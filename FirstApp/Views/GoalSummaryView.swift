import SwiftUI

struct GoalSummaryView: View {
    let title: String
    let count: Int
    let target: Int

    private var isTargetReached: Bool {
        target > 0 && count >= target
    }

    private var progress: Double {
        guard target > 0 else {
            return 0
        }

        return min(
            Double(count) / Double(target),
            1.0
        )
    }

    private var statusMessage:
        LocalizedStringResource {

        if target <= 0 {
            return "Invalid target"
        }

        if count == 0 {
            return "Start tapping!"
        }

        if count < target {
            return "\(target - count) remaining"
        }

        if count < target * 2 {
            return "Target reached!"
        }

        return "Double target reached!"
    }

    private var accessibilitySummary:
        LocalizedStringResource {

        if target <= 0 {
            return """
            Current count \(count), invalid target
            """
        }

        if isTargetReached {
            return """
            Current count \(count), target \(target), completed
            """
        }

        let remaining = max(
            target - count,
            0
        )

        return """
        Current count \(count), target \(target), \
        \(remaining) remaining
        """
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
            .accessibilityHidden(true)

            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Text("\(count) taps")
                .font(
                    .system(
                        .largeTitle,
                        design: .rounded,
                        weight: .bold
                    )
                )
                .monospacedDigit()
                .multilineTextAlignment(.center)
                .contentTransition(
                    .numericText(
                        value: Double(count)
                    )
                )
                .animation(
                    .snappy,
                    value: count
                )

            Text("Target: \(target)")
                .foregroundStyle(.secondary)

            ProgressView(value: progress)
                .frame(maxWidth: 300)

            HStack(spacing: 8) {
                Image(
                    systemName: isTargetReached
                        ? "checkmark.circle.fill"
                        : "hourglass"
                )

                Text(statusMessage)
            }
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(
            Text(accessibilitySummary)
        )
    }
}

#Preview("Normal") {
    GoalSummaryView(
        title: "Study iOS",
        count: 3,
        target: 8
    )
    .padding()
}

#Preview("Accessibility Text") {
    ScrollView {
        GoalSummaryView(
            title: "A Goal With a Much Longer Title",
            count: 3,
            target: 8
        )
        .padding()
    }
    .dynamicTypeSize(.accessibility3)
}

#Preview("Dark Mode") {
    GoalSummaryView(
        title: "Study iOS",
        count: 8,
        target: 8
    )
    .padding()
    .preferredColorScheme(.dark)
}
