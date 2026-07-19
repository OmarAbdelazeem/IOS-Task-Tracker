import SwiftUI

struct GoalRowView: View {
    let goal: Goal

    var body: some View {
        HStack(spacing: 14) {
            Image(
                systemName: goal.isCompleted
                    ? "checkmark.circle.fill"
                    : "circle"
            )
            .font(.title2)
            .foregroundStyle(
                goal.isCompleted
                    ? Color.green
                    : Color.secondary
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(goal.title)
                    .font(.headline)

                ProgressView(value: goal.progress)

                Text("\(goal.count) of \(goal.target)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview("In Progress") {
    GoalRowView(
        goal: Goal(
            title: "Read",
            count: 6,
            target: 10
        )
    )
    .padding()
}

#Preview("Completed") {
    GoalRowView(
        goal: Goal(
            title: "Exercise",
            count: 5,
            target: 5
        )
    )
    .padding()
}
