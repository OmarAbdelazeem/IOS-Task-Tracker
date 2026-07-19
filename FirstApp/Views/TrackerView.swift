import SwiftUI

struct TrackerView: View {
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
                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
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

#Preview {
    TrackerView()
}
