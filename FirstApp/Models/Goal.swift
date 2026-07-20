import Foundation
import SwiftData

@Model
final class Goal {
    var title: String
    var count: Int
    var target: Int

    var reminderTime: Date?
    var notificationIdentifier: String?

    init(
        title: String,
        count: Int = 0,
        target: Int,
        reminderTime: Date? = nil,
        notificationIdentifier: String? = nil
    ) {
        self.title = title
        self.count = count
        self.target = target
        self.reminderTime = reminderTime
        self.notificationIdentifier =
            notificationIdentifier
    }

    var progress: Double {
        guard target > 0 else {
            return 0
        }

        return min(
            Double(count) / Double(target),
            1.0
        )
    }

    var isCompleted: Bool {
        guard target > 0 else {
            return false
        }

        return count >= target
    }
}
