import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Query(sort: \Goal.title)
    private var goals: [Goal]

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    private var statistics: GoalStatistics {
        GoalStatistics(goals: goals)
    }

    private var statusData: [GoalStatusData] {
        [
            GoalStatusData(
                name: "Active",
                count: statistics.active
            ),
            GoalStatusData(
                name: "Completed",
                count: statistics.completed
            )
        ]
    }

    private var dashboardColumns: [GridItem] {
        if dynamicTypeSize.isAccessibilitySize {
            return [
                GridItem(.flexible())
            ]
        }

        return [
            GridItem(.flexible()),
            GridItem(.flexible())
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
            columns: dashboardColumns,
            spacing: 16
        ) {
            DashboardCard(
                title: "Total",
                value: "\(statistics.total)",
                systemImage: "target"
            )

            DashboardCard(
                title: "Active",
                value: "\(statistics.active)",
                systemImage: "hourglass"
            )

            DashboardCard(
                title: "Completed",
                value: "\(statistics.completed)",
                systemImage: "checkmark.circle.fill"
            )

            DashboardCard(
                title: "Average",
                value: "\(statistics.averageProgress)%",
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

                Text("\(statistics.completionPercentage)%")
                    .font(.headline)
                    .monospacedDigit()
            }

            ProgressView(
                value: Double(statistics.completed),
                total: Double(max(statistics.total, 1))
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
                domain: 0...max(statistics.total, 1)
            )
            .chartLegend(position: .bottom)
            .frame(height: 240)
            .accessibilityLabel(
                "Goal status chart"
            )
            .accessibilityValue(
                "\(statistics.active) active and \(statistics.completed) completed goals"
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
                    ViewThatFits(in: .horizontal) {
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

                        VStack(
                            alignment: .leading,
                            spacing: 4
                        ) {
                            Text(goal.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text(
                                "\(goal.count) of \(goal.target)"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
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
                .multilineTextAlignment(.center)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
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

#Preview("Accessibility Text") {
    DashboardView()
        .dynamicTypeSize(.accessibility3)
        .modelContainer(
            for: Goal.self,
            inMemory: true
        )
}

#Preview("Dark Mode") {
    DashboardView()
        .preferredColorScheme(.dark)
        .modelContainer(
            for: Goal.self,
            inMemory: true
        )
}
