import Foundation

enum SafeParse {
    static func decimal(_ raw: String) -> Double? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return nil
        }
        let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }
}
