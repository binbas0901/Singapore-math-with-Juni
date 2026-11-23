#if DEBUG
import AVFoundation
import Foundation

/// Decodes an M4A, prepends silence in memory so hardware ramp-up is absorbed,
/// then plays the combined buffer. Original files are never modified.
final class PrependedSilencePlayer: NSObject, @unchecked Sendable {
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var combinedBuffer: AVAudioPCMBuffer?
    private let silenceDuration: TimeInterval = 0.18
    private var fileDuration: TimeInterval = 0
    private var startedAt: ContinuousClock.Instant?
    private var pausedAt: TimeInterval = 0
    private var isPaused = false

    var duration: TimeInterval { fileDuration }
    var isPlaying: Bool { playerNode.isPlaying }

    var currentTime: TimeInterval {
        guard let startedAt, !isPaused else { return pausedAt }
        let elapsed = startedAt.duration(to: ContinuousClock().now).components
        let total = Double(elapsed.seconds) + Double(elapsed.attoseconds) / 1e18
        return max(0, total - silenceDuration)
    }

    override init() {
        super.init()
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: nil)
    }

    func load(url: URL) -> Bool {
        do {
            let file = try AVAudioFile(forReading: url)
            fileDuration = Double(file.length) / file.processingFormat.sampleRate
            guard fileDuration > 0 else { return false }

            guard let format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                              sampleRate: file.processingFormat.sampleRate,
                                              channels: file.processingFormat.channelCount,
                                              interleaved: false),
                  let audioBuffer = AVAudioPCMBuffer(pcmFormat: format,
                                                     frameCapacity: AVAudioFrameCount(file.length)) else {
                return false
            }
            try file.read(into: audioBuffer)

            let silenceFrames = AVAudioFrameCount(silenceDuration * format.sampleRate)
            let totalFrames = silenceFrames + audioBuffer.frameLength
            guard let combined = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: totalFrames) else {
                return false
            }
            combined.frameLength = totalFrames

            if let src = audioBuffer.floatChannelData, let dst = combined.floatChannelData {
                for ch in 0..<Int(format.channelCount) {
                    memcpy(dst[ch] + Int(silenceFrames),
                           src[ch],
                           Int(audioBuffer.frameLength) * MemoryLayout<Float>.size)
                }
            }
            combinedBuffer = combined
            return true
        } catch {
            print("PrependedSilencePlayer load failed: \(error)")
            return false
        }
    }

    func play(from position: TimeInterval = 0) {
        guard let buffer = combinedBuffer else { return }
        playerNode.stop()
        pausedAt = position
        isPaused = false
        playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !engine.isRunning { try? engine.start() }
        startedAt = ContinuousClock().now
        playerNode.play()
    }

    func pause() {
        pausedAt = currentTime
        isPaused = true
        playerNode.pause()
    }

    func stop() {
        playerNode.stop()
        isPaused = false
        pausedAt = 0
        startedAt = nil
    }

    func resume() {
        isPaused = false
        startedAt = ContinuousClock().now
        playerNode.play()
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
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers])
        try? session.setActive(true)
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

    static func prependedPlayer(for id: String, in bundle: Bundle = .main) -> PrependedSilencePlayer? {
        guard let url = url(for: id, extension: "m4a", in: bundle) else { return nil }
        let p = PrependedSilencePlayer()
        return p.load(url: url) ? p : nil
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