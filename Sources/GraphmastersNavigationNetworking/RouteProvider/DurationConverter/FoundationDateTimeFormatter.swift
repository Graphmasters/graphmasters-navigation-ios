import Foundation
import GraphmastersNavigationCore

public final class FoundationDateTimeFormatter: DateTimeFormatter {
    public init() {}

    public func convert(format: String, time: String) -> Duration {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.defaultDate = Date(timeIntervalSince1970: 0)
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "DE_de")
        let date = formatter.date(from: time)
        return date.map { Duration.companion.fromSeconds(seconds: Int64($0.timeIntervalSince1970)) } ?? Duration.companion.ZERO
    }
}
