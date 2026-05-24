// Created by Alex Skorulis on 15/5/2026.

import ASKCoordinator
import Knit
import Observation
import SwiftUI

struct ExerciseListView: View {
    @State var viewModel: ExerciseListViewModel
    @Bindable private var mainStore: MainStore
    @State private var isFilterPresented = false

    init(viewModel: ExerciseListViewModel, mainStore: MainStore) {
        self._viewModel = State(initialValue: viewModel)
        self._mainStore = Bindable(mainStore)
    }

    var body: some View {
        let allItems = viewModel.items
        let favoriteItems = allItems.filter { mainStore.isFavorite(exerciseId: $0.exercise.id) }
        let availableItems = allItems.filter {
            hasAvailableEquipment($0.exercise) && !mainStore.isFavorite(exerciseId: $0.exercise.id)
        }
        let missingEquipmentItems = allItems.filter {
            !hasAvailableEquipment($0.exercise) && !mainStore.isFavorite(exerciseId: $0.exercise.id)
        }
        List {
            if !favoriteItems.isEmpty {
                Section {
                    ForEach(favoriteItems) { item in
                        exerciseRow(item: item)
                    }
                } header: {
                    Text("Favorites")
                }
            }
            Section {
                ForEach(availableItems) { item in
                    exerciseRow(item: item)
                }
            }
            if !missingEquipmentItems.isEmpty {
                Section {
                    ForEach(missingEquipmentItems) { item in
                        exerciseRow(item: item)
                    }
                } header: {
                    Text("Missing equipment")
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Exercises")
        .searchable(text: $viewModel.searchText, prompt: Text("Search exercises"))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.showAllProgressionTrees()
                } label: {
                    Label("Progression trees", systemImage: "tree")
                }
                .accessibilityLabel("All progression trees")
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isFilterPresented = true
                } label: {
                    Label(
                        "Filter",
                        systemImage: viewModel.hasActiveFilters
                            ? "line.3.horizontal.decrease.circle.fill"
                            : "line.3.horizontal.decrease.circle"
                    )
                }
            }
        }
        .sheet(isPresented: $isFilterPresented) {
            ExerciseListFilterView(
                filterLevel: $viewModel.filterLevel,
                filterProgress: $viewModel.filterProgress,
                hasActiveFilters: viewModel.hasActiveFilters,
                onClear: viewModel.resetFilters
            )
            .presentationDetents([.medium, .large])
        }
    }

    private func hasAvailableEquipment(_ exercise: Exercise) -> Bool {
        exercise.equipment.allSatisfy(mainStore.isEquipmentAvailable)
    }

    @ViewBuilder
    private func exerciseRow(item: ExerciseListItem) -> some View {
        Button {
            viewModel.showDetails(exercise: item.exercise)
        } label: {
            ExerciseCell(
                exercise: item.exercise,
                masteryProgress: item.masteryProgress
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let assembler = ExerciseTreeAssembly.testing()
    assembler.resolver.mainStore().setMasteryProgress(15, for: "Hanging L-Sit")
    return NavigationStack {
        ExerciseListView(
            viewModel: assembler.resolver.exerciseListViewModel(),
            mainStore: assembler.resolver.mainStore()
        )
    }
    .environment(\.coordinator, Coordinator(root: MainPath.exerciseList))
}
