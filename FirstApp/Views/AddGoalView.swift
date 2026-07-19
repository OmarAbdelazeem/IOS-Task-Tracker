import SwiftUI
import Foundation

struct AddGoalView: View {
    @State private var title = ""
    @State private var target = 5

    let onAdd: (Goal) -> Void

    @Environment(\.dismiss)
    private var dismiss

    private var trimmedTitle: String {
        title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Goal") {
                    TextField(
                        "Goal name",
                        text: $title
                    )

                    Stepper(
                        "Target: \(target)",
                        value: $target,
                        in: 1...20
                    )
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
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
                    Button("Add") {
                        addGoal()
                    }
                    .disabled(trimmedTitle.isEmpty)
                }
            }
        }
    }

    private func addGoal() {
        let newGoal = Goal(
            title: trimmedTitle,
            target: target
        )

        onAdd(newGoal)
        dismiss()
    }
}

#Preview {
    AddGoalView { goal in
        print("Added \(goal.title)")
    }
}
