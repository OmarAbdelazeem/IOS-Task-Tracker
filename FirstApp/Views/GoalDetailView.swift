import SwiftUI
import SwiftData

struct GoalDetailView: View {
    let goal: Goal
    let repository: any GoalRepository

    @State private var draft: GoalDraft

    @Environment(\.dismiss)
    private var dismiss

    @State private var isShowingSaveError = false
    @State private var saveErrorMessage = ""

    init(
        goal: Goal,
        repository: any GoalRepository
    ) {
        self.goal = goal
        self.repository = repository

        _draft = State(
            initialValue: GoalDraft(goal: goal)
        )
    }

    private var hasChanges: Bool {
        draft != GoalDraft(goal: goal)
    }

    var body: some View {
        GoalFormView(
            draft: $draft,
            mode: .edit
        )
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
                    !draft.isValid ||
                    !hasChanges
                )
                .accessibilityIdentifier(
                    "saveGoalButton"
                )
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

    private func saveAndClose() {
        do {
            try repository.update(
                goal,
                with: draft
            )

            dismiss()
        } catch {
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
                count: 4,
                target: 10
            ),
            repository: PreviewGoalRepository()
        )
    }
    .modelContainer(
        for: Goal.self,
        inMemory: true
    )
}
