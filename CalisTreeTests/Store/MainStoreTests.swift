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
        first.setMasteryProgress(12, for: "Hanging L-Sit")

        let second = MainStore(keyValueStore: keyValueStore)
        #expect(second.masteryProgress(for: "Hanging L-Sit") == 12)
    }

    @Test func progressionMasteryProgressPersistsAcrossInstances() {
        let keyValueStore = InMemoryDefaults()
        let first = MainStore(keyValueStore: keyValueStore)
        first.setProgressionMasteryProgress(8, for: "One Arm Elbow Lever", variationName: "Bent Knee")

        let second = MainStore(keyValueStore: keyValueStore)
        #expect(second.progressionMasteryProgress(for: "One Arm Elbow Lever", variationName: "Bent Knee") == 8)
        #expect(second.masteryProgress(for: "One Arm Elbow Lever") == 0)
    }

    @Test func effectiveMasteryWithoutProgressionUsesBaseValue() {
        let store = MainStore(keyValueStore: InMemoryDefaults())
        let exercise = Exercise(
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
        store.setMasteryProgress(12, for: exercise.name)
        #expect(store.effectiveMasteryProgress(for: exercise) == 12)
    }

    @Test func effectiveMasteryAveragesProgressionSteps() {
        let store = MainStore(keyValueStore: InMemoryDefaults())
        let exercise = Exercise(
            name: "One Arm Elbow Lever",
            description: nil,
            steps: nil,
            level: .advanced,
            imageFile: nil,
            videoURL: "https://example.com",
            equipment: [.floor],
            mastery: .time(10),
            progression: [
                ExerciseVariation(name: "Bent Knee", description: nil, mastery: .time(10)),
                ExerciseVariation(name: "Straddle", description: nil, mastery: .time(10)),
            ],
            prerequisites: []
        )
        store.setProgressionMasteryProgress(5, for: exercise.name, variationName: "Bent Knee")
        store.setProgressionMasteryProgress(10, for: exercise.name, variationName: "Straddle")

        #expect(store.effectiveMasteryProgress(for: exercise) == 5)
    }

    @Test func effectiveMasteryUsesBaseWhenHigherThanProgressionAverage() {
        let store = MainStore(keyValueStore: InMemoryDefaults())
        let exercise = Exercise(
            name: "One Arm Elbow Lever",
            description: nil,
            steps: nil,
            level: .advanced,
            imageFile: nil,
            videoURL: "https://example.com",
            equipment: [.floor],
            mastery: .time(10),
            progression: [
                ExerciseVariation(name: "Bent Knee", description: nil, mastery: .time(10)),
            ],
            prerequisites: []
        )
        store.setMasteryProgress(10, for: exercise.name)
        store.setProgressionMasteryProgress(0, for: exercise.name, variationName: "Bent Knee")
        #expect(store.effectiveMasteryProgress(for: exercise) == 10)
    }

    @Test func favoritesPersistAcrossInstances() {
        let keyValueStore = InMemoryDefaults()
        let first = MainStore(keyValueStore: keyValueStore)
        first.setFavorite(true, for: "Pull up")
        first.setFavorite(true, for: "Hanging L-Sit")
        first.setFavorite(false, for: "Pull up")

        let second = MainStore(keyValueStore: keyValueStore)
        #expect(second.isFavorite(exerciseName: "Hanging L-Sit"))
        #expect(!second.isFavorite(exerciseName: "Pull up"))
    }

}
