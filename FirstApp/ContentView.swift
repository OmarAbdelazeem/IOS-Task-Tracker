import SwiftUI
import SwiftData
import Foundation

struct ContentView: View {
    let goalService: any GoalServicing

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
                service: goalService
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
        goalService: PreviewGoalService()
    )
    .modelContainer(
        for: Goal.self,
        inMemory: true
    )
}

#Preview("Arabic") {
    ContentView(
        goalService:
            PreviewGoalService()
    )
    .modelContainer(
        for: Goal.self,
        inMemory: true
    )
    .environment(
        \.locale,
        Locale(identifier: "ar")
    )
    .environment(
        \.layoutDirection,
        .rightToLeft
    )
}
