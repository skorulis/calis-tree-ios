// Created by Alex Skorulis on 15/5/2026.

import Foundation
import Knit
import KnitMacros
import Observation

struct PrerequisiteItem: Identifiable {
    var id: Exercise.ID { exercise.id }
    let exercise: Exercise
    let masteryProgress: ExerciseProgress
}

struct ProgressionStepItem: Identifiable {
    var id: Exercise.ID { variation.id }
    let variation: ExerciseVariation
    let index: Int
}

@MainActor
@Observable
final class ExerciseDetailViewModel {
    let exercise: Exercise
    private let fullExercise: FullExercise
    private let mainStore: MainStore
    private let repository: ExerciseRepository
    private var favoriteChangeToken = 0
    
    @Resolvable<Resolver>
    init(@Argument exercise: Exercise, mainStore: MainStore, repository: ExerciseRepository) {
        self.mainStore = mainStore
        self.repository = repository
        self.exercise = exercise
        self.fullExercise = repository.fullExercise(for: exercise.id)
            ?? FullExercise(exercise: exercise, progression: [])
    }

    var showsMastery: Bool {
        exercise.mastery != nil
    }

    var masteryTarget: SetType? {
        exercise.mastery
    }

    var masteryProgress: Int {
        get {
            guard let target = exercise.mastery else { return 0 }
            return min(target.intValue, mainStore.masteryProgress(for: exercise.id))
        }
        set {
            guard let target = exercise.mastery else { return }
            let clamped = min(max(0, newValue), target.intValue)
            mainStore.setMasteryProgress(clamped, for: exercise.id)
        }
    }

    var masteryLabel: String {
        guard let target = exercise.mastery else { return "" }
        let current = masteryProgress
        return "\(current) / \(target.intValue) \(target.unitLabel)"
    }

    var progressionItems: [ProgressionStepItem] {
        fullExercise.progression.enumerated().map { index, variation in
            ProgressionStepItem(variation: variation, index: index)
        }
    }

    func progressionMasteryProgress(for variationId: Exercise.ID) -> Int {
        guard let variation = fullExercise.progression.first(where: { $0.id == variationId })
        else { return 0 }
        return min(
            variation.mastery.intValue,
            mainStore.masteryProgress(for: variationId)
        )
    }

    func setProgressionMasteryProgress(_ value: Int, for variationId: Exercise.ID) {
        guard let variation = fullExercise.progression.first(where: { $0.id == variationId })
        else { return }
        let clamped = min(max(0, value), variation.mastery.intValue)
        mainStore.setMasteryProgress(
            clamped,
            for: variationId
        )
    }

    func progressionMasteryLabel(for variation: ExerciseVariation) -> String {
        let target = variation.mastery
        let current = progressionMasteryProgress(for: variation.id)
        return "\(current) / \(target.intValue) \(target.unitLabel)"
    }

    var prerequisiteItems: [PrerequisiteItem] {
        repository.progressionChain(to: exercise.id)
            .filter { $0.id != exercise.id }
            .map { prerequisite in
                PrerequisiteItem(
                    exercise: prerequisite,
                    masteryProgress: mainStore.effectiveMasteryProgress(
                        for: repository.fullExercise(for: prerequisite.id)
                            ?? FullExercise(exercise: prerequisite, progression: [])
                    )
                )
            }
    }

    var isFavorite: Bool {
        get {
            _ = favoriteChangeToken
            return mainStore.isFavorite(exerciseId: exercise.id)
        }
        set {
            mainStore.setFavorite(newValue, for: exercise.id)
            favoriteChangeToken += 1
        }
    }
}
