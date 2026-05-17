// Created by Alex Skorulis on 15/5/2026.

import ASKCore
import Foundation
import Knit
import KnitMacros
import Observation

@MainActor
@Observable
final class MainStore {
    private let keyValueStore: PKeyValueStore
    private static let masteryKey = "calisTree.exerciseMastery.v1"
    private static let favoritesKey = "calisTree.exerciseFavorites.v1"

    private(set) var masteryByExerciseId: [Exercise.ID: Int] = [:]
    private(set) var favoriteExerciseIds: Set<Exercise.ID> = []

    @Resolvable<Resolver>
    init(keyValueStore: PKeyValueStore) {
        self.keyValueStore = keyValueStore
        masteryByExerciseId =
            (try? keyValueStore.codable(forKey: Self.masteryKey)) ?? [:]
        favoriteExerciseIds =
            (try? keyValueStore.codable(forKey: Self.favoritesKey)) ?? []
    }

    func masteryProgress(for exerciseId: Exercise.ID) -> Int {
        masteryByExerciseId[exerciseId] ?? 0
    }

    /// Effective mastery for display and filtering, accounting for progression steps when present.
    func effectiveMasteryProgress(for exercise: Exercise) -> ExerciseProgress {
        let base = exercise.mastery.map { mastery in
            let target = mastery.intValue
            let value = min(target, masteryProgress(for: exercise.id))
            return MasteryProgress(current: value, target: target)
        }

        let progression = exercise.progression ?? []
        var progressionMastery: [Exercise.ID: MasteryProgress] = [:]
        for variation in progression {
            let stepProgress = progressionMasteryProgress(
                for: exercise.id,
                variationId: variation.id
            )
            let stepClamped = min(stepProgress, variation.mastery.intValue)
            progressionMastery[variation.id] = .init(current: stepClamped, target: variation.mastery.intValue)
        }
        
        return .init(main: base, progression: progressionMastery)
    }

    func setMasteryProgress(_ value: Int, for exerciseId: Exercise.ID) {
        updateMasteryProgress(max(0, value), forKey: exerciseId)
    }

    func progressionMasteryProgress(for exerciseId: Exercise.ID, variationId: Exercise.ID) -> Int {
        masteryByExerciseId[progressionMasteryKey(exerciseId: exerciseId, variationId: variationId)] ?? 0
    }

    func setProgressionMasteryProgress(
        _ value: Int,
        for exerciseId: Exercise.ID,
        variationId: Exercise.ID
    ) {
        updateMasteryProgress(
            max(0, value),
            forKey: progressionMasteryKey(exerciseId: exerciseId, variationId: variationId)
        )
    }

    private func progressionMasteryKey(exerciseId: Exercise.ID, variationId: Exercise.ID) -> String {
        "\(exerciseId)-\(variationId)"
    }

    private func updateMasteryProgress(_ value: Int, forKey key: String) {
        var updated = masteryByExerciseId
        updated[key] = value
        masteryByExerciseId = updated
        try? keyValueStore.set(codable: masteryByExerciseId, forKey: Self.masteryKey)
    }

    func isFavorite(exerciseId: Exercise.ID) -> Bool {
        favoriteExerciseIds.contains(exerciseId)
    }

    func setFavorite(_ isFavorite: Bool, for exerciseId: Exercise.ID) {
        var updated = favoriteExerciseIds
        if isFavorite {
            updated.insert(exerciseId)
        } else {
            updated.remove(exerciseId)
        }
        favoriteExerciseIds = updated
        try? keyValueStore.set(codable: favoriteExerciseIds, forKey: Self.favoritesKey)
    }
}
