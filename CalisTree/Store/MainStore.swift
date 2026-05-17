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

    private(set) var masteryByExerciseName: [String: Int] = [:]
    private(set) var favoriteExerciseNames: Set<String> = []

    @Resolvable<Resolver>
    init(keyValueStore: PKeyValueStore) {
        self.keyValueStore = keyValueStore
        masteryByExerciseName =
            (try? keyValueStore.codable(forKey: Self.masteryKey)) ?? [:]
        favoriteExerciseNames =
            (try? keyValueStore.codable(forKey: Self.favoritesKey)) ?? []
    }

    func masteryProgress(for exerciseName: String) -> Int {
        masteryByExerciseName[exerciseName] ?? 0
    }

    /// Effective mastery for display and filtering, accounting for progression steps when present.
    func effectiveMasteryProgress(for exercise: Exercise) -> Int {
        guard let target = exercise.mastery else { return 0 }
        let targetValue = target.intValue
        let base = min(targetValue, masteryProgress(for: exercise.name))

        guard let progression = exercise.progression, !progression.isEmpty else {
            return base
        }

        let stepCount = Double(progression.count + 1)
        let totalFraction = progression.reduce(0.0) { sum, variation in
            let stepTarget = variation.mastery.intValue
            guard stepTarget > 0 else { return sum + 1 }
            let stepProgress = progressionMasteryProgress(
                for: exercise.name,
                variationName: variation.name
            )
            return sum + min(1, Double(stepProgress) / Double(stepTarget))
        }
        let fromSteps = Int((totalFraction / stepCount * Double(targetValue)).rounded())
        return min(targetValue, max(base, fromSteps))
    }

    func setMasteryProgress(_ value: Int, for exerciseName: String) {
        updateMasteryProgress(max(0, value), forKey: exerciseName)
    }

    func progressionMasteryProgress(for exerciseName: String, variationName: String) -> Int {
        masteryByExerciseName[progressionMasteryKey(exerciseName: exerciseName, variationName: variationName)] ?? 0
    }

    func setProgressionMasteryProgress(
        _ value: Int,
        for exerciseName: String,
        variationName: String
    ) {
        updateMasteryProgress(
            max(0, value),
            forKey: progressionMasteryKey(exerciseName: exerciseName, variationName: variationName)
        )
    }

    private func progressionMasteryKey(exerciseName: String, variationName: String) -> String {
        "\(exerciseName)-\(variationName)"
    }

    private func updateMasteryProgress(_ value: Int, forKey key: String) {
        var updated = masteryByExerciseName
        updated[key] = value
        masteryByExerciseName = updated
        try? keyValueStore.set(codable: masteryByExerciseName, forKey: Self.masteryKey)
    }

    func isFavorite(exerciseName: String) -> Bool {
        favoriteExerciseNames.contains(exerciseName)
    }

    func setFavorite(_ isFavorite: Bool, for exerciseName: String) {
        var updated = favoriteExerciseNames
        if isFavorite {
            updated.insert(exerciseName)
        } else {
            updated.remove(exerciseName)
        }
        favoriteExerciseNames = updated
        try? keyValueStore.set(codable: favoriteExerciseNames, forKey: Self.favoritesKey)
    }
}
