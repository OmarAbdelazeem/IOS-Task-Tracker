import Foundation
import SwiftData

enum GoalSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version {
        Schema.Version(1, 0, 0)
    }

    static var models: [any PersistentModel.Type] {
        [Goal.self]
    }

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
}

enum GoalSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version {
        Schema.Version(2, 0, 0)
    }

    static var models: [any PersistentModel.Type] {
        [Goal.self]
    }

    @Model
    final class Goal {
        var title: String
        var count: Int
        var target: Int

        var reminderTime: Date?
        var notificationIdentifier: String?

        var notes: String?

        init(
            title: String,
            count: Int = 0,
            target: Int,
            reminderTime: Date? = nil,
            notificationIdentifier: String? = nil,
            notes: String? = nil
        ) {
            self.title = title
            self.count = count
            self.target = target
            self.reminderTime = reminderTime
            self.notificationIdentifier =
                notificationIdentifier
            self.notes = notes
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
}

typealias Goal = GoalSchemaV2.Goal
