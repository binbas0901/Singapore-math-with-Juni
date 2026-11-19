public enum NumberBond {
    public static func missingPart(whole: Int, known: Int) -> Int? {
        guard (0...10).contains(whole), (0...whole).contains(known) else { return nil }
        return whole - known
    }
}
