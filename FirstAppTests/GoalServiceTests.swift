import Foundation
import Testing

@testable import FirstApp

@MainActor
struct GoalServiceTests {
    @Test(
        "Adding a reminder goal schedules it"
    )
    func addsReminderGoal() async throws {
        let repository =
            GoalRepositorySpy()

        let scheduler =
            ReminderSchedulerSpy()

        let service = DefaultGoalService(
            repository: repository,
            reminderScheduler: scheduler
        )

        let reminderTime =
            GoalDraft.defaultReminderTime

        let draft = GoalDraft(
            title: "Meditate",
            target: 5,
            reminderEnabled: true,
            reminderTime: reminderTime
        )

        try await service.add(
            draft: draft
        )

        #expect(repository.addedGoal != nil)

        #expect(
            repository.addedGoal?
                .notificationIdentifier
            != nil
        )

        #expect(
            scheduler.scheduled.count == 1
        )

        #expect(
            scheduler.scheduled.first?.title
            == "Meditate"
        )
    }

    @Test(
        "Disabling a reminder cancels it"
    )
    func disablesReminder() async throws {
        let repository =
            GoalRepositorySpy()

        let scheduler =
            ReminderSchedulerSpy()

        let service = DefaultGoalService(
            repository: repository,
            reminderScheduler: scheduler
        )

        let identifier = "test-reminder"

        let goal = Goal(
            title: "Read",
            count: 1,
            target: 5,
            reminderTime:
                GoalDraft.defaultReminderTime,
            notificationIdentifier:
                identifier
        )

        var draft = GoalDraft(
            goal: goal
        )

        draft.reminderEnabled = false

        try await service.update(
            goal,
            with: draft
        )

        #expect(goal.reminderTime == nil)

        #expect(
            goal.notificationIdentifier
            == nil
        )

        #expect(
            scheduler.cancelled ==
            [identifier]
        )
    }
}

@MainActor
private final class GoalRepositorySpy:
    GoalRepository {

    var addedGoal: Goal?

    func add(_ goal: Goal) throws {
        addedGoal = goal
    }

    func update(
        _ goal: Goal,
        with draft: GoalDraft
    ) throws {
        guard draft.apply(to: goal) else {
            throw GoalRepositoryError
                .invalidDraft(
                    "Invalid draft"
                )
        }
    }

    func delete(
        _ goals: [Goal]
    ) throws {
        // Test spy.
    }
}

@MainActor
private final class ReminderSchedulerSpy:
    GoalReminderScheduling {

    struct ScheduledReminder {
        let identifier: String
        let title: String
        let time: Date
    }

    var scheduled:
        [ScheduledReminder] = []

    var cancelled: [String] = []

    func scheduleDailyReminder(
        identifier: String,
        title: String,
        time: Date
    ) async throws {
        scheduled.append(
            ScheduledReminder(
                identifier: identifier,
                title: title,
                time: time
            )
        )
    }

    func cancelReminder(
        identifier: String
    ) {
        cancelled.append(identifier)
    }
}
