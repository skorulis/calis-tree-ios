// Created by Alex Skorulis on 15/5/2026.

import Foundation
import Knit
import KnitMacros
import Observation

struct PrerequisiteItem: Identifiable {
    var id: String { exercise.name }
    let exercise: Exercise
    let masteryProgress: Int
}

@MainActor
@Observable
final class ExerciseDetailViewModel {
    let exercise: Exercise
    private let mainStore: MainStore
    private let repository: ExerciseRepository
    
    @Resolvable<Resolver>
    init(@Argument exercise: Exercise, mainStore: MainStore, repository: ExerciseRepository) {
        self.mainStore = mainStore
        self.repository = repository
        self.exercise = exercise
    }

    var showsMastery: Bool {
        exercise.mastery != nil
    }

    var masteryTarget: SetType? {
        exercise.mastery
    }

    var masteryProgress: Int {
        get {
            mainStore.masteryProgress(for: exercise.name)
        }
        set {
            guard let target = exercise.mastery else { return }
            let clamped = min(max(0, newValue), target.intValue)
            mainStore.setMasteryProgress(clamped, for: exercise.name)
        }
    }

    var masteryLabel: String {
        guard let target = exercise.mastery else { return "" }
        let current = masteryProgress
        return "\(current) / \(target.intValue) \(target.unitLabel)"
    }

    var prerequisiteItems: [PrerequisiteItem] {
        exercise.prerequisites.compactMap { name in
            guard let prerequisite = repository.exerciseByName[name] else { return nil }
            return PrerequisiteItem(
                exercise: prerequisite,
                masteryProgress: mainStore.masteryProgress(for: name)
            )
        }
    }

    
}
