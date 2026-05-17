// Created by Alex Skorulis on 15/5/2026.

import ASKCoordinator
import Knit
import SwiftUI

struct MainPathRenderer: CoordinatorPathRenderer {
    typealias PathType = MainPath

    let resolver: Resolver

    @ViewBuilder @MainActor
    func render(path: MainPath, in coordinator: Coordinator) -> some View {
        switch path {
        case .exerciseList:
            ExerciseListView(
                viewModel: coordinator.apply(resolver.exerciseListViewModel()),
                mainStore: resolver.mainStore()
            )
        case .exerciseDetail(let exercise):
            ExerciseDetailView(
                viewModel: resolver.exerciseDetailViewModel(exercise: exercise)
            )
        case .exerciseVideo(let exercise):
            ExerciseVideoView(exercise: exercise)
        case .exerciseProgression(let exercise):
            ExerciseProgressionView(
                viewModel: coordinator.apply(
                    resolver.exerciseProgressionViewModel(exercise: exercise)
                )
            )
        case .terminologyList:
            TerminologyListView(
                viewModel: coordinator.apply(resolver.terminologyListViewModel())
            )
        case .terminologyDetail(let term):
            TerminologyDetailView(
                viewModel: resolver.terminologyDetailViewModel(terminology: term)
            )
        }
    }
}
