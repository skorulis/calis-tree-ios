// Created by Alex Skorulis on 15/5/2026.

import ASKCore
import Foundation
import Testing
@testable import CalisTree

@MainActor
struct MainStoreTests {

    @Test func masteryProgressPersistsAcrossInstances() {
        let keyValueStore = InMemoryDefaults()
        let first = MainStore(keyValueStore: keyValueStore)
        first.setMasteryProgress(12, for: "hanging_l_sit")

        let second = MainStore(keyValueStore: keyValueStore)
        #expect(second.masteryProgress(for: "hanging_l_sit") == 12)
    }

    @Test func progressionMasteryProgressPersistsAcrossInstances() {
        let keyValueStore = InMemoryDefaults()
        let first = MainStore(keyValueStore: keyValueStore)
        first.setMasteryProgress(8, for: "bent_knee")

        let second = MainStore(keyValueStore: keyValueStore)
        #expect(second.masteryProgress(for: "bent_knee") == 8)
        #expect(second.masteryProgress(for: "one_arm_elbow_lever") == 0)
    }

    @Test func effectiveMasteryWithoutProgressionUsesBaseValue() {
        let store = MainStore(keyValueStore: InMemoryDefaults())
        let exercise = Exercise(
            id: "pull_up",
            name: "Pull Up",
            description: nil,
            steps: nil,
            level: .beginner,
            imageFile: nil,
            videoURL: "https://example.com",
            equipment: [.overheadBar],
            mastery: .reps(20),
            progression: nil,
            prerequisites: []
        )
        store.setMasteryProgress(12, for: exercise.id)
        let fullExercise = FullExercise(exercise: exercise, progression: [])
        #expect(store.effectiveMasteryProgress(for: fullExercise).fraction == 0.6)
    }

    @Test func effectiveMasteryAveragesProgressionSteps() {
        let store = MainStore(keyValueStore: InMemoryDefaults())
        let exercise = Exercise(
            id: "one_arm_elbow_lever",
            name: "One Arm Elbow Lever",
            description: nil,
            steps: nil,
            level: .advanced,
            imageFile: nil,
            videoURL: "https://example.com",
            equipment: [],
            mastery: .time(10),
            progression: ["bent_knee", "straddle"],
            prerequisites: []
        )
        let fullExercise = FullExercise(
            exercise: exercise,
            progression: [
                ExerciseVariation(id: "bent_knee", name: "Bent Knee", description: nil, level: nil, mastery: .time(10)),
                ExerciseVariation(id: "straddle", name: "Straddle", description: nil, level: nil, mastery: .time(10)),
            ]
        )
        store.setMasteryProgress(5, for: "bent_knee")
        store.setMasteryProgress(10, for: "straddle")

        #expect(store.effectiveMasteryProgress(for: fullExercise).fraction == 0.5)
    }

    @Test func effectiveMasteryUsesBaseWhenHigherThanProgressionAverage() {
        let store = MainStore(keyValueStore: InMemoryDefaults())
        let exercise = Exercise(
            id: "one_arm_elbow_lever",
            name: "One Arm Elbow Lever",
            description: nil,
            steps: nil,
            level: .advanced,
            imageFile: nil,
            videoURL: "https://example.com",
            equipment: [],
            mastery: .time(10),
            progression: ["bent_knee"],
            prerequisites: []
        )
        let fullExercise = FullExercise(
            exercise: exercise,
            progression: [
                ExerciseVariation(id: "bent_knee", name: "Bent Knee", description: nil, level: nil, mastery: .time(10)),
            ]
        )
        store.setMasteryProgress(10, for: exercise.id)
        store.setMasteryProgress(0, for: "bent_knee")
        #expect(store.effectiveMasteryProgress(for: fullExercise).fraction == 1)
    }

    @Test func availableEquipmentDefaultsToAllCases() {
        let store = MainStore(keyValueStore: InMemoryDefaults())
        #expect(store.availableEquipment == Set(Equipment.allCases))
    }

    @Test func availableEquipmentPersistsAcrossInstances() {
        let keyValueStore = InMemoryDefaults()
        let first = MainStore(keyValueStore: keyValueStore)
        first.setEquipmentAvailable(false, for: .rings)
        first.setEquipmentAvailable(false, for: .lowBar)

        let second = MainStore(keyValueStore: keyValueStore)
        #expect(!second.isEquipmentAvailable(.rings))
        #expect(!second.isEquipmentAvailable(.lowBar))
        #expect(second.isEquipmentAvailable(.overheadBar))
    }

    @Test func favoritesPersistAcrossInstances() {
        let keyValueStore = InMemoryDefaults()
        let first = MainStore(keyValueStore: keyValueStore)
        first.setFavorite(true, for: "pull_up")
        first.setFavorite(true, for: "hanging_l_sit")
        first.setFavorite(false, for: "pull_up")

        let second = MainStore(keyValueStore: keyValueStore)
        #expect(second.isFavorite(exerciseId: "hanging_l_sit"))
        #expect(!second.isFavorite(exerciseId: "pull_up"))
    }

    @Test func onboardingCompletionDefaultsToFalse() {
        let store = MainStore(keyValueStore: InMemoryDefaults())
        #expect(!store.hasCompletedOnboarding)
    }

    @Test func onboardingCompletionPersistsAcrossInstances() {
        let keyValueStore = InMemoryDefaults()
        let first = MainStore(keyValueStore: keyValueStore)
        first.completeOnboarding()

        let second = MainStore(keyValueStore: keyValueStore)
        #expect(second.hasCompletedOnboarding)
    }

}
