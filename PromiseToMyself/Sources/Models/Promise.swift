import Foundation

struct Promise: Codable, Equatable {
    let content: String
    let deadline: Date

    var isExpired: Bool {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: deadline)
        components.hour = 9
        guard let notificationTime = Calendar.current.date(from: components) else { return false }
        return Date() >= notificationTime
    }

    var daysRemaining: Int {
        let days = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: deadline)
        ).day ?? 0
        return max(0, days)
    }
}
