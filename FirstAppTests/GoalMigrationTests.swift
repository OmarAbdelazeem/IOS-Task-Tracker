import Foundation
import SwiftData
import Testing

@testable import FirstApp

@MainActor
struct GoalMigrationTests {
    @Test(
        "Migrates a V1 goal to V2"
    )
    func migratesV1GoalToV2() throws {
        let testDirectory =
            FileManager.default
                .temporaryDirectory
                .appendingPathComponent(
                    UUID().uuidString,
                    isDirectory: true
                )

        try FileManager.default
            .createDirectory(
                at: testDirectory,
                withIntermediateDirectories:
                    true
            )

        defer {
            try? FileManager.default
                .removeItem(
                    at: testDirectory
                )
        }

        let storeURL =
            testDirectory
                .appendingPathComponent(
                    "Migration.store"
                )

        do {
            let v1Schema = Schema(
                versionedSchema:
                    GoalSchemaV1.self
            )

            let v1Configuration =
                ModelConfiguration(
                    "MigrationTest",
                    schema: v1Schema,
                    url: storeURL,
                    allowsSave: true,
                    cloudKitDatabase: .none
                )

            let v1Container =
                try ModelContainer(
                    for: v1Schema,
                    migrationPlan: nil,
                    configurations: [
                        v1Configuration
                    ]
                )

            let v1Context =
                ModelContext(v1Container)

            let oldGoal =
                GoalSchemaV1.Goal(
                    title: "Old Goal",
                    count: 3,
                    target: 10,
                    reminderTime:
                        GoalDraft
                            .defaultReminderTime,
                    notificationIdentifier:
                        "old-reminder"
                )

            v1Context.insert(oldGoal)
            try v1Context.save()
        }

        do {
            let v2Schema = Schema(
                versionedSchema:
                    GoalSchemaV2.self
            )

            let v2Configuration =
                ModelConfiguration(
                    "MigrationTest",
                    schema: v2Schema,
                    url: storeURL,
                    allowsSave: true,
                    cloudKitDatabase: .none
                )

            let v2Container =
                try ModelContainer(
                    for: v2Schema,
                    migrationPlan:
                        GoalMigrationPlan.self,
                    configurations: [
                        v2Configuration
                    ]
                )

            let v2Context =
                ModelContext(v2Container)

            let migratedGoals =
                try v2Context.fetch(
                    FetchDescriptor<
                        GoalSchemaV2.Goal
                    >()
                )

            #expect(
                migratedGoals.count == 1
            )

            let migratedGoal =
                try #require(
                    migratedGoals.first
                )

            #expect(
                migratedGoal.title ==
                "Old Goal"
            )

            #expect(
                migratedGoal.count == 3
            )

            #expect(
                migratedGoal.target == 10
            )

            #expect(
                migratedGoal
                    .notificationIdentifier
                == "old-reminder"
            )

            #expect(
                migratedGoal.notes == nil
            )
        }
    }
}
