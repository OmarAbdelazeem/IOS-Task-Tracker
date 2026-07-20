struct GoalStatistics {
    let goals: [Goal]

    var total: Int {
        goals.count
    }

    var completed: Int {
        goals.filter { goal in
            goal.isCompleted
        }
        .count
    }

    var active: Int {
        total - completed
    }

    var completionPercentage: Int {
        guard total > 0 else {
            return 0
        }

        let percentage =
            Double(completed) /
            Double(total) *
            100

        return Int(percentage.rounded())
    }

    var averageProgress: Int {
        guard !goals.isEmpty else {
            return 0
        }

        let totalProgress = goals.reduce(0.0) {
            partialResult,
            goal in

            partialResult + goal.progress
        }

        let average =
            totalProgress /
            Double(goals.count) *
            100

        return Int(average.rounded())
    }
}
