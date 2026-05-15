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
            ExerciseListView(repository: resolver.exerciseRepository())
        case .exerciseDetail(let exercise):
            ExerciseDetailView(exercise: exercise)
        }
    }
}
