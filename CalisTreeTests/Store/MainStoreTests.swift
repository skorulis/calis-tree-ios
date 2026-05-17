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
