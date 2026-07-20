import SwiftUI
import SwiftData

struct GoalDetailView: View {
    let goal: Goal

    @State private var draft: GoalDraft

    @Environment(\.modelContext)
    private var modelContext

    @Environment(\.dismiss)
    private var dismiss

    @State private var isShowingSaveError = false
    @State private var saveErrorMessage = ""

    init(goal: Goal) {
        self.goal = goal

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
        guard draft.apply(to: goal) else {
            return
        }

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
                count: 4,
                target: 10
            )
        )
    }
    .modelContainer(
        for: Goal.self,
        inMemory: true
    )
}
