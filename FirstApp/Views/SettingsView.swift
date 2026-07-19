import SwiftUI

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
    SettingsView(
        appTitle: .constant("My Goal Tracker"),
        targetCount: .constant(8)
    )
}
