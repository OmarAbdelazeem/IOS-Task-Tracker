#if DEBUG

import SwiftData

@MainActor
enum PerformanceDataSeeder {
    static func seedGoals(
        count: Int,
        into modelContext: ModelContext
    ) throws {
        guard count > 0 else {
            return
        }

        for index in 0..<count {
            let target =
                (index % 20) + 1

            let currentCount: Int

            if index.isMultiple(of: 5) {
                currentCount = target
            } else {
                currentCount =
                    index % target
            }

            let goal = Goal(
                title:
                    "Performance Goal \(index + 1)",
                count: currentCount,
                target: target,
                notes:
                    index.isMultiple(of: 3)
                    ? "Generated performance data."
                    : nil
            )

            modelContext.insert(goal)
        }

        try modelContext.save()
    }
}

#endif
