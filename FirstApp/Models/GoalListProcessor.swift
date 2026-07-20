import Foundation

enum GoalFilter: CaseIterable, Identifiable {
    case all
    case active
    case completed

    var id: Self {
        self
    }

    var title: LocalizedStringResource {
        switch self {
        case .all:
            return "All"

        case .active:
            return "Active"

        case .completed:
            return "Completed"
        }
    }
}

enum GoalSortOption: CaseIterable, Identifiable {
    case name
    case progress
    case target

    var id: Self {
        self
    }

    var title: LocalizedStringResource {
        switch self {
        case .name:
            return "Name"

        case .progress:
            return "Progress"

        case .target:
            return "Target"
        }
    }
}

struct GoalListProcessor {
    let goals: [Goal]
    let searchText: String
    let filter: GoalFilter
    let sort: GoalSortOption

    var results: [Goal] {
        let trimmedSearchText =
            searchText.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let searchedGoals: [Goal]

        if trimmedSearchText.isEmpty {
            searchedGoals = goals
        } else {
            searchedGoals = goals.filter { goal in
                goal.title.localizedCaseInsensitiveContains(
                    trimmedSearchText
                )
            }
        }

        let filteredGoals =
            searchedGoals.filter { goal in
                switch filter {
                case .all:
                    return true

                case .active:
                    return !goal.isCompleted

                case .completed:
                    return goal.isCompleted
                }
            }

        switch sort {
        case .name:
            return filteredGoals.sorted {
                first,
                second in

                first.title
                    .localizedCaseInsensitiveCompare(
                        second.title
                    ) == .orderedAscending
            }

        case .progress:
            return filteredGoals.sorted {
                first,
                second in

                if first.progress ==
                    second.progress {

                    return first.title
                        .localizedCaseInsensitiveCompare(
                            second.title
                        ) == .orderedAscending
                }

                return first.progress >
                    second.progress
            }

        case .target:
            return filteredGoals.sorted {
                first,
                second in

                if first.target ==
                    second.target {

                    return first.title
                        .localizedCaseInsensitiveCompare(
                            second.title
                        ) == .orderedAscending
                }

                return first.target <
                    second.target
            }
        }
    }
}
