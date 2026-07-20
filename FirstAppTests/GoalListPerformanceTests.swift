import XCTest

@testable import FirstApp

final class GoalListPerformanceTests:
    XCTestCase {

    func testFilteringAndSortingTenThousandGoals() {
        let goals = makeGoals(
            count: 10_000
        )

        var resultCount = 0

        measure(
            metrics: [
                XCTClockMetric(),
                XCTCPUMetric()
            ]
        ) {
            let processor =
                GoalListProcessor(
                    goals: goals,
                    searchText:
                        "Goal 9",
                    filter: .active,
                    sort: .progress
                )

            resultCount =
                processor.results.count
        }

        XCTAssertGreaterThan(
            resultCount,
            0
        )
    }

    private func makeGoals(
        count: Int
    ) -> [Goal] {
        (0..<count).map { index in
            let target =
                (index % 20) + 1

            let currentCount =
                index.isMultiple(of: 5)
                ? target
                : index % target

            return Goal(
                title:
                    "Goal \(index + 1)",
                count: currentCount,
                target: target
            )
        }
    }
}
