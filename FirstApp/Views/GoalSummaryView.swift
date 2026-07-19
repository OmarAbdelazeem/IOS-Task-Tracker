import SwiftUI

struct GoalSummaryView: View {
    let title: String
    let count: Int
    let target: Int

    private var isTargetReached: Bool {
        count >= target
    }

    private var progress: Double {
        let currentValue = Double(count)
        let targetValue = Double(target)

        return min(currentValue / targetValue, 1.0)
    }

    private var statusMessage: String {
        if count == 0 {
            return "Start tapping!"
        } else if count < target {
            return "\(target - count) remaining"
        } else if count < target * 2 {
            return "Target reached!"
        } else {
            return "Double target reached!"
        }
    }

    var body: some View {
        VStack(spacing: 22) {
            Image(
                systemName: isTargetReached
                    ? "checkmark.circle.fill"
                    : "target"
            )
            .font(.system(size: 65))
            .foregroundStyle(
                isTargetReached
                    ? Color.green
                    : Color.primary
            )
            .scaleEffect(isTargetReached ? 1.1 : 1.0)
            .animation(.snappy, value: isTargetReached)

            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            VStack(spacing: 2) {
                Text("\(count)")
                    .font(
                        .system(
                            size: 72,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .monospacedDigit()
                    .contentTransition(
                        .numericText(value: Double(count))
                    )

                Text(count == 1 ? "tap" : "taps")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .animation(.snappy, value: count)

            Text("Target: \(target)")
                .foregroundStyle(.secondary)

            ProgressView(value: progress)
                .frame(maxWidth: 300)

            Text(statusMessage)
                .font(.headline)
                .foregroundStyle(
                    isTargetReached
                        ? Color.green
                        : Color.primary
                )
                .animation(
                    .easeInOut,
                    value: isTargetReached
                )
        }
    }
}

#Preview("In Progress") {
    GoalSummaryView(
        title: "Reading Goal",
        count: 3,
        target: 8
    )
    .padding()
}

#Preview("Target Reached") {
    GoalSummaryView(
        title: "Exercise Goal",
        count: 10,
        target: 10
    )
    .padding()
}
