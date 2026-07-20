import SwiftUI

enum GoalFormMode {
    case create
    case edit

    var showsProgress: Bool {
        self == .edit
    }

    var titleFieldIdentifier: String {
        switch self {
        case .create:
            return "goalTitleField"

        case .edit:
            return "goalDetailTitleField"
        }
    }
}

struct GoalFormView: View {
    @Binding var draft: GoalDraft

    let mode: GoalFormMode

    var body: some View {
        Form {
            if mode.showsProgress {
                summarySection
            }

            detailsSection
            reminderSection

            if mode.showsProgress {
                progressSection
            }

            if let validationMessage =
                draft.validationMessage {

                validationSection(
                    message: validationMessage
                )
            }
        }
    }

    private var summarySection: some View {
        Section {
            VStack(spacing: 16) {
                Image(
                    systemName: draft.isCompleted
                        ? "checkmark.circle.fill"
                        : "target"
                )
                .font(.system(size: 60))
                .foregroundStyle(
                    draft.isCompleted
                        ? Color.green
                        : Color.primary
                )
                .accessibilityHidden(true)

                Text(
                    "\(draft.count) of \(draft.target)"
                )
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
                        value: Double(draft.count)
                    )
                )

                ProgressView(value: draft.progress)

                HStack(spacing: 8) {
                    Image(
                        systemName: draft.isCompleted
                            ? "checkmark.circle.fill"
                            : "hourglass"
                    )

                    Text(draft.statusMessage)
                }
                .font(.headline)
                .foregroundStyle(
                    draft.isCompleted
                        ? Color.green
                        : Color.secondary
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .animation(
                .snappy,
                value: draft.count
            )
            .accessibilityElement(
                children: .ignore
            )
            .accessibilityLabel("Goal progress")
            .accessibilityValue(
                "\(draft.count) of \(draft.target). \(draft.statusMessage)"
            )
        }
    }

    private var detailsSection: some View {
        Section("Details") {
            TextField(
                "Goal name",
                text: $draft.title
            )
            .textInputAutocapitalization(.words)
            .accessibilityIdentifier(
                mode.titleFieldIdentifier
            )

            Stepper(
                "Target: \(draft.target)",
                value: $draft.target,
                in: 1...100
            )
            .accessibilityIdentifier(
                mode == .create
                    ? "goalTargetStepper"
                    : "goalDetailTargetStepper"
            )
        }
    }

    private var progressSection: some View {
        Section("Progress") {
            Stepper(
                "Current count: \(draft.count)",
                value: $draft.count,
                in: 0...1000
            )
            .accessibilityIdentifier(
                "goalDetailCountStepper"
            )

            ViewThatFits(in: .horizontal) {
                HStack {
                    decreaseButton

                    Spacer()

                    increaseButton
                }

                VStack(spacing: 12) {
                    decreaseButton
                    increaseButton
                }
            }
        }
    }

    private var reminderSection: some View {
        Section("Reminder") {
            Toggle(
                "Daily reminder",
                isOn: $draft.reminderEnabled
            )
            .accessibilityIdentifier(
                "goalReminderToggle"
            )

            if draft.reminderEnabled {
                DatePicker(
                    "Reminder time",
                    selection: $draft.reminderTime,
                    displayedComponents: .hourAndMinute
                )
                .accessibilityIdentifier(
                    "goalReminderTimePicker"
                )

                Text(
                    "The reminder repeats every day at the selected time."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
    }

    private func validationSection(
        message: String
    ) -> some View {
        Section {
            Label(
                message,
                systemImage:
                    "exclamationmark.triangle.fill"
            )
            .font(.footnote)
            .foregroundStyle(.red)
        }
    }

    private var decreaseButton: some View {
        Button {
            if draft.count > 0 {
                draft.count -= 1
            }
        } label: {
            Label(
                "Remove",
                systemImage: "minus"
            )
            .frame(maxWidth: .infinity)
        }
        .disabled(draft.count == 0)
        .accessibilityHint(
            "Decreases the current count by one"
        )
    }

    private var increaseButton: some View {
        Button {
            draft.count += 1
        } label: {
            Label(
                "Add",
                systemImage: "plus"
            )
            .frame(maxWidth: .infinity)
        }
        .accessibilityIdentifier(
            "goalDetailIncreaseButton"
        )
        .accessibilityHint(
            "Increases the current count by one"
        )
    }
}

private struct GoalFormPreview: View {
    @State private var draft = GoalDraft(
        title: "Study iOS",
        target: 10,
        count: 4
    )

    let mode: GoalFormMode

    var body: some View {
        NavigationStack {
            GoalFormView(
                draft: $draft,
                mode: mode
            )
        }
    }
}

#Preview("Create") {
    GoalFormPreview(mode: .create)
}

#Preview("Edit") {
    GoalFormPreview(mode: .edit)
}
