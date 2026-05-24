// Created by Alex Skorulis on 16/5/2026.

import ASKCoordinator
import Foundation
import Knit
import KnitMacros
import Observation

struct ExerciseListItem: Identifiable {
    var id: Exercise.ID { exercise.id }
    let exercise: Exercise
    let masteryProgress: ExerciseProgress
}

enum ExerciseProgressFilter: String, CaseIterable, Hashable {
    case mastered
    case inProgress
    case notStarted

    var menuTitle: String {
        switch self {
        case .mastered:
            "Mastered"
        case .inProgress:
            "In progress"
        case .notStarted:
            "Not started"
        }
    }
}

@MainActor
@Observable
final class ExerciseListViewModel: CoordinatorViewModel {
    private let mainStore: MainStore
    private let repository: ExerciseRepository

    weak var coordinator: Coordinator?

    var searchText: String = ""
    var filterLevel: Level?
    var filterProgress: ExerciseProgressFilter?

    @Resolvable<Resolver>
    init(mainStore: MainStore, repository: ExerciseRepository) {
        self.mainStore = mainStore
        self.repository = repository
    }

    var hasActiveFilters: Bool {
        filterLevel != nil || filterProgress != nil
    }

    var items: [ExerciseListItem] {
        let tokens = Self.searchTokens(from: searchText)
        return repository.exercises.compactMap { exercise in
            guard let fullExercise = repository.fullExercise(for: exercise.id) else { return nil }
            let progress = mainStore.effectiveMasteryProgress(for: fullExercise)
            guard matchesProgress(exercise: exercise, progress: progress, filter: filterProgress)
            else { return nil }
            if let filterLevel, exercise.level != filterLevel { return nil }
            guard Self.matchesSearch(name: exercise.displayName, tokens: tokens) else { return nil }
            return ExerciseListItem(
                exercise: exercise,
                masteryProgress: progress
            )
        }
        .sorted {
            $0.exercise.displayName.localizedStandardCompare($1.exercise.displayName) == .orderedAscending
        }
    }

    func resetFilters() {
        filterLevel = nil
        filterProgress = nil
    }

    private static func searchTokens(from searchText: String) -> [String] {
        searchText.split(whereSeparator: \.isWhitespace).map(String.init)
    }

    private static func matchesSearch(name: String, tokens: [String]) -> Bool {
        tokens.allSatisfy { name.localizedStandardContains($0) }
    }

    private func matchesProgress(
        exercise: Exercise,
        progress: ExerciseProgress,
        filter: ExerciseProgressFilter?
    ) -> Bool {
        guard let filter else { return true }
        switch filter {
        case .mastered:
            return progress.fraction >= 1
        case .inProgress:
            return progress.fraction > 0 && progress.fraction < 1
        case .notStarted:
            return progress.fraction == 0
        }
    }
}

// MARK: - Actions

extension ExerciseListViewModel {
    func showDetails(exercise: Exercise) {
        coordinator?.push(MainPath.exerciseDetail(exercise))
    }

    func showAllProgressionTrees() {
        coordinator?.push(MainPath.allExercisesProgressionTree)
    }
}
