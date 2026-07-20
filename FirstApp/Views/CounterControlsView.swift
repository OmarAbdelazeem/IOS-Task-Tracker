import SwiftUI

struct CounterControlsView: View {
    let count: Int

    let onDecrease: () -> Void
    let onIncrease: () -> Void
    let onResetRequest: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    decreaseButton
                    increaseButton
                }

                VStack(spacing: 12) {
                    decreaseButton
                    increaseButton
                }
            }

            Button(
                "Reset Count",
                role: .destructive
            ) {
                onResetRequest()
            }
            .disabled(count == 0)
            .accessibilityHint(
                "Asks for confirmation before resetting"
            )
        }
        .frame(maxWidth: .infinity)
    }

    private var decreaseButton: some View {
        Button {
            onDecrease()
        } label: {
            Label(
                "Remove",
                systemImage: "minus"
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .disabled(count == 0)
        .accessibilityHint(
            "Decreases the count by one"
        )
    }

    private var increaseButton: some View {
        Button {
            onIncrease()
        } label: {
            Label(
                "Add",
                systemImage: "plus"
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .accessibilityHint(
            "Increases the count by one"
        )
    }
}

#Preview("Normal") {
    CounterControlsView(
        count: 3,
        onDecrease: {},
        onIncrease: {},
        onResetRequest: {}
    )
    .padding()
}

#Preview("Large Text") {
    CounterControlsView(
        count: 3,
        onDecrease: {},
        onIncrease: {},
        onResetRequest: {}
    )
    .padding()
    .dynamicTypeSize(.accessibility3)
}
