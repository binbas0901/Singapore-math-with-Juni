import Foundation

/// Bundled preview projection of DATA-001 items and typed cue actions.
public struct NumberBondLesson: Decodable {
    public enum Error: Swift.Error {
        case invalidContent
    }

    public enum Prompt: String, CaseIterable, Sendable {
        case tryEntry, tryCount, tryBond, trySplit, tryRecount, tryDone
        case tryRetry, tryMoveBack, tryRecountRetry, checkEntry, checkAnswer, checkRetry, checkSuccess
    }

    public struct Caption: Decodable {
        public let text: String
        public let clipID: String?
    }

    public struct Item: Decodable {
        public enum ModelRequirement: String, Decodable {
            case knownPartInBowl, wholeAndBothParts
        }

        public let whole: Int
        public let knownPart: Int
        public let expectedAnswer: Int
        public let modelRequirement: ModelRequirement

        public func matches(answer: Int?, bowlCount: Int) -> Bool {
            guard let missing = NumberBond.missingPart(whole: whole, known: knownPart),
                  (0...whole).contains(bowlCount) else { return false }
            let matchesModel = bowlCount == knownPart
                || (modelRequirement == .wholeAndBothParts && whole - bowlCount == knownPart)
            return matchesModel && answer == missing
        }

        fileprivate var isValid: Bool {
            whole > 1 && knownPart > 0 && expectedAnswer > 0
                && NumberBond.missingPart(whole: whole, known: knownPart) == expectedAnswer
        }

        fileprivate func repeats(_ other: Item) -> Bool {
            whole == other.whole && (knownPart == other.knownPart || knownPart == other.expectedAnswer)
        }
    }

    public enum Group: String, Decodable, Hashable {
        case tray, bowl
    }

    public struct Cue: Decodable {
        public let at: Int
        public let moveToBowl: Int?
        public let recombine: Bool?
        public let count: Int?
        public let highlight: Set<Group>?
        public let revealTrayCount: Bool?
    }

    public struct Step: Decodable {
        public enum Reaction: String, Decodable {
            case smiling, thinking, focused, delighted
        }

        public let caption: Caption
        public let cues: [Cue]
        public let quiet: Double
        public let showWhole: Bool
        public let showParts: Bool
        public let showTrayCount: Bool
        public let otherGroup: Bool
        public let reaction: Reaction
        public let highlight: Set<Group>
        public let requiresImmediateAudioCue: Bool?
        public var start: Int { cues[0].at }
    }

    public struct Frame: Equatable {
        public var time = 0
        public var manual = true
        public var countIndex = 0
        public var waitingForFirstCue = false

        public init(time: Int = 0, manual: Bool = true, countIndex: Int = 0,
                    waitingForFirstCue: Bool = false) {
            self.time = time
            self.manual = manual
            self.countIndex = countIndex
            self.waitingForFirstCue = waitingForFirstCue
        }
    }

    public struct Projection {
        public let step: Step
        public let index: Int
        public let bowl: Set<Int>
        public let historical: Bool
        public let showTrayCount: Bool
        public let linkedGroups: Set<Group>
        public let indicatedCounter: Int?
        public let indicatedWord: String?
        public let canCountNext: Bool
        public let canTry: Bool
        public let manualCue: Int
    }

    private let schemaVersion: Int
    public let id: String
    public let version: String
    public let title: String
    public let synthetic: Bool
    public let observe: Item
    public let guided: Item
    public let check: Item
    public let steps: [Step]
    public let end: Int
    private let prompts: [String: Caption]

    public static func load(from url: URL) throws -> Self {
        guard url.isFileURL else { throw Error.invalidContent }
        return try decode(Data(contentsOf: url))
    }

    public static func decode(_ data: Data) throws -> Self {
        try JSONDecoder().decode(Self.self, from: data)
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, id, version, title, synthetic, observe, guided, check, steps, end, prompts
    }

    public init(from decoder: Decoder) throws {
        let fields = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try fields.decode(Int.self, forKey: .schemaVersion)
        id = try fields.decode(String.self, forKey: .id)
        version = try fields.decode(String.self, forKey: .version)
        title = try fields.decode(String.self, forKey: .title)
        synthetic = try fields.decode(Bool.self, forKey: .synthetic)
        observe = try fields.decode(Item.self, forKey: .observe)
        guided = try fields.decode(Item.self, forKey: .guided)
        check = try fields.decode(Item.self, forKey: .check)
        steps = try fields.decode([Step].self, forKey: .steps)
        end = try fields.decode(Int.self, forKey: .end)
        prompts = try fields.decode([String: Caption].self, forKey: .prompts)
        try validate()
    }

    public func prompt(_ key: Prompt) -> Caption {
        let whole = Self.words[check.whole].lowercased()
        let known = Self.words[check.knownPart].lowercased()
        let question = "The whole is \(whole). One part is \(known). What is the other part?"
        let model = "Show how your two parts make \(whole)"
        // Preserve the reviewed U07 media association only for its original question.
        let audioPrefix = id == "u07" && !synthetic && check.whole == 8 && check.knownPart == 3 ? "u07-" : nil
        switch key {
        case .checkEntry: return Caption(text: "\(question) \(model) with counters.", clipID: audioPrefix.map { $0 + "check-entry" })
        case .checkAnswer: return Caption(text: "Put your answer in the empty part.", clipID: audioPrefix.map { $0 + "check-answer" })
        case .checkRetry: return Caption(text: "Take another look. \(question) \(model).", clipID: audioPrefix.map { $0 + "check-retry" })
        default:
            // The loader requires every authored prompt.
            return prompts[key.rawValue] ?? Caption(text: "", clipID: nil)
        }
    }

    public func project(_ frame: Frame) -> Projection {
        let index = steps.lastIndex { $0.start <= frame.time } ?? 0
        let step = steps[index]
        let counts = step.cues.compactMap { $0.count == nil ? nil : $0 }
        let manualCount = counts.indices.contains(frame.countIndex) ? counts[frame.countIndex] : nil
        let actions = step.cues.filter { $0.moveToBowl != nil || $0.recombine == true }
        let currentCues = step.cues.filter { frame.manual || $0.at <= frame.time }
        var bowl: Set<Int> = []
        var historical = false
        for cue in steps.prefix(index).flatMap(\.cues) + currentCues {
            if let counter = cue.moveToBowl { bowl.insert(counter) }
            if cue.recombine == true {
                bowl.removeAll()
                historical = true
            }
        }
        let countCue = frame.manual ? manualCount : currentCues.last { $0.count != nil }
        let count = frame.waitingForFirstCue ? nil : countCue?.count
        let order = counts.compactMap(\.count)
        let word = count.flatMap { order.firstIndex(of: $0) }.map { Self.words[$0 + 1] }
        let move = frame.manual ? actions.last?.moveToBowl : currentCues.last { $0.moveToBowl != nil }?.moveToBowl
        let linked = currentCues.compactMap(\.highlight).last ?? step.highlight
        let showTray = step.showTrayCount || currentCues.contains { $0.revealTrayCount == true }
        return Projection(
            step: step, index: index, bowl: bowl, historical: historical,
            showTrayCount: showTray, linkedGroups: frame.manual ? step.highlight : linked,
            indicatedCounter: move ?? count, indicatedWord: word,
            canCountNext: frame.manual && frame.countIndex + 1 < counts.count,
            canTry: frame.manual ? index == steps.count - 1 : frame.time == end,
            manualCue: manualCount?.at ?? actions.last?.at ?? step.start
        )
    }

    private static let words = ["Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten"]
    private static let independentPrompts: Set<Prompt> = [.checkEntry, .checkAnswer, .checkRetry]

    private func validate() throws {
        guard schemaVersion == 1, Self.validID(id), !version.isEmpty, !title.isEmpty,
              [observe, guided, check].allSatisfy(\.isValid),
              !check.repeats(observe), !check.repeats(guided),
              guided.modelRequirement == .knownPartInBowl, check.modelRequirement == .wholeAndBothParts,
              (1...300).contains(end), (2...32).contains(steps.count),
              Set(prompts.keys) == Set(Prompt.allCases.filter { !Self.independentPrompts.contains($0) }.map(\.rawValue)),
              (Array(prompts.values) + steps.map(\.caption)).allSatisfy(validCaption),
              steps.allSatisfy({ $0.caption.clipID?.hasPrefix(id + "-observe-") ?? true }),
              prompts.allSatisfy({ key, caption in
                  guard let clip = caption.clipID else { return true }
                  return clip.hasPrefix(id + (key == Prompt.checkSuccess.rawValue ? "-check-" : "-try-"))
              }),
              steps.allSatisfy({ (!$0.showParts || $0.showWhole) && (1...16).contains($0.cues.count) && (0...5).contains($0.quiet) })
        else { throw Error.invalidContent }

        let cues = steps.flatMap(\.cues)
        guard cues.first?.at == 0, cues.allSatisfy({ (0..<end).contains($0.at) }),
              zip(cues, cues.dropFirst()).allSatisfy({ $0.at < $1.at })
        else { throw Error.invalidContent }

        var bowl: Set<Int> = []
        var showedParts = false
        var recombined = false
        for step in steps {
            var counted: Set<Int> = []
            let lastAction = step.cues.last { $0.moveToBowl != nil || $0.recombine == true }
            for cue in step.cues {
                if let counter = cue.moveToBowl {
                    guard !showedParts, cue.recombine != true, (1...observe.whole).contains(counter),
                          bowl.insert(counter).inserted else { throw Error.invalidContent }
                }
                if cue.recombine == true {
                    guard showedParts, !recombined, !bowl.isEmpty else { throw Error.invalidContent }
                    bowl.removeAll()
                    recombined = true
                }
                if let counter = cue.count {
                    guard (1...observe.whole).contains(counter), !bowl.contains(counter),
                          counted.insert(counter).inserted, counter != cue.moveToBowl,
                          lastAction.map({ $0.at <= cue.at }) ?? true else { throw Error.invalidContent }
                }
                if step.showParts && !recombined {
                    guard step.showWhole, bowl.count == observe.knownPart else { throw Error.invalidContent }
                    showedParts = true
                }
            }
        }
        guard showedParts, recombined, steps.last?.showParts == true else { throw Error.invalidContent }
    }

    private func validCaption(_ caption: Caption) -> Bool {
        guard !caption.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard let clip = caption.clipID else { return true }
        return !synthetic && Self.validID(clip) && clip.hasPrefix(id + "-")
            && (!clip.hasPrefix(id + "-check-") || clip == id + "-check-success")
    }

    public static func validID(_ id: String) -> Bool {
        !id.isEmpty && id.utf8.count <= 80
            && id.utf8.allSatisfy { (97...122).contains($0) || (48...57).contains($0) || $0 == 45 }
    }
}
