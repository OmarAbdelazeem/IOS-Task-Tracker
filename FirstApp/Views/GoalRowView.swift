import SwiftUI
import SwiftData

struct GoalRowView: View {
    let goal: Goal

    private var accessibilityStatus: String {
        if goal.isCompleted {
            return "Completed"
        }

        return "\(max(goal.target - goal.count, 0)) remaining"
    }

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
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                ProgressView(value: goal.progress)

                Text("\(goal.count) of \(goal.target)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(goal.title)
        .accessibilityValue(
            "\(goal.count) of \(goal.target). \(accessibilityStatus)"
        )
    }
}

#Preview("Accessibility Text") {
    List {
        GoalRowView(
            goal: Goal(
                title: "Finish the SwiftUI accessibility course",
                count: 3,
                target: 10
            )
        )
    }
    .dynamicTypeSize(.accessibility3)
    .modelContainer(
        for: Goal.self,
        inMemory: true
    )
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
