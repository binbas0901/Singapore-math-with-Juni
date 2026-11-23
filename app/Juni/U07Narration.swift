#if DEBUG
import AVFoundation
import Foundation

/// Forces the iOS audio hardware to full level before real content plays.
/// Prevents the clipped/attenuated first words that happen with plain AVAudioPlayer.
final class PrimedNarrationPlayer: NSObject {
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var file: AVAudioFile?
    private var silentBuffer: AVAudioPCMBuffer?
    private let silentDuration: TimeInterval = 0.10
    private var playbackStartPosition: TimeInterval = 0

    var duration: TimeInterval {
        guard let file else { return 0 }
        return Double(file.length) / file.processingFormat.sampleRate
    }
    var isPlaying: Bool { playerNode.isPlaying }

    /// Time inside the real recording (silent prime is excluded).
    var currentTime: TimeInterval {
        guard let nodeTime = playerNode.lastRenderTime,
              let playerTime = playerNode.playerTime(forNodeTime: nodeTime) else {
            return playbackStartPosition
        }
        let elapsed = Double(playerTime.sampleTime) / playerTime.sampleRate
        return max(0, elapsed - silentDuration + playbackStartPosition)
    }

    override init() {
        super.init()
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: nil)
        createSilentBuffer()
    }

    private func createSilentBuffer() {
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        guard format.sampleRate > 0 else { return }
        let frames = AVAudioFrameCount(silentDuration * format.sampleRate)
        silentBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames)
        silentBuffer?.frameLength = frames
    }

    func load(url: URL) -> Bool {
        do {
            file = try AVAudioFile(forReading: url)
            return file != nil
        } catch {
            print("PrimedNarrationPlayer load failed: \(error)")
            return false
        }
    }

    func play(from position: TimeInterval = 0) {
        guard let file else { return }
        playerNode.stop()
        playbackStartPosition = position

        if let silent = silentBuffer {
            playerNode.scheduleBuffer(silent, at: nil, options: [], completionHandler: nil)
        }

        let startFrame = AVAudioFramePosition(position * file.processingFormat.sampleRate)
        let frames = AVAudioFrameCount(max(0, file.length - startFrame))
        if frames > 0 {
            playerNode.scheduleSegment(file,
                                        startingFrame: startFrame,
                                        frameCount: frames,
                                        at: nil,
                                        completionHandler: nil)
        }

        if !engine.isRunning {
            try? engine.start()
        }
        playerNode.play()
    }

    func pause() { playerNode.pause() }
    func stop() { playerNode.stop() }
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
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("U07Narration: session activation failed: \(error)")
        }
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

    /// Prefer the primed engine player. Falls back to classic AVAudioPlayer.
    static func primedPlayer(for id: String, in bundle: Bundle = .main) -> PrimedNarrationPlayer? {
        guard let url = bundle.url(forResource: id, withExtension: "m4a", subdirectory: "U07Narration") else {
            return nil
        }
        let primed = PrimedNarrationPlayer()
        return primed.load(url: url) ? primed : nil
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