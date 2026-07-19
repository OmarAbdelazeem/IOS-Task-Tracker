import SwiftUI

struct ContentView: View {
    @AppStorage("appTitle")
    private var appTitle = "My Goal Tracker"

    @AppStorage("targetCount")
    private var targetCount = 5

    @AppStorage("tapCount")
    private var tapCount = 0

    @State private var isShowingSettings = false
    @State private var isShowingResetAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                GoalSummaryView(
                    title: appTitle,
                    count: tapCount,
                    target: targetCount
                )

                CounterControlsView(
                    count: tapCount,
                    onDecrease: decreaseCount,
                    onIncrease: increaseCount,
                    onResetRequest: {
                        isShowingResetAlert = true
                    }
                )
            }
            .padding()
            .navigationTitle("Goal Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView(
                    appTitle: $appTitle,
                    targetCount: $targetCount
                )
            }
            .alert(
                "Reset progress?",
                isPresented: $isShowingResetAlert
            ) {
                Button("Cancel", role: .cancel) {
                    // Keep the current count.
                }

                Button("Reset", role: .destructive) {
                    resetCount()
                }
            } message: {
                Text(
                    "Your count of \(tapCount) will be permanently reset to zero."
                )
            }
            .sensoryFeedback(
                .success,
                trigger: tapCount
            ) { oldValue, newValue in
                oldValue < targetCount &&
                newValue >= targetCount
            }
        }
    }

    private func increaseCount() {
        tapCount += 1
    }

    private func decreaseCount() {
        if tapCount > 0 {
            tapCount -= 1
        }
    }

    private func resetCount() {
        tapCount = 0
    }
}

// MARK: - Goal summary

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

// MARK: - Counter controls

struct CounterControlsView: View {
    let count: Int

    let onDecrease: () -> Void
    let onIncrease: () -> Void
    let onResetRequest: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Button {
                    onDecrease()
                } label: {
                    Label("Remove", systemImage: "minus")
                }
                .buttonStyle(.bordered)
                .disabled(count == 0)

                Button {
                    onIncrease()
                } label: {
                    Label("Add", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }

            Button("Reset Count", role: .destructive) {
                onResetRequest()
            }
            .disabled(count == 0)
        }
    }
}

// MARK: - Settings

struct SettingsView: View {
    @Binding var appTitle: String
    @Binding var targetCount: Int

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Application") {
                    TextField(
                        "Enter a title",
                        text: $appTitle
                    )
                }

                Section("Goal") {
                    Stepper(
                        "Target: \(targetCount)",
                        value: $targetCount,
                        in: 1...20
                    )
                }

                Section {
                    Text(
                        "Your progress is calculated using the selected target."
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
