// Created by Alex Skorulis on 15/5/2026.

import ASKCoordinator
import Knit
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
