// Created by Alex Skorulis on 17/5/2026.

import ASKCoordinator
import Knit
import SwiftUI

struct ExerciseProgressionView: View {
    @State var viewModel: ExerciseProgressionViewModel

    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                exerciseRow(item: item)
            }
        }
        .navigationTitle("Progression")
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
    let exercise = assembler.resolver.exerciseRepository().exerciseById["one_arm_elbow_lever"]!
    return NavigationStack {
        ExerciseProgressionView(
            viewModel: assembler.resolver.exerciseProgressionViewModel(exercise: exercise)
        )
    }
    .environment(\.coordinator, Coordinator(root: MainPath.exerciseList))
}
