import Testing
import SwiftData

@testable import FirstApp

struct GoalTests {
    @Test("Calculates progress")
    func calculatesProgress() {
        let goal = Goal(
            title: "Read",
            count: 3,
            target: 5
        )

        #expect(
            abs(goal.progress - 0.6) < 0.0001
        )
    }

    @Test("Caps progress at one hundred percent")
    func capsProgress() {
        let goal = Goal(
            title: "Exercise",
            count: 12,
            target: 5
        )

        #expect(goal.progress == 1.0)
    }

    @Test("Detects a completed goal")
    func detectsCompletion() {
        let completedGoal = Goal(
            title: "Walk",
            count: 5,
            target: 5
        )

        let activeGoal = Goal(
            title: "Study",
            count: 4,
            target: 5
        )

        #expect(completedGoal.isCompleted)
        #expect(!activeGoal.isCompleted)
    }

    @Test("Handles an invalid zero target")
    func handlesZeroTarget() {
        let goal = Goal(
            title: "Invalid",
            count: 0,
            target: 0
        )

        #expect(goal.progress == 0)
        #expect(!goal.isCompleted)
    }
}

struct GoalStatisticsTests {
    @Test("Empty goals produce zero statistics")
    func emptyStatistics() {
        let statistics = GoalStatistics(
            goals: []
        )

        #expect(statistics.total == 0)
        #expect(statistics.active == 0)
        #expect(statistics.completed == 0)
        #expect(
            statistics.completionPercentage == 0
        )
        #expect(statistics.averageProgress == 0)
    }

    @Test("Counts active and completed goals")
    func countsStatuses() {
        let goals = [
            Goal(title: "Read", count: 3, target: 5),
            Goal(title: "Exercise", count: 5, target: 5),
            Goal(title: "Walk", count: 0, target: 5)
        ]

        let statistics = GoalStatistics(goals: goals)

        #expect(statistics.total == 3)
        #expect(statistics.active == 2)
        #expect(statistics.completed == 1)
    }

    @Test("Calculates completion percentage")
    func calculatesCompletionPercentage() {
        let goals = [
            Goal(title: "Goal One", count: 5, target: 5),
            Goal(title: "Goal Two", count: 0, target: 5),
            Goal(title: "Goal Three", count: 0, target: 5)
        ]

        let statistics = GoalStatistics(goals: goals)

        #expect(
            statistics.completionPercentage == 33
        )
    }

    @Test("Calculates average progress")
    func calculatesAverageProgress() {
        let goals = [
            Goal(title: "Goal One", count: 3, target: 5),
            Goal(title: "Goal Two", count: 0, target: 5),
            Goal(title: "Goal Three", count: 5, target: 5)
        ]

        let statistics = GoalStatistics(goals: goals)

        #expect(statistics.averageProgress == 53)
    }
}

struct GoalDraftTests {
    @Test("Rejects an empty title")
    func rejectsEmptyTitle() {
        let draft = GoalDraft(
            title: "   ",
            target: 5
        )

        #expect(!draft.isValid)
        #expect(
            draft.validationMessage ==
            "Enter a goal name."
        )
        #expect(draft.makeGoal() == nil)
    }

    @Test("Creates a trimmed goal")
    func createsTrimmedGoal() {
        let draft = GoalDraft(
            title: "  Study Swift  ",
            target: 8,
            count: 2
        )

        let goal = draft.makeGoal()

        #expect(goal != nil)
        #expect(goal?.title == "Study Swift")
        #expect(goal?.target == 8)
        #expect(goal?.count == 2)
    }

    @Test("Copies values from an existing goal")
    func copiesGoalValues() {
        let goal = Goal(
            title: "Exercise",
            count: 3,
            target: 5
        )

        let draft = GoalDraft(goal: goal)

        #expect(draft.title == "Exercise")
        #expect(draft.count == 3)
        #expect(draft.target == 5)
    }

    @Test("Applies changes to an existing goal")
    func appliesChanges() {
        let goal = Goal(
            title: "Read",
            count: 1,
            target: 5
        )

        let draft = GoalDraft(
            title: "Read Swift",
            target: 10,
            count: 4
        )

        let didApply = draft.apply(to: goal)

        #expect(didApply)
        #expect(goal.title == "Read Swift")
        #expect(goal.target == 10)
        #expect(goal.count == 4)
    }

    @Test("Calculates draft progress")
    func calculatesDraftProgress() {
        let draft = GoalDraft(
            title: "Walk",
            target: 10,
            count: 4
        )

        #expect(
            abs(draft.progress - 0.4) <
            0.0001
        )
        #expect(!draft.isCompleted)
        #expect(
            draft.statusMessage ==
            "6 remaining"
        )
    }
}
