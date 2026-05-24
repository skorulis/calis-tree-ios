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
                viewModel: resolver.exerciseDetailViewModel(exercise: exercise),
                mainStore: resolver.mainStore()
            )
        case .exerciseVideo(let exercise):
            ExerciseVideoView(exercise: exercise)
        case .exerciseProgression(let exercise):
            ExerciseProgressionView(
                viewModel: coordinator.apply(
                    resolver.exerciseProgressionViewModel(exercise: exercise)
                ),
                mainStore: resolver.mainStore()
            )
        case .exerciseProgressionTree(let exercise):
            ProgressionTreeView(
                viewModel: coordinator.apply(
                    resolver.progressionTreeViewModel(exercise: exercise)
                ),
                mainStore: resolver.mainStore()
            )
        case .allExercisesProgressionTree:
            ProgressionTreeView(
                viewModel: coordinator.apply(
                    ProgressionTreeViewModel(
                        scope: .allExercises,
                        mainStore: resolver.mainStore(),
                        repository: resolver.exerciseRepository(),
                        layoutService: resolver.progressionTreeLayoutService()
                    )
                ),
                mainStore: resolver.mainStore()
            )
        case .terminologyList:
            TerminologyListView(
                viewModel: coordinator.apply(resolver.terminologyListViewModel())
            )
        case .terminologyDetail(let term):
            TerminologyDetailView(
                viewModel: resolver.terminologyDetailViewModel(terminology: term)
            )
        case .settings:
            SettingsView(
                viewModel: coordinator.apply(resolver.settingsViewModel())
            )
        }
    }
}
