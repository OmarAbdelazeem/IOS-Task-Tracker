import Foundation

struct GoalDraft: Equatable {
    var title: String
    var target: Int
    var count: Int

    init(
        title: String = "",
        target: Int = 5,
        count: Int = 0
    ) {
        self.title = title
        self.target = target
        self.count = count
    }

    init(goal: Goal) {
        title = goal.title
        target = goal.target
        count = goal.count
    }

    var trimmedTitle: String {
        title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    var validationMessage: String? {
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

    var statusMessage: String {
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
            target: target
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

        return true
    }
}
