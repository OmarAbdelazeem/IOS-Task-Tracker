import SwiftUI
import SwiftData

struct ContentView: View {
    let goalRepository: any GoalRepository

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

            GoalsListView(
                repository: goalRepository
            )
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
    ContentView(
        goalRepository: PreviewGoalRepository()
    )
    .modelContainer(
        for: Goal.self,
        inMemory: true
    )
}
