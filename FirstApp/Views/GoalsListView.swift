import SwiftUI
import SwiftData
import Foundation

private enum GoalFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"

    var id: Self {
        self
    }
}

private enum GoalSortOption: String, CaseIterable, Identifiable {
    case name = "Name"
    case progress = "Progress"
    case target = "Target"

    var id: Self {
        self
    }
}

struct GoalsListView: View {
    @Query(sort: \Goal.title)
    private var goals: [Goal]

    @Environment(\.modelContext)
    private var modelContext



    @State private var isShowingAddGoal = false
    @State private var searchText = ""
    @State private var selectedFilter = GoalFilter.all
    @State private var selectedSort = GoalSortOption.name

    @State private var isShowingStorageError = false
    @State private var storageErrorMessage = ""

    private var visibleGoals: [Goal] {
        let trimmedSearchText = searchText.trimmingCharacters(
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

        let filteredGoals = searchedGoals.filter { goal in
            switch selectedFilter {
            case .all:
                return true

            case .active:
                return !goal.isCompleted

            case .completed:
                return goal.isCompleted
            }
        }

        switch selectedSort {
        case .name:
            return filteredGoals.sorted { first, second in
                first.title.localizedCaseInsensitiveCompare(
                    second.title
                ) == .orderedAscending
            }

        case .progress:
            return filteredGoals.sorted { first, second in
                if first.progress == second.progress {
                    return first.title.localizedCaseInsensitiveCompare(
                        second.title
                    ) == .orderedAscending
                }

                return first.progress > second.progress
            }

        case .target:
            return filteredGoals.sorted { first, second in
                if first.target == second.target {
                    return first.title.localizedCaseInsensitiveCompare(
                        second.title
                    ) == .orderedAscending
                }

                return first.target < second.target
            }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if goals.isEmpty {
                    ContentUnavailableView(
                        "No Goals",
                        systemImage: "target",
                        description: Text(
                            "Tap the plus button to add your first goal."
                        )
                    )
                } else if visibleGoals.isEmpty {
                    ContentUnavailableView(
                        "No Matching Goals",
                        systemImage: "magnifyingglass",
                        description: Text(
                            "Try a different search or filter."
                        )
                    )
                } else {
                    List {
                        ForEach(visibleGoals) { goal in
                            NavigationLink {
                                GoalDetailView(goal: goal)
                            } label: {
                                GoalRowView(goal: goal)
                            }
                        }
                        .onDelete(perform: deleteGoals)
                    }
                }
            }
            .navigationTitle("My Goals")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                prompt: "Search goals"
            )
            .toolbar {
                ToolbarItemGroup(
                    placement: .primaryAction
                ) {
                    Menu {
                        Picker(
                            "Filter",
                            selection: $selectedFilter
                        ) {
                            ForEach(GoalFilter.allCases) { filter in
                                Text(filter.rawValue)
                                    .tag(filter)
                            }
                        }

                        Picker(
                            "Sort",
                            selection: $selectedSort
                        ) {
                            ForEach(GoalSortOption.allCases) { option in
                                Text(option.rawValue)
                                    .tag(option)
                            }
                        }
                    } label: {
                        Image(
                            systemName:
                                selectedFilter == .all
                                && selectedSort == .name
                                ? "line.3.horizontal.decrease.circle"
                                : "line.3.horizontal.decrease.circle.fill"
                        )
                    }
                    .accessibilityLabel("Filter and sort goals")

                    Button {
                        isShowingAddGoal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addGoalButton")
                    .accessibilityLabel("Add goal")
                }
            }
            .sheet(isPresented: $isShowingAddGoal) {
                AddGoalView { newGoal in
                    addGoal(newGoal)
                }
            }
            .alert(
                "Storage Error",
                isPresented: $isShowingStorageError
            ) {
                Button("OK", role: .cancel) {
                    // Dismiss the alert.
                }
            } message: {
                Text(storageErrorMessage)
            }
        }
    }

    private func addGoal(_ goal: Goal) {
        modelContext.insert(goal)
        saveChanges()
    }

    private func deleteGoals(
        at offsets: IndexSet
    ) {
        let goalsToDelete = offsets.map { index in
            visibleGoals[index]
        }

        for goal in goalsToDelete {
            modelContext.delete(goal)
        }

        saveChanges()
    }

    private func saveChanges() {
        do {
            if modelContext.hasChanges {
                try modelContext.save()
            }
        } catch {
            modelContext.rollback()

            storageErrorMessage =
                error.localizedDescription

            isShowingStorageError = true
        }
    }
}

#Preview {
    GoalsListView()
        .modelContainer(
            for: Goal.self,
            inMemory: true
        )
}
