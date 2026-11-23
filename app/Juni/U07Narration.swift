#if DEBUG
import AVFoundation
import Foundation

/// Persistent engine that is started and primed once so every later clip
/// begins at full level. Avoids the clipped first word in the simulator.
final class PersistentNarrationEngine: NSObject, @unchecked Sendable {
    static let shared = PersistentNarrationEngine()

    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var primed = false
    private let silentDuration: TimeInterval = 0.25

    private override init() {
        super.init()
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: nil)
    }

    /// Call once when the lesson appears. Starts the engine and plays silence
    /// so the hardware is already at full gain before any real clip.
    func activateAndPrime() {
        activateSession()
        guard !primed else { return }
        do {
            if !engine.isRunning { try engine.start() }
            if let silent = makeSilentBuffer() {
                playerNode.scheduleBuffer(silent, at: nil, options: [], completionHandler: nil)
                playerNode.play()
                // Let the silence finish so the ramp-up is complete.
                DispatchQueue.main.asyncAfter(deadline: .now() + silentDuration + 0.05) { [weak self] in
                    self?.playerNode.stop()
                    self?.primed = true
                }
            } else {
                primed = true
            }
        } catch {
            print("PersistentNarrationEngine prime failed: \(error)")
        }
    }

    private func activateSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers])
        try? session.setActive(true)
    }

    private func makeSilentBuffer() -> AVAudioPCMBuffer? {
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        guard format.sampleRate > 0 else { return nil }
        let frames = AVAudioFrameCount(silentDuration * format.sampleRate)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames)
        buffer?.frameLength = frames
        return buffer
    }

    /// Play an M4A. The engine is already running and primed.
    func play(url: URL, from position: TimeInterval = 0) -> Bool {
        guard primed || engine.isRunning else { return false }
        do {
            let file = try AVAudioFile(forReading: url)
            playerNode.stop()
            let startFrame = AVAudioFramePosition(position * file.processingFormat.sampleRate)
            let frames = AVAudioFrameCount(max(0, file.length - startFrame))
            if frames > 0 {
                playerNode.scheduleSegment(file,
                                            startingFrame: startFrame,
                                            frameCount: frames,
                                            at: nil,
                                            completionHandler: nil)
            }
            if !engine.isRunning { try engine.start() }
            playerNode.play()
            return true
        } catch {
            print("PersistentNarrationEngine play failed: \(error)")
            return false
        }
    }

    func stop() { playerNode.stop() }
    func pause() { playerNode.pause() }
    func resume() { playerNode.play() }
}

enum U07Narration {
    private static let zeroStartClips: Set<String> = [
        "u07-observe-first", "u07-observe-second", "u07-observe-bond", "u07-observe-recombine"
    ]

    private struct CueSheet: Decodable {
        let offsets: [TimeInterval]
    }

    static func activateSession() {
        PersistentNarrationEngine.shared.activateAndPrime()
    }

    final class ObservePlayback: NSObject, AVAudioPlayerDelegate {
        enum Tick: Equatable {
            case position(TimeInterval)
            case waitingForCompletion
            case stopped
        }

        private let completionLock = NSLock()
        private var finishedSuccessfully: Bool?
        private var stoppedAt: ContinuousClock.Instant?

        init(player: AVAudioPlayer) {
            super.init()
            player.delegate = self
        }

        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            completionLock.withLock { finishedSuccessfully = flag }
        }

        func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: (any Error)?) {
            completionLock.withLock { finishedSuccessfully = false }
        }

        func tick(player: AVAudioPlayer, position: TimeInterval, elapsed: TimeInterval,
                  now: ContinuousClock.Instant) -> Tick {
            if position >= player.duration { return .position(position + elapsed) }
            switch completionLock.withLock({ finishedSuccessfully }) {
            case true?: return .position(player.duration)
            case false?: return .stopped
            case nil: break
            }
            if player.isPlaying {
                stoppedAt = nil
                return .position(max(position, min(player.currentTime, player.duration.nextDown)))
            }
            let firstStoppedTick = stoppedAt ?? now
            stoppedAt = firstStoppedTick
            return firstStoppedTick.duration(to: now) >= .milliseconds(100)
                ? .stopped : .waitingForCompletion
        }
    }

    struct Timeline {
        let cues: [Int]
        let offsets: [TimeInterval]
        let duration: TimeInterval
        let usesRecording: Bool

        init(cues: [Int], fallbackDuration: TimeInterval, recordingDuration: TimeInterval? = nil,
             offsets recordedOffsets: [TimeInterval] = [], quiet: TimeInterval = 0) {
            self.cues = cues
            if let recordingDuration, recordingDuration.isFinite, recordingDuration > 0,
               recordedOffsets.count == cues.count,
               recordedOffsets.allSatisfy({ $0 >= 0 && $0 < recordingDuration }),
               zip(recordedOffsets, recordedOffsets.dropFirst()).allSatisfy({ $0 < $1 }) {
                usesRecording = true
                offsets = recordedOffsets
                duration = recordingDuration + quiet
            } else {
                usesRecording = false
                offsets = cues.map { Double($0 - cues[0]) }
                duration = fallbackDuration
            }
        }

        func cue(at position: TimeInterval) -> Int {
            offsets.lastIndex { $0 <= position }.map { cues[$0] } ?? cues[0]
        }

        func offset(for cue: Int) -> TimeInterval {
            cues.lastIndex { $0 <= cue }.map { offsets[$0] } ?? 0
        }
    }

    static func player(for id: String, in bundle: Bundle = .main) -> AVAudioPlayer? {
        guard let url = bundle.url(forResource: id, withExtension: "m4a", subdirectory: "U07Narration"),
              let player = try? AVAudioPlayer(contentsOf: url),
              player.duration.isFinite, player.duration > 0 else { return nil }
        player.volume = 1.0
        player.prepareToPlay()
        return player
    }

    /// Play using the already-primed persistent engine.
    static func playPrimed(id: String, in bundle: Bundle = .main, from position: TimeInterval = 0) -> Bool {
        guard let url = bundle.url(forResource: id, withExtension: "m4a", subdirectory: "U07Narration") else {
            return false
        }
        return PersistentNarrationEngine.shared.play(url: url, from: position)
    }

    static func observe(_ id: String, cues: [Int], fallbackDuration: TimeInterval,
                        quiet: TimeInterval, requiresImmediateCue: Bool = false, in bundle: Bundle = .main) -> (Timeline, AVAudioPlayer?) {
        let player = player(for: id, in: bundle)
        var offsets: [TimeInterval] = cues.count == 1 ? [0] : []
        if cues.count > 1,
           let url = bundle.url(forResource: id, withExtension: "json", subdirectory: "U07Narration"),
           let data = try? Data(contentsOf: url),
           let sheet = try? JSONDecoder().decode(CueSheet.self, from: data),
           !(requiresImmediateCue || zeroStartClips.contains(id)) || sheet.offsets.first == 0 {
            offsets = sheet.offsets
        }
        let timeline = Timeline(cues: cues, fallbackDuration: fallbackDuration,
                                recordingDuration: player?.duration, offsets: offsets, quiet: quiet)
        return (timeline, timeline.usesRecording ? player : nil)
    }
}
#endif