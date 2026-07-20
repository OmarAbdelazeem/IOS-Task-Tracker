import Foundation
import SwiftData

@MainActor
protocol GoalRepository {
    func add(_ goal: Goal) throws

    func update(
        _ goal: Goal,
        with draft: GoalDraft
    ) throws

    func delete(_ goals: [Goal]) throws
}

enum GoalRepositoryError: LocalizedError {
    case invalidDraft(String)

    var errorDescription: String? {
        switch self {
        case .invalidDraft(let message):
            return message
        }
    }
}

@MainActor
final class SwiftDataGoalRepository: GoalRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func add(_ goal: Goal) throws {
        modelContext.insert(goal)
        try saveChanges()
    }

    func update(
        _ goal: Goal,
        with draft: GoalDraft
    ) throws {
        guard draft.apply(to: goal) else {
            let message =
                draft.validationMessage.map {
                    String(localized: $0)
                }
                ?? String(
                    localized:
                        "The goal contains invalid values."
                )

            throw GoalRepositoryError.invalidDraft(
                message
            )
        }

        try saveChanges()
    }

    func delete(_ goals: [Goal]) throws {
        for goal in goals {
            modelContext.delete(goal)
        }

        try saveChanges()
    }

    private func saveChanges() throws {
        do {
            if modelContext.hasChanges {
                try modelContext.save()
            }
        } catch {
            modelContext.rollback()
            throw error
        }
    }
}

#if DEBUG
@MainActor
final class PreviewGoalRepository: GoalRepository {
    func add(_ goal: Goal) throws {
        // Preview-only implementation.
    }

    func update(
        _ goal: Goal,
        with draft: GoalDraft
    ) throws {
        _ = draft.apply(to: goal)
    }

    func delete(_ goals: [Goal]) throws {
        // Preview-only implementation.
    }
}
#endif
