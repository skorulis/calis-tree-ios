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

    private(set) var masteryByExerciseName: [String: Int] = [:]

    @Resolvable<Resolver>
    init(keyValueStore: PKeyValueStore) {
        self.keyValueStore = keyValueStore
        masteryByExerciseName =
            (try? keyValueStore.codable(forKey: Self.masteryKey)) ?? [:]
    }

    func masteryProgress(for exerciseName: String) -> Int {
        masteryByExerciseName[exerciseName] ?? 0
    }

    func setMasteryProgress(_ value: Int, for exerciseName: String) {
        var updated = masteryByExerciseName
        updated[exerciseName] = max(0, value)
        masteryByExerciseName = updated
        try? keyValueStore.set(codable: masteryByExerciseName, forKey: Self.masteryKey)
    }
}
