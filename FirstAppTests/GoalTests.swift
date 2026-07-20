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
