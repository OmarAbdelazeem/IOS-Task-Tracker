import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            TrackerView()
                .tabItem {
                    Label(
                        "Tracker",
                        systemImage: "target"
                    )
                }

            DashboardView()
                .tabItem {
                    Label(
                        "Dashboard",
                        systemImage: "chart.bar.fill"
                    )
                }

            GoalsListView()
                .tabItem {
                    Label(
                        "Goals",
                        systemImage: "list.bullet"
                    )
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: Goal.self,
            inMemory: true
        )
}
