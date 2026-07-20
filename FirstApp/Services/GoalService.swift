import Foundation

@MainActor
protocol GoalServicing {
    func add(
        draft: GoalDraft
    ) async throws

    func update(
        _ goal: Goal,
        with draft: GoalDraft
    ) async throws

    func delete(
        _ goals: [Goal]
    ) async throws
}

@MainActor
final class DefaultGoalService:
    GoalServicing {

    private let repository:
        any GoalRepository

    private let reminderScheduler:
        any GoalReminderScheduling

    init(
        repository: any GoalRepository,
        reminderScheduler:
            any GoalReminderScheduling
    ) {
        self.repository = repository

        self.reminderScheduler =
            reminderScheduler
    }

    func add(
        draft: GoalDraft
    ) async throws {
        guard let goal = draft.makeGoal() else {
            throw GoalRepositoryError.invalidDraft(
                draft.validationMessage
                    ?? "The goal is invalid."
            )
        }

        if let reminderTime =
            goal.reminderTime {

            let identifier =
                UUID().uuidString

            goal.notificationIdentifier =
                identifier

            try await reminderScheduler
                .scheduleDailyReminder(
                    identifier: identifier,
                    title: goal.title,
                    time: reminderTime
                )
        }

        do {
            try repository.add(goal)
        } catch {
            if let identifier =
                goal.notificationIdentifier {

                reminderScheduler
                    .cancelReminder(
                        identifier: identifier
                    )
            }

            throw error
        }
    }

    func update(
        _ goal: Goal,
        with draft: GoalDraft
    ) async throws {
        guard draft.isValid else {
            throw GoalRepositoryError.invalidDraft(
                draft.validationMessage
                    ?? "The goal is invalid."
            )
        }

        let previousTitle = goal.title

        let previousReminderTime =
            goal.reminderTime

        let previousIdentifier =
            goal.notificationIdentifier

        if draft.reminderEnabled {
            let identifier =
                previousIdentifier
                ?? UUID().uuidString

            try await reminderScheduler
                .scheduleDailyReminder(
                    identifier: identifier,
                    title: draft.trimmedTitle,
                    time: draft.reminderTime
                )

            goal.notificationIdentifier =
                identifier
        } else {
            goal.notificationIdentifier = nil
        }

        do {
            try repository.update(
                goal,
                with: draft
            )
        } catch {
            await restorePreviousReminder(
                title: previousTitle,
                time: previousReminderTime,
                identifier:
                    previousIdentifier,
                replacementIdentifier:
                    goal.notificationIdentifier
            )

            throw error
        }

        if !draft.reminderEnabled,
           let previousIdentifier {

            reminderScheduler.cancelReminder(
                identifier: previousIdentifier
            )
        }
    }

    func delete(
        _ goals: [Goal]
    ) async throws {
        let identifiers =
            goals.compactMap {
                $0.notificationIdentifier
            }

        try repository.delete(goals)

        for identifier in identifiers {
            reminderScheduler.cancelReminder(
                identifier: identifier
            )
        }
    }

    private func restorePreviousReminder(
        title: String,
        time: Date?,
        identifier: String?,
        replacementIdentifier: String?
    ) async {
        if let replacementIdentifier {
            reminderScheduler.cancelReminder(
                identifier:
                    replacementIdentifier
            )
        }

        guard
            let time,
            let identifier
        else {
            return
        }

        try? await reminderScheduler
            .scheduleDailyReminder(
                identifier: identifier,
                title: title,
                time: time
            )
    }
}

#if DEBUG
@MainActor
final class PreviewGoalService:
    GoalServicing {

    func add(
        draft: GoalDraft
    ) async throws {
        // Preview-only implementation.
    }

    func update(
        _ goal: Goal,
        with draft: GoalDraft
    ) async throws {
        _ = draft.apply(to: goal)
    }

    func delete(
        _ goals: [Goal]
    ) async throws {
        // Preview-only implementation.
    }
}
#endif
