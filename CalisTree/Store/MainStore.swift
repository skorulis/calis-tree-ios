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
    private static let availableEquipmentKey = "calisTree.availableEquipment.v1"
    private static let onboardingCompletedKey = "calisTree.onboardingCompleted.v1"

    private(set) var masteryByExerciseId: [Exercise.ID: Int] = [:]
    private(set) var favoriteExerciseIds: Set<Exercise.ID> = []
    private(set) var availableEquipment: Set<Equipment> = Set(Equipment.allCases)
    private(set) var hasCompletedOnboarding: Bool = false

    @Resolvable<Resolver>
    init(keyValueStore: PKeyValueStore) {
        self.keyValueStore = keyValueStore
        masteryByExerciseId =
            (try? keyValueStore.codable(forKey: Self.masteryKey)) ?? [:]
        favoriteExerciseIds =
            (try? keyValueStore.codable(forKey: Self.favoritesKey)) ?? []
        if let saved: Set<Equipment> = try? keyValueStore.codable(forKey: Self.availableEquipmentKey) {
            availableEquipment = saved
        }
        hasCompletedOnboarding =
            (try? keyValueStore.codable(forKey: Self.onboardingCompletedKey)) ?? false
    }

    func masteryProgress(for exerciseId: Exercise.ID) -> Int {
        masteryByExerciseId[exerciseId] ?? 0
    }

    /// Effective mastery for display and filtering, accounting for progression steps when present.
    func effectiveMasteryProgress(for fullExercise: FullExercise) -> ExerciseProgress {
        let exercise = fullExercise.exercise
        let base = exercise.mastery.map { mastery in
            let target = mastery.intValue
            let value = min(target, masteryProgress(for: exercise.id))
            return MasteryProgress(current: value, target: target)
        }

        let progression = fullExercise.progression
        var progressionMastery: [Exercise.ID: MasteryProgress] = [:]
        for variation in progression {
            let stepProgress = masteryProgress(
                for: variation.id
            )
            let stepClamped = min(stepProgress, variation.mastery.intValue)
            progressionMastery[variation.id] = .init(current: stepClamped, target: variation.mastery.intValue)
        }
        
        return .init(main: base, progression: progressionMastery)
    }

    func setMasteryProgress(_ value: Int, for exerciseId: Exercise.ID) {
        var updated = masteryByExerciseId
        updated[exerciseId] = value
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

    func isEquipmentAvailable(_ equipment: Equipment) -> Bool {
        availableEquipment.contains(equipment)
    }

    func hasAvailableEquipment(for exercise: Exercise) -> Bool {
        exercise.equipment.allSatisfy(isEquipmentAvailable)
    }

    func setEquipmentAvailable(_ available: Bool, for equipment: Equipment) {
        var updated = availableEquipment
        if available {
            updated.insert(equipment)
        } else {
            updated.remove(equipment)
        }
        availableEquipment = updated
        try? keyValueStore.set(codable: availableEquipment, forKey: Self.availableEquipmentKey)
    }

    func completeOnboarding() {
        guard !hasCompletedOnboarding else { return }
        hasCompletedOnboarding = true
        try? keyValueStore.set(codable: true, forKey: Self.onboardingCompletedKey)
    }
}
