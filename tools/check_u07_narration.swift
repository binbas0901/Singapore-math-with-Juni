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
            print("PASS: local playback, pause, resume and replay")
        } else {
            print("SKIP: Mac audio output unavailable for audible playback lifecycle")
        }

        let (corrupt, corruptPlayer) = observe("corrupt")
        precondition(corruptPlayer == nil && corrupt.duration == 7)
        print("PASS: asset loading, cue validation, recording clock and fallback")
    }

    private static func require<T>(_ optional: T?, _ message: String) throws -> T {
        guard let optional else {
            throw NSError(domain: "U07 narration check", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
        }
        return optional
    }

}
