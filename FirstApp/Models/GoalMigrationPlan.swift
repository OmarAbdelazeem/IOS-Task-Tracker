import SwiftData

enum GoalMigrationPlan: SchemaMigrationPlan {
    static var schemas: [
        any VersionedSchema.Type
    ] {
        [
            GoalSchemaV1.self,
            GoalSchemaV2.self
        ]
    }

    static var stages: [MigrationStage] {
        [
            migrateV1ToV2
        ]
    }

    private static let migrateV1ToV2 =
        MigrationStage.lightweight(
            fromVersion: GoalSchemaV1.self,
            toVersion: GoalSchemaV2.self
        )
}
