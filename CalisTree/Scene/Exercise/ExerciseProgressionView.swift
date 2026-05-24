// Created by Alex Skorulis on 17/5/2026.

import ASKCoordinator
import Knit
import SwiftUI

struct ExerciseProgressionView: View {
    @State var viewModel: ExerciseProgressionViewModel
    @Bindable private var mainStore: MainStore
    @Environment(\.coordinator) private var coordinator

    init(viewModel: ExerciseProgressionViewModel, mainStore: MainStore) {
        self._viewModel = State(initialValue: viewModel)
        self._mainStore = Bindable(mainStore)
    }

    var body: some View {
        let _ = mainStore.availableEquipment
        let allItems = viewModel.items
        let availableItems = allItems.filter { mainStore.hasAvailableEquipment(for: $0.exercise) }
        let missingEquipmentItems = allItems.filter {
            !mainStore.hasAvailableEquipment(for: $0.exercise)
        }
        List {
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
        .navigationTitle("Progression")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    coordinator?.push(MainPath.exerciseProgressionTree(viewModel.exercise))
                } label: {
                    Label("Tree", systemImage: "tree")
                }
                .accessibilityLabel("Progression tree")
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
    let assembler = ExerciseTreeAssembly.testing()
    let exercise = assembler.resolver.exerciseRepository().exerciseById["one_arm_elbow_lever"]!
    return NavigationStack {
        ExerciseProgressionView(
            viewModel: assembler.resolver.exerciseProgressionViewModel(exercise: exercise),
            mainStore: assembler.resolver.mainStore()
        )
    }
    .environment(\.coordinator, Coordinator(root: MainPath.exerciseList))
}
