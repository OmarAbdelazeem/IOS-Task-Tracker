import SwiftUI

struct AddGoalView: View {
    @State private var draft =
        GoalDraft()

    let service: any GoalServicing

    @Environment(\.dismiss)
    private var dismiss

    @State private var isSaving = false

    @State private var isShowingError =
        false

    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            GoalFormView(
                draft: $draft,
                mode: .create
            )
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(
                .inline
            )
            .toolbar {
                ToolbarItem(
                    placement:
                        .cancellationAction
                ) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                    .accessibilityIdentifier(
                        "cancelAddGoalButton"
                    )
                }

                ToolbarItem(
                    placement:
                        .confirmationAction
                ) {
                    Button("Add") {
                        Task {
                            await addGoal()
                        }
                    }
                    .disabled(
                        !draft.isValid ||
                        isSaving
                    )
                    .accessibilityIdentifier(
                        "confirmAddGoalButton"
                    )
                }
            }
            .alert(
                "Couldn’t Add Goal",
                isPresented:
                    $isShowingError
            ) {
                Button("OK", role: .cancel) {
                    // Dismiss the alert.
                }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func addGoal() async {
        isSaving = true
        defer {
            isSaving = false
        }

        do {
            try await service.add(
                draft: draft
            )

            dismiss()
        } catch {
            errorMessage =
                error.localizedDescription

            isShowingError = true
        }
    }
}

#Preview {
    AddGoalView(
        service: PreviewGoalService()
    )
}
