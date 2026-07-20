import SwiftUI
import SwiftData
import Foundation

struct GoalDetailView: View {
    let goal: Goal

    @Environment(\.modelContext)
    private var modelContext

    @Environment(\.dismiss)
    private var dismiss

    @State private var draftTitle: String
    @State private var draftTarget: Int
    @State private var draftCount: Int

    @State private var isShowingSaveError = false
    @State private var saveErrorMessage = ""

    init(goal: Goal) {
        self.goal = goal

        _draftTitle = State(
            initialValue: goal.title
        )

        _draftTarget = State(
            initialValue: goal.target
        )

        _draftCount = State(
            initialValue: goal.count
        )
    }

    private var trimmedTitle: String {
        draftTitle.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    private var progress: Double {
        guard draftTarget > 0 else {
            return 0
        }

        return min(
            Double(draftCount) / Double(draftTarget),
            1.0
        )
    }

    private var isCompleted: Bool {
        draftCount >= draftTarget
    }

    private var statusMessage: String {
        if draftCount == 0 {
            return "Not started"
        } else if draftCount < draftTarget {
            return "\(draftTarget - draftCount) remaining"
        } else {
            return "Goal completed"
        }
    }

    private var hasChanges: Bool {
        trimmedTitle != goal.title ||
        draftTarget != goal.target ||
        draftCount != goal.count
    }

    var body: some View {
        Form {
            Section {
                VStack(spacing: 16) {
                    Image(
                        systemName: isCompleted
                            ? "checkmark.circle.fill"
                            : "target"
                    )
                    .font(.system(size: 60))
                    .foregroundStyle(
                        isCompleted
                            ? Color.green
                            : Color.primary
                    )

                    Text("\(draftCount) of \(draftTarget)")
                        .font(
                            .system(
                                size: 38,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                        .monospacedDigit()
                        .contentTransition(
                            .numericText(
                                value: Double(draftCount)
                            )
                        )

                    ProgressView(value: progress)

                    Text(statusMessage)
                        .font(.headline)
                        .foregroundStyle(
                            isCompleted
                                ? Color.green
                                : Color.secondary
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .animation(
                    .snappy,
                    value: draftCount
                )
            }

            Section("Details") {
                TextField(
                    "Goal name",
                    text: $draftTitle
                )
                .accessibilityIdentifier("goalDetailTitleField")

                Stepper(
                    "Target: \(draftTarget)",
                    value: $draftTarget,
                    in: 1...100
                )
            }

            Section("Progress") {
                Stepper(
                    "Current count: \(draftCount)",
                    value: $draftCount,
                    in: 0...1000
                )

                HStack {
                    Button {
                        decreaseCount()
                    } label: {
                        Label(
                            "Remove",
                            systemImage: "minus"
                        )
                    }
                    .disabled(draftCount == 0)

                    Spacer()

                    Button {
                        increaseCount()
                    } label: {
                        Label(
                            "Add",
                            systemImage: "plus"
                        )
                    }
                    .accessibilityIdentifier("goalDetailIncreaseButton")
                }
            }
        }
        .navigationTitle("Goal Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(
                placement: .cancellationAction
            ) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(
                placement: .confirmationAction
            ) {
                Button("Save") {
                    saveAndClose()
                }
                .disabled(
                    trimmedTitle.isEmpty ||
                    !hasChanges
                )
                .accessibilityIdentifier("saveGoalButton")
            }
        }
        .alert(
            "Couldn’t Save Goal",
            isPresented: $isShowingSaveError
        ) {
            Button("OK", role: .cancel) {
                // Dismiss the alert.
            }
        } message: {
            Text(saveErrorMessage)
        }
    }

    private func increaseCount() {
        draftCount += 1
    }

    private func decreaseCount() {
        if draftCount > 0 {
            draftCount -= 1
        }
    }

    private func saveAndClose() {
        goal.title = trimmedTitle
        goal.target = draftTarget
        goal.count = draftCount

        do {
            if modelContext.hasChanges {
                try modelContext.save()
            }

            dismiss()
        } catch {
            modelContext.rollback()

            saveErrorMessage =
                error.localizedDescription

            isShowingSaveError = true
        }
    }
}

#Preview {
    NavigationStack {
        GoalDetailView(
            goal: Goal(
                title: "Study iOS",
                count: 6,
                target: 10
            )
        )
    }
    .modelContainer(
        for: Goal.self,
        inMemory: true
    )
}
