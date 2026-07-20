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

        let schema = Schema(
            versionedSchema: GoalSchemaV2.self
        )

        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: isRunningUITests
        )

        do {
            let container = try ModelContainer(
                for: schema,
                migrationPlan: GoalMigrationPlan.self,
                configurations: [configuration]
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
