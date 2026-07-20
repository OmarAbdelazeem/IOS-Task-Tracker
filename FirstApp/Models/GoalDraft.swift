import Foundation

struct GoalDraft: Equatable {
    var title: String
    var target: Int
    var count: Int

    var reminderEnabled: Bool
    var reminderTime: Date
    var notes: String

    init(
        title: String = "",
        target: Int = 5,
        count: Int = 0,
        reminderEnabled: Bool = false,
        reminderTime: Date = GoalDraft.defaultReminderTime,
        notes: String = ""
    ) {
        self.title = title
        self.target = target
        self.count = count
        self.reminderEnabled = reminderEnabled
        self.reminderTime = reminderTime
        self.notes = notes
    }

    init(goal: Goal) {
        title = goal.title
        target = goal.target
        count = goal.count

        reminderEnabled = goal.reminderTime != nil

        reminderTime =
            goal.reminderTime
            ?? GoalDraft.defaultReminderTime

        notes = goal.notes ?? ""
    }

    static var defaultReminderTime: Date {
        Calendar.current.date(
            bySettingHour: 9,
            minute: 0,
            second: 0,
            of: Date()
        ) ?? Date()
    }

    var trimmedTitle: String {
        title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    var normalizedNotes: String? {
        let trimmedNotes =
            notes.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        return trimmedNotes.isEmpty
            ? nil
            : trimmedNotes
    }

    var validationMessage: LocalizedStringResource? {
        if trimmedTitle.isEmpty {
            return "Enter a goal name."
        }

        if target < 1 {
            return "The target must be at least 1."
        }

        if count < 0 {
            return "The current count cannot be negative."
        }

        return nil
    }

    var isValid: Bool {
        validationMessage == nil
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
        target > 0 && count >= target
    }

    var statusMessage: LocalizedStringResource {
        if target <= 0 {
            return "Invalid target"
        }

        if count == 0 {
            return "Not started"
        }

        if count < target {
            return "\(target - count) remaining"
        }

        return "Goal completed"
    }

    func makeGoal() -> Goal? {
        guard isValid else {
            return nil
        }

        return Goal(
            title: trimmedTitle,
            count: count,
            target: target,
            reminderTime:
                reminderEnabled
                ? reminderTime
                : nil,
            notes: normalizedNotes
        )
    }

    @discardableResult
    func apply(to goal: Goal) -> Bool {
        guard isValid else {
            return false
        }

        goal.title = trimmedTitle
        goal.target = target
        goal.count = count

        goal.reminderTime =
            reminderEnabled
            ? reminderTime
            : nil

        goal.notes = normalizedNotes

        return true
    }
}
