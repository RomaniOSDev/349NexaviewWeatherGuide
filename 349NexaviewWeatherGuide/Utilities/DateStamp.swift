import Foundation

enum DateStamp {
    static func medium(_ date: Date) -> String {
        DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
    }
}
