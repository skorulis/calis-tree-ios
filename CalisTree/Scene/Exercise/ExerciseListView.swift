// Created by Alex Skorulis on 15/5/2026.

import ASKCoordinator
import Knit
import Observation
import SwiftUI

struct ExerciseListView: View {
    @State var viewModel: ExerciseListViewModel

    var body: some View {
        List {
            ForEach(viewModel.items) { item in
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
}

#Preview {
    let assembler = CalisTreeAssembly.testing()
    assembler.resolver.mainStore().setMasteryProgress(15, for: "Hanging L-Sit")
    return NavigationStack {
        ExerciseListView(viewModel: assembler.resolver.exerciseListViewModel())
    }
    .environment(\.coordinator, Coordinator(root: MainPath.exerciseList))
}
