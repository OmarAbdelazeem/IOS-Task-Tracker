import SwiftUI
import SwiftData
import Foundation

@main
@MainActor
struct FirstAppApp: App {
    private let modelContainer: ModelContainer
    private let goalService: any GoalServicing

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

            let repository =
                SwiftDataGoalRepository(
                    modelContext:
                        container.mainContext
                )

            let reminderScheduler =
                UserNotificationGoalReminderScheduler()

            goalService = DefaultGoalService(
                repository: repository,
                reminderScheduler:
                    reminderScheduler
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
                goalService: goalService
            )
        }
        .modelContainer(modelContainer)
    }
}
