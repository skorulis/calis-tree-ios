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

struct ProgressionStepItem: Identifiable {
    var id: String { variation.name }
    let variation: ExerciseVariation
    let index: Int
}

@MainActor
@Observable
final class ExerciseDetailViewModel {
    let exercise: Exercise
    private let mainStore: MainStore
    private let repository: ExerciseRepository
    private var favoriteChangeToken = 0
    
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
            guard let target = exercise.mastery else { return 0 }
            return min(target.intValue, mainStore.masteryProgress(for: exercise.name))
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

    var progressionItems: [ProgressionStepItem] {
        (exercise.progression ?? []).enumerated().map { index, variation in
            ProgressionStepItem(variation: variation, index: index)
        }
    }

    func progressionMasteryProgress(for variationName: String) -> Int {
        guard let variation = exercise.progression?.first(where: { $0.name == variationName })
        else { return 0 }
        return min(
            variation.mastery.intValue,
            mainStore.progressionMasteryProgress(for: exercise.name, variationName: variationName)
        )
    }

    func setProgressionMasteryProgress(_ value: Int, for variationName: String) {
        guard let variation = exercise.progression?.first(where: { $0.name == variationName })
        else { return }
        let clamped = min(max(0, value), variation.mastery.intValue)
        mainStore.setProgressionMasteryProgress(
            clamped,
            for: exercise.name,
            variationName: variationName
        )
    }

    func progressionMasteryLabel(for variation: ExerciseVariation) -> String {
        let target = variation.mastery
        let current = progressionMasteryProgress(for: variation.name)
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

    var isFavorite: Bool {
        get {
            _ = favoriteChangeToken
            return mainStore.isFavorite(exerciseName: exercise.name)
        }
        set {
            mainStore.setFavorite(newValue, for: exercise.name)
            favoriteChangeToken += 1
        }
    }
}
