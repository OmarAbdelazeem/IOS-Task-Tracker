import SwiftUI
import SwiftData
import Foundation

@main
@MainActor
struct FirstAppApp: App {
    private let modelContainer: ModelContainer
    private let goalService: any GoalServicing

    init() {
        let processInfo = ProcessInfo.processInfo
        let arguments = processInfo.arguments

        let isRunningTests =
            arguments.contains(
                "--ui-testing"
            ) ||
            processInfo.environment[
                "XCTestConfigurationFilePath"
            ] != nil

        let isPerformanceTesting =
            arguments.contains(
                "--performance-testing"
            )

        let schema = Schema(
            versionedSchema: GoalSchemaV2.self
        )

        let configuration = ModelConfiguration(
            isStoredInMemoryOnly:
                isRunningTests ||
                isPerformanceTesting
        )

        do {
            let container = try ModelContainer(
                for: schema,
                migrationPlan: GoalMigrationPlan.self,
                configurations: [configuration]
            )

#if DEBUG
            if isPerformanceTesting {
                try PerformanceDataSeeder.seedGoals(
                    count: 5_000,
                    into: container.mainContext
                )
            }
#endif

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
