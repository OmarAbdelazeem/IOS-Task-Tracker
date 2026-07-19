import SwiftUI

struct CounterControlsView: View {
    let count: Int

    let onDecrease: () -> Void
    let onIncrease: () -> Void
    let onResetRequest: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Button {
                    onDecrease()
                } label: {
                    Label("Remove", systemImage: "minus")
                }
                .buttonStyle(.bordered)
                .disabled(count == 0)

                Button {
                    onIncrease()
                } label: {
                    Label("Add", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }

            Button("Reset Count", role: .destructive) {
                onResetRequest()
            }
            .disabled(count == 0)
        }
    }
}

#Preview("Active Controls") {
    CounterControlsView(
        count: 5,
        onDecrease: {},
        onIncrease: {},
        onResetRequest: {}
    )
    .padding()
}

#Preview("Disabled Controls") {
    CounterControlsView(
        count: 0,
        onDecrease: {},
        onIncrease: {},
        onResetRequest: {}
    )
    .padding()
}
