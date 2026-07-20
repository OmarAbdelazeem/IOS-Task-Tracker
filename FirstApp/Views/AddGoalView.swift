import SwiftUI

struct AddGoalView: View {
    @State private var draft = GoalDraft()

    let onAdd: (Goal) -> Void

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        NavigationStack {
            GoalFormView(
                draft: $draft,
                mode: .create
            )
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityIdentifier(
                        "cancelAddGoalButton"
                    )
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button("Add") {
                        addGoal()
                    }
                    .disabled(!draft.isValid)
                    .accessibilityIdentifier(
                        "confirmAddGoalButton"
                    )
                }
            }
        }
    }

    private func addGoal() {
        guard let newGoal = draft.makeGoal() else {
            return
        }

        onAdd(newGoal)
        dismiss()
    }
}

#Preview {
    AddGoalView { goal in
        print("Added \(goal.title)")
    }
}
