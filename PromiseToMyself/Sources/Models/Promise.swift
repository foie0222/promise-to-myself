import Foundation

struct Promise: Codable, Equatable {
    let content: String
    let deadline: Date

    var isExpired: Bool {
        Date() >= Calendar.current.startOfDay(for: deadline)
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
