import SwiftUI
import SwiftData
import Foundation

@main
@MainActor
struct FirstAppApp: App {
    private let modelContainer: ModelContainer
    private let goalRepository: any GoalRepository

    init() {
        let isRunningUITests =
            ProcessInfo.processInfo.arguments.contains(
                "--ui-testing"
            )

        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: isRunningUITests
        )

        do {
            let container = try ModelContainer(
                for: Goal.self,
                configurations: configuration
            )

            modelContainer = container

            goalRepository = SwiftDataGoalRepository(
                modelContext: container.mainContext
            )
        } catch {
            fatalError(
                "Could not create SwiftData container: \(error)"
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                goalRepository: goalRepository
            )
        }
        .modelContainer(modelContainer)
    }
}
