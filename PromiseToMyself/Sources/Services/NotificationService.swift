import UserNotifications
import Foundation

enum NotificationService {
    private static let promiseNotificationID = "promise-deadline"

    static func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func scheduleDeadlineNotification(for deadline: Date) {
        let content = UNMutableNotificationContent()
        content.title = "自分との約束"
        content.body = "約束の期間が終わりました。守れましたか？"
        content.sound = .default

        var dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: deadline
        )
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: promiseNotificationID,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    static func cancelScheduledNotification() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [promiseNotificationID]
            )
    }
}
