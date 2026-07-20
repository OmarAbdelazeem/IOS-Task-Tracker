import Foundation
import UserNotifications

@MainActor
protocol GoalReminderScheduling {
    func scheduleDailyReminder(
        identifier: String,
        title: String,
        time: Date
    ) async throws

    func cancelReminder(
        identifier: String
    )
}

enum GoalReminderError: LocalizedError {
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return """
            Notifications are disabled. Enable them \
            in the iPhone Settings app to use reminders.
            """
        }
    }
}

@MainActor
final class UserNotificationGoalReminderScheduler:
    GoalReminderScheduling {

    private let notificationCenter:
        UNUserNotificationCenter

    init(
        notificationCenter:
            UNUserNotificationCenter = .current()
    ) {
        self.notificationCenter =
            notificationCenter
    }

    func scheduleDailyReminder(
        identifier: String,
        title: String,
        time: Date
    ) async throws {
        try await ensureAuthorization()

        let content =
            UNMutableNotificationContent()

        content.title = "Goal Reminder"
        content.body = "Make progress on \(title)."
        content.sound = .default

        let components =
            Calendar.current.dateComponents(
                [.hour, .minute],
                from: time
            )

        let trigger =
            UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: true
            )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }

    func cancelReminder(
        identifier: String
    ) {
        notificationCenter
            .removePendingNotificationRequests(
                withIdentifiers: [identifier]
            )
    }

    private func ensureAuthorization()
        async throws {

        let settings =
            await notificationCenter
                .notificationSettings()

        switch settings.authorizationStatus {
        case .authorized,
             .provisional,
             .ephemeral:
            return

        case .notDetermined:
            let granted =
                try await notificationCenter
                    .requestAuthorization(
                        options: [
                            .alert,
                            .sound
                        ]
                    )

            guard granted else {
                throw GoalReminderError
                    .permissionDenied
            }

        case .denied:
            throw GoalReminderError
                .permissionDenied

        @unknown default:
            throw GoalReminderError
                .permissionDenied
        }
    }
}

#if DEBUG
@MainActor
final class PreviewGoalReminderScheduler:
    GoalReminderScheduling {

    func scheduleDailyReminder(
        identifier: String,
        title: String,
        time: Date
    ) async throws {
        // Preview-only implementation.
    }

    func cancelReminder(
        identifier: String
    ) {
        // Preview-only implementation.
    }
}
#endif
