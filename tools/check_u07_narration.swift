import AVFoundation
import Foundation

@main
struct CheckU07Narration {
    static func main() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".bundle", isDirectory: true)
        let resources = directory.appendingPathComponent("U07Narration", isDirectory: true)
        try FileManager.default.createDirectory(at: resources, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let fixturePath = try require(CommandLine.arguments.dropFirst().first, "Pass a silent AAC M4A fixture")
        let source = URL(fileURLWithPath: fixturePath)
        let invalidSheets = ["{}", "{\"offsets\":[0,0.5]}", "{\"offsets\":[0,0.5,0.5]}",
                             "{\"offsets\":[0,0.5,9]}"]
        for (index, sheet) in invalidSheets.enumerated() {
            try FileManager.default.copyItem(at: source, to: resources.appendingPathComponent("invalid-\(index).m4a"))
            try Data(sheet.utf8).write(to: resources.appendingPathComponent("invalid-\(index).json"))
        }
        try FileManager.default.copyItem(at: source, to: resources.appendingPathComponent("missing-sheet.m4a"))
        try FileManager.default.copyItem(at: source, to: resources.appendingPathComponent("test-count.m4a"))
        try Data(#"{"offsets":[0.16,0.37,1.42]}"#.utf8).write(
            to: resources.appendingPathComponent("test-count.json")
        )
        try Data("corrupt audio".utf8).write(to: resources.appendingPathComponent("corrupt.m4a"))

        let bundle = try require(Bundle(url: directory), "Open the temporary fixture bundle")
        try checkSidecars(source: source, resources: resources, bundle: bundle)
        let cues = [5, 6, 7]
        func observe(_ id: String = "test-count") -> (U07Narration.Timeline, AVAudioPlayer?) {
            U07Narration.observe(id, cues: cues, fallbackDuration: 7, quiet: 0.5, in: bundle)
        }

        let (missing, missingPlayer) = observe("missing")
        precondition(missingPlayer == nil && missing.duration == 7 && missing.cue(at: 1.5) == 6)
        let (missingSheet, missingSheetPlayer) = observe("missing-sheet")
        precondition(missingSheetPlayer == nil && missingSheet.duration == 7)

        for index in invalidSheets.indices {
            let (fallback, invalidPlayer) = observe("invalid-\(index)")
            precondition(invalidPlayer == nil && fallback.offsets == [0, 1, 2])
        }

        let (timeline, recording) = observe()
        let player = try require(recording, "Load valid local M4A and cue marks")
        precondition(timeline.duration == player.duration + 0.5)
        precondition(timeline.duration < 7)
        precondition(timeline.offset(for: 5) == 0.16)
        precondition(timeline.cue(at: 0.36) == 5 && timeline.cue(at: 0.37) == 6)
        precondition(timeline.cue(at: 1.41) == 6 && timeline.cue(at: 1.42) == 7)

        player.currentTime = timeline.offset(for: 6)
        if player.play() {
            Thread.sleep(forTimeInterval: 0.12)
            player.pause()
            let held = player.currentTime
            precondition(!player.isPlaying && held >= 0.37)
            Thread.sleep(forTimeInterval: 0.2)
            precondition(abs(player.currentTime - held) < 0.01, "Hold the cue clock while paused")
            precondition(player.play(), "Resume the paused local player")
            Thread.sleep(forTimeInterval: 0.18)
            precondition(player.currentTime > held, "Resume from the held position")
            player.stop()

            let replay = try require(observe().1, "Start a new player for Replay")
            precondition(!player.isPlaying && replay.currentTime == 0 && replay.play())
            replay.stop()
            try checkObserveCompletion(using: { try require(observe().1, "Load Observe fixture") })
            print("PASS: local playback, pause, resume and replay")
        } else {
            throw NSError(domain: "U07 narration check", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Local audio output unavailable for playback tests"])
        }

        let (corrupt, corruptPlayer) = observe("corrupt")
        precondition(corruptPlayer == nil && corrupt.duration == 7)
        print("PASS: asset loading, cue validation, recording clock and fallback")
    }

    private static func checkSidecars(source: URL, resources: URL, bundle: Bundle) throws {
        let rows = [
            ("count", [5, 6, 7, 8, 9, 10], false),
            ("first", [19, 20], true),
            ("second", [22, 23], true),
            ("count-tray", [32, 33, 34, 35], false),
            ("bond", [38, 40, 42], true),
            ("recombine", [49, 51, 52, 53, 54, 55, 56, 57], true)
        ]
        for (name, _, _) in rows {
            try FileManager.default.copyItem(at: source, to: resources.appendingPathComponent("u07-observe-\(name).m4a"))
        }
        // Keep both count recordings valid alongside the four invalid row-start recordings.
        for valid in [true, false] {
            for (name, cues, requiresZero) in rows {
                var offsets = cues.indices.map { Double($0) / 4 + 0.125 }
                if requiresZero { offsets[0] = valid ? 0 : 0.000_001 }
                let url = resources.appendingPathComponent("u07-observe-\(name).json")
                try JSONEncoder().encode(["offsets": offsets]).write(to: url)
            }
            for (name, cues, requiresZero) in rows {
                let id = "u07-observe-\(name)"
                let (row, player) = U07Narration.observe(id, cues: cues, fallbackDuration: 7, quiet: 0.5, in: bundle)
                let usesRecording = valid || !requiresZero
                precondition(row.usesRecording == usesRecording && (player != nil) == usesRecording, id)
                if let player {
                    precondition(row.offsets[0] == (requiresZero ? 0 : 0.125), id)
                    precondition(row.duration == player.duration + 0.5, id)
                } else {
                    precondition(row.offsets == cues.map { Double($0 - cues[0]) } && row.duration == 7, id)
                }
            }
        }
        print("PASS: all six Observe sidecar contracts in a mixed fixture bundle")
    }

    private static func checkObserveCompletion(using load: () throws -> AVAudioPlayer) throws {
        let early = try load()
        let playback = U07Narration.ObservePlayback(player: early)
        precondition(early.play())
        early.stop()
        let now = ContinuousClock.now
        let held = 0.16
        precondition(playback.tick(player: early, position: held, elapsed: 2, now: now) == .waitingForCompletion)
        precondition(playback.tick(player: early, position: held, elapsed: 2, now: now + .milliseconds(100)) == .stopped)

        let player = try load()
        let natural = U07Narration.ObservePlayback(player: player)
        player.currentTime = player.duration - 0.3
        let position = player.currentTime
        precondition(player.play())
        let deadline = ContinuousClock.now + .seconds(3)
        var tick = U07Narration.ObservePlayback.Tick.waitingForCompletion
        repeat {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.01))
            tick = natural.tick(player: player, position: position, elapsed: 0.01, now: .now)
        } while tick != .position(player.duration) && tick != .stopped && ContinuousClock.now < deadline
        precondition(tick == .position(player.duration), "Natural completion must start the quiet hold")
        precondition(natural.tick(player: player, position: player.duration, elapsed: 0.25, now: .now)
                     == .position(player.duration + 0.25))
        print("PASS: premature stop freezes the cue clock and natural completion starts the quiet hold")
    }

    private static func require<T>(_ optional: T?, _ message: String) throws -> T {
        guard let optional else {
            throw NSError(domain: "U07 narration check", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
        }
        return optional
    }

}
