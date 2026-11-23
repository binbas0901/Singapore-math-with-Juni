#if DEBUG
import AVFoundation
import Foundation

@MainActor
enum U07Narration {
    private static let zeroStartClips: Set<String> = [
        "u07-observe-first", "u07-observe-second", "u07-observe-bond", "u07-observe-recombine"
    ]

    private struct CueSheet: Decodable {
        let offsets: [TimeInterval]
    }

    // One engine and one output node remain alive between short sentences.
    // Stop unschedules a clip but does not stop or tear down the output engine.
    @MainActor
    final class AudioOutput {
        static let shared = AudioOutput()

        let engine = AVAudioEngine()
        let node = AVAudioPlayerNode()
        var activeID: UUID?
        private var format: AVAudioFormat?

        private init() {
            engine.attach(node)
        }

        func ensureRunning(format requested: AVAudioFormat) -> Bool {
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playback, mode: .default)
                try session.setActive(true)

                if let format {
                    // Every U07 narration export uses the same 44.1kHz mono format.
                    guard format.sampleRate == requested.sampleRate,
                          format.channelCount == requested.channelCount else { return false }
                } else {
                    engine.connect(node, to: engine.mainMixerNode, format: requested)
                    format = requested
                }
                if !engine.isRunning { try engine.start() }
                return true
            } catch {
                return false
            }
        }
    }

    @MainActor
    final class Player {
        private let file: AVAudioFile
        private let id = UUID()
        private let output = AudioOutput.shared
        private var position: TimeInterval = 0
        private var segmentStart: TimeInterval = 0
        private var paused = false

        let duration: TimeInterval

        init?(url: URL) {
            guard let file = try? AVAudioFile(forReading: url),
                  file.length > 0,
                  file.processingFormat.sampleRate > 0 else { return nil }
            self.file = file
            duration = Double(file.length) / file.processingFormat.sampleRate
        }

        var currentTime: TimeInterval {
            get {
                guard output.activeID == id, !paused, output.node.isPlaying,
                      let renderTime = output.node.lastRenderTime,
                      let playbackTime = output.node.playerTime(forNodeTime: renderTime),
                      playbackTime.sampleRate > 0 else { return position }
                return min(duration, max(position, segmentStart +
                    Double(playbackTime.sampleTime) / playbackTime.sampleRate))
            }
            set {
                if output.activeID == id {
                    output.node.stop()
                    output.activeID = nil
                }
                position = min(duration, max(0, newValue))
                paused = false
            }
        }

        var isPlaying: Bool {
            output.activeID == id && !paused &&
                output.node.isPlaying && currentTime < duration
        }

        @discardableResult
        func play() -> Bool {
            if output.activeID == id && paused {
                output.node.play()
                paused = false
                return true
            }
            guard output.ensureRunning(format: file.processingFormat) else { return false }
            output.node.stop()
            output.activeID = id
            let rate = file.processingFormat.sampleRate
            let first = min(file.length, AVAudioFramePosition(position * rate))
            let remaining = file.length - first
            guard remaining > 0,
                  remaining <= Int64(UInt32.max) else {
                output.activeID = nil
                return false
            }
            segmentStart = position
            output.node.scheduleSegment(file, startingFrame: first,
                                        frameCount: AVAudioFrameCount(remaining),
                                        at: nil, completionHandler: nil)
            output.node.play()
            return true
        }

        func pause() {
            guard output.activeID == id, !paused else { return }
            position = currentTime
            output.node.pause()
            paused = true
        }

        func stop() {
            if output.activeID == id {
                output.node.stop()
                output.activeID = nil
            }
            paused = false
            position = 0
            segmentStart = 0
        }
    }

    @MainActor
    final class ObservePlayback {
        enum Tick: Equatable {
            case position(TimeInterval)
            case waitingForCompletion
            case stopped
        }

        // A brief start/route interruption should not prematurely end a clip.
        private var stoppedAt: ContinuousClock.Instant?

        func tick(player: Player, position: TimeInterval, elapsed: TimeInterval,
                  now: ContinuousClock.Instant) -> Tick {
            if position >= player.duration { return .position(position + elapsed) }
            let heardPosition = player.currentTime
            if heardPosition >= player.duration - 0.015 {
                return .position(player.duration)
            }
            if player.isPlaying {
                stoppedAt = nil
                return .position(max(position, heardPosition))
            }
            let first = stoppedAt ?? now
            stoppedAt = first
            return first.duration(to: now) >= .milliseconds(350)
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

    static func player(for id: String, in bundle: Bundle = .main) -> Player? {
        guard let url = bundle.url(forResource: id, withExtension: "m4a", subdirectory: "U07Narration"),
              let player = Player(url: url),
              player.duration.isFinite, player.duration > 0 else { return nil }
        return player
    }

    static func observe(_ id: String, cues: [Int], fallbackDuration: TimeInterval,
                        quiet: TimeInterval, requiresImmediateCue: Bool = false, in bundle: Bundle = .main) -> (Timeline, Player?) {
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
