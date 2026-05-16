// Created by Alex Skorulis on 15/5/2026.

import ASKCoordinator
import Knit
import Observation
import SwiftUI

struct ExerciseListView: View {
    @State var viewModel: ExerciseListViewModel
    @Bindable private var mainStore: MainStore

    init(viewModel: ExerciseListViewModel, mainStore: MainStore) {
        self._viewModel = State(initialValue: viewModel)
        self._mainStore = Bindable(mainStore)
    }

    var body: some View {
        let allItems = viewModel.items
        let favoriteItems = allItems.filter { mainStore.isFavorite(exerciseName: $0.exercise.name) }
        let alphabeticalItems = allItems.filter { !mainStore.isFavorite(exerciseName: $0.exercise.name) }
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
                ForEach(alphabeticalItems) { item in
                    exerciseRow(item: item)
                }
            }
        }
        .navigationTitle("Exercises")
        .searchable(text: $viewModel.searchText, prompt: Text("Search exercises"))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Picker("Level", selection: $viewModel.filterLevel) {
                        Text("All levels").tag(Optional<Level>.none)
                        ForEach(Level.allCases, id: \.self) { level in
                            Text(level.displayTitle).tag(Optional(level))
                        }
                    }

                    Picker("Equipment", selection: $viewModel.filterEquipment) {
                        Text("All equipment").tag(Optional<Equipment>.none)
                        ForEach(Equipment.allCases, id: \.self) { equipment in
                            Text(equipment.description).tag(Optional(equipment))
                        }
                    }

                    Picker("Status", selection: $viewModel.filterProgress) {
                        Text("All statuses").tag(Optional<ExerciseProgressFilter>.none)
                        ForEach(ExerciseProgressFilter.allCases, id: \.self) { status in
                            Text(status.menuTitle).tag(Optional(status))
                        }
                    }

                    if viewModel.hasActiveFilters {
                        Button("Clear filters") {
                            viewModel.resetFilters()
                        }
                    }
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
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
    let assembler = CalisTreeAssembly.testing()
    assembler.resolver.mainStore().setMasteryProgress(15, for: "Hanging L-Sit")
    return NavigationStack {
        ExerciseListView(
            viewModel: assembler.resolver.exerciseListViewModel(),
            mainStore: assembler.resolver.mainStore()
        )
    }
    .environment(\.coordinator, Coordinator(root: MainPath.exerciseList))
}
