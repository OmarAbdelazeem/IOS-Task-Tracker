import SwiftUI
import SwiftData

struct GoalDetailView: View {
    let goal: Goal
    let service: any GoalServicing

    @State private var draft: GoalDraft

    @Environment(\.dismiss)
    private var dismiss

    @State private var isSaving = false
    @State private var isShowingSaveError = false
    @State private var saveErrorMessage = ""

    init(
        goal: Goal,
        service: any GoalServicing
    ) {
        self.goal = goal
        self.service = service

        _draft = State(
            initialValue:
                GoalDraft(goal: goal)
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
                .disabled(isSaving)
            }

            ToolbarItem(
                placement: .confirmationAction
            ) {
                Button("Save") {
                    Task {
                        await saveAndClose()
                    }
                }
                .disabled(
                    !draft.isValid ||
                    !hasChanges ||
                    isSaving
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

    private func saveAndClose() async {
        isSaving = true
        defer {
            isSaving = false
        }

        do {
            try await service.update(
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
            service:
                PreviewGoalService()
        )
    }
    .modelContainer(
        for: Goal.self,
        inMemory: true
    )
}
