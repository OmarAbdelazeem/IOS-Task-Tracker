import SwiftUI
import SwiftData
import Foundation
import os

#if DEBUG
private let goalsListSignposter =
    OSSignposter(
        subsystem:
            Bundle.main.bundleIdentifier
            ?? "FirstApp",
        category: .pointsOfInterest
    )
#endif

struct GoalsListView: View {
    let service: any GoalServicing

    @Query(sort: \Goal.title)
    private var goals: [Goal]

    @State private var isShowingAddGoal = false
    @State private var searchText = ""
    @State private var debouncedSearchText = ""
    @State private var selectedFilter = GoalFilter.all
    @State private var selectedSort = GoalSortOption.name

    @State private var isShowingStorageError = false
    @State private var storageErrorMessage = ""

    private var visibleGoals: [Goal] {
#if DEBUG
        let intervalState =
            goalsListSignposter.beginInterval(
                "Build Visible Goals"
            )

        defer {
            goalsListSignposter.endInterval(
                "Build Visible Goals",
                intervalState
            )
        }
#endif

        return GoalListProcessor(
            goals: goals,
            searchText: debouncedSearchText,
            filter: selectedFilter,
            sort: selectedSort
        )
        .results
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
                                GoalDetailView(
                                    goal: goal,
                                    service: service
                                )
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
            .task(id: searchText) {
                if searchText.isEmpty {
                    debouncedSearchText = ""
                    return
                }

                do {
                    try await Task.sleep(
                        for: .milliseconds(250)
                    )
                } catch {
                    // A newer search cancelled this task.
                    return
                }

                debouncedSearchText = searchText
            }
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
                                Text(filter.title)
                                    .tag(filter)
                            }
                        }

                        Picker(
                            "Sort",
                            selection: $selectedSort
                        ) {
                            ForEach(GoalSortOption.allCases) { option in
                                Text(option.title)
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
                AddGoalView(
                    service: service
                )
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

    private func deleteGoals(
        at offsets: IndexSet
    ) {
        let goalsToDelete =
            offsets.map { index in
                visibleGoals[index]
            }

        Task {
            do {
                try await service.delete(
                    goalsToDelete
                )
            } catch {
                showStorageError(error)
            }
        }
    }

    private func showStorageError(
        _ error: Error
    ) {
        storageErrorMessage =
            error.localizedDescription

        isShowingStorageError = true
    }
}

#Preview {
    GoalsListView(
        service: PreviewGoalService()
    )
        .modelContainer(
            for: Goal.self,
            inMemory: true
        )
}
