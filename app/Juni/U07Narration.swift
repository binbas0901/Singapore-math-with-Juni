#if DEBUG
import AVFoundation
import Foundation

/// One long-lived engine + player node. Never stopped between sentences so the
/// hardware stays warm. This is why only the second sentence was clean before.
final class ContinuousNarrationPlayer: NSObject, @unchecked Sendable {
    static let shared = ContinuousNarrationPlayer()

    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var currentFile: AVAudioFile?
    private var fileDuration: TimeInterval = 0
    private var startedAt: ContinuousClock.Instant?
    private var startPosition: TimeInterval = 0
    private var isPaused = false

    var duration: TimeInterval { fileDuration }
    var isPlaying: Bool { playerNode.isPlaying }

    var currentTime: TimeInterval {
        guard let startedAt, !isPaused else { return startPosition }
        let elapsed = startedAt.duration(to: ContinuousClock().now).components
        let total = Double(elapsed.seconds) + Double(elapsed.attoseconds) / 1e18
        return min(fileDuration, max(0, startPosition + total))
    }

    private override init() {
        super.init()
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: nil)
        activateAndWarm()
    }

    private func activateAndWarm() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers])
        try? session.setActive(true)
        do {
            if !engine.isRunning { try engine.start() }
            let format = engine.mainMixerNode.outputFormat(forBus: 0)
            let frames = AVAudioFrameCount(0.2 * format.sampleRate)
            if let silent = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames) {
                silent.frameLength = frames
                playerNode.scheduleBuffer(silent, at: nil, options: [], completionHandler: nil)
                playerNode.play()
            }
        } catch { }
    }

    func loadAndPlay(url: URL, from position: TimeInterval = 0) -> Bool {
        do {
            if !engine.isRunning { try engine.start() }
            let file = try AVAudioFile(forReading: url)
            currentFile = file
            fileDuration = Double(file.length) / file.processingFormat.sampleRate
            startPosition = position
            isPaused = false

            let startFrame = AVAudioFramePosition(position * file.processingFormat.sampleRate)
            let frames = AVAudioFrameCount(max(0, file.length - startFrame))
            if frames > 0 {
                playerNode.scheduleSegment(file,
                                            startingFrame: startFrame,
                                            frameCount: frames,
                                            at: nil,
                                            completionHandler: nil)
            }
            if !playerNode.isPlaying { playerNode.play() }
            startedAt = ContinuousClock().now
            return true
        } catch {
            print("ContinuousNarrationPlayer loadAndPlay failed: \(error)")
            return false
        }
    }

    func pause() {
        startPosition = currentTime
        isPaused = true
        playerNode.pause()
    }

    func stop() {
        currentFile = nil
        isPaused = false
        startPosition = 0
        startedAt = nil
    }

    func resume() {
        isPaused = false
        startedAt = ContinuousClock().now
        if !playerNode.isPlaying { playerNode.play() }
    }
}

enum U07Narration {
    private static let zeroStartClips: Set<String> = [
        "u07-observe-first", "u07-observe-second", "u07-observe-bond", "u07-observe-recombine"
    ]

    private struct CueSheet: Decodable {
        let offsets: [TimeInterval]
    }

    static func activateSession() {
        _ = ContinuousNarrationPlayer.shared
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

    private static func url(for id: String, extension ext: String, in bundle: Bundle) -> URL? {
        if let primed = bundle.url(forResource: id + "-primed", withExtension: ext, subdirectory: "U07Narration") {
            return primed
        }
        return bundle.url(forResource: id, withExtension: ext, subdirectory: "U07Narration")
    }

    static func player(for id: String, in bundle: Bundle = .main) -> AVAudioPlayer? {
        guard let url = url(for: id, extension: "m4a", in: bundle),
              let player = try? AVAudioPlayer(contentsOf: url),
              player.duration.isFinite, player.duration > 0 else { return nil }
        player.volume = 1.0
        player.prepareToPlay()
        return player
    }

    static func continuousCurrentTime() -> TimeInterval {
        ContinuousNarrationPlayer.shared.currentTime
    }

    static func playContinuous(id: String, from position: TimeInterval = 0, in bundle: Bundle = .main) -> Bool {
        guard let url = url(for: id, extension: "m4a", in: bundle) else { return false }
        return ContinuousNarrationPlayer.shared.loadAndPlay(url: url, from: position)
    }

    static func observe(_ id: String, cues: [Int], fallbackDuration: TimeInterval,
                        quiet: TimeInterval, requiresImmediateCue: Bool = false, in bundle: Bundle = .main) -> (Timeline, AVAudioPlayer?) {
        let player = player(for: id, in: bundle)
        var offsets: [TimeInterval] = cues.count == 1 ? [0] : []
        if cues.count > 1,
           let url = url(for: id, extension: "json", in: bundle),
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