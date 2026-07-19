import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Query(sort: \Goal.title)
    private var goals: [Goal]

    private var totalGoals: Int {
        goals.count
    }

    private var completedGoals: Int {
        goals.filter { goal in
            goal.isCompleted
        }
        .count
    }

    private var activeGoals: Int {
        totalGoals - completedGoals
    }

    private var completionPercentage: Int {
        guard totalGoals > 0 else {
            return 0
        }

        let percentage =
            Double(completedGoals) /
            Double(totalGoals) *
            100

        return Int(percentage.rounded())
    }

    private var averageProgress: Int {
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

    private var statusData: [GoalStatusData] {
        [
            GoalStatusData(
                name: "Active",
                count: activeGoals
            ),
            GoalStatusData(
                name: "Completed",
                count: completedGoals
            )
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    summaryGrid

                    if goals.isEmpty {
                        ContentUnavailableView(
                            "No Goal Data",
                            systemImage: "chart.bar",
                            description: Text(
                                "Add goals to see your dashboard."
                            )
                        )
                        .padding(.top, 40)
                    } else {
                        completionSection
                        statusChart
                        goalProgressSection
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var summaryGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 16
        ) {
            DashboardCard(
                title: "Total",
                value: "\(totalGoals)",
                systemImage: "target"
            )

            DashboardCard(
                title: "Active",
                value: "\(activeGoals)",
                systemImage: "hourglass"
            )

            DashboardCard(
                title: "Completed",
                value: "\(completedGoals)",
                systemImage: "checkmark.circle.fill"
            )

            DashboardCard(
                title: "Average",
                value: "\(averageProgress)%",
                systemImage: "chart.line.uptrend.xyaxis"
            )
        }
    }

    private var completionSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Overall Completion")
                    .font(.headline)

                Spacer()

                Text("\(completionPercentage)%")
                    .font(.headline)
                    .monospacedDigit()
            }

            ProgressView(
                value: Double(completedGoals),
                total: Double(max(totalGoals, 1))
            )
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(.background.secondary)
        }
    }

    private var statusChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Goal Status")
                .font(.headline)

            Chart(statusData) { item in
                BarMark(
                    x: .value(
                        "Status",
                        item.name
                    ),
                    y: .value(
                        "Goals",
                        item.count
                    )
                )
                .foregroundStyle(
                    by: .value(
                        "Status",
                        item.name
                    )
                )
                .annotation(position: .top) {
                    Text("\(item.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
            .chartYScale(
                domain: 0...max(totalGoals, 1)
            )
            .chartLegend(position: .bottom)
            .frame(height: 240)
            .accessibilityLabel(
                "Goal status chart"
            )
            .accessibilityValue(
                "\(activeGoals) active and \(completedGoals) completed goals"
            )
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(.background.secondary)
        }
    }

    private var goalProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Individual Progress")
                .font(.headline)

            ForEach(goals) { goal in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(goal.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Spacer()

                        Text(
                            "\(goal.count) of \(goal.target)"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    ProgressView(value: goal.progress)
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(.background.secondary)
        }
    }
}

private struct GoalStatusData: Identifiable {
    let id = UUID()

    let name: String
    let count: Int
}

private struct DashboardCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.title2)

            Text(value)
                .font(
                    .system(
                        size: 32,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .monospacedDigit()

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(.background.secondary)
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(
            for: Goal.self,
            inMemory: true
        )
}
