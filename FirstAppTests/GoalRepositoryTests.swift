import Testing
import SwiftData

@testable import FirstApp

@MainActor
struct GoalRepositoryTests {
    @Test("Adds and persists a goal")
    func addsGoal() throws {
        let system = try makeSystem()

        let goal = Goal(
            title: "Meditate",
            count: 0,
            target: 10
        )

        try system.repository.add(goal)

        let verificationContext = ModelContext(
            system.container
        )

        let savedGoals = try verificationContext.fetch(
            FetchDescriptor<Goal>()
        )

        #expect(savedGoals.count == 1)
        #expect(savedGoals.first?.title == "Meditate")
        #expect(savedGoals.first?.target == 10)
    }

    @Test("Updates and persists a goal")
    func updatesGoal() throws {
        let system = try makeSystem()

        let goal = Goal(
            title: "Read",
            count: 1,
            target: 5
        )

        try system.repository.add(goal)

        let draft = GoalDraft(
            title: "Read Swift",
            target: 10,
            count: 4
        )

        try system.repository.update(
            goal,
            with: draft
        )

        let verificationContext = ModelContext(
            system.container
        )

        let savedGoals = try verificationContext.fetch(
            FetchDescriptor<Goal>()
        )

        #expect(savedGoals.count == 1)
        #expect(
            savedGoals.first?.title ==
            "Read Swift"
        )
        #expect(savedGoals.first?.target == 10)
        #expect(savedGoals.first?.count == 4)
    }

    @Test("Deletes and persists goal removal")
    func deletesGoal() throws {
        let system = try makeSystem()

        let firstGoal = Goal(
            title: "Read",
            target: 5
        )

        let secondGoal = Goal(
            title: "Walk",
            target: 10
        )

        try system.repository.add(firstGoal)
        try system.repository.add(secondGoal)

        try system.repository.delete(
            [firstGoal]
        )

        let verificationContext = ModelContext(
            system.container
        )

        let savedGoals = try verificationContext.fetch(
            FetchDescriptor<Goal>()
        )

        #expect(savedGoals.count == 1)
        #expect(savedGoals.first?.title == "Walk")
    }

    private func makeSystem() throws -> (
        repository: SwiftDataGoalRepository,
        container: ModelContainer
    ) {
        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: true
        )

        let container = try ModelContainer(
            for: Goal.self,
            configurations: configuration
        )

        let repository = SwiftDataGoalRepository(
            modelContext: container.mainContext
        )

        return (
            repository: repository,
            container: container
        )
    }
}
