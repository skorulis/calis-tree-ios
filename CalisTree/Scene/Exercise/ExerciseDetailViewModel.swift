// Created by Alex Skorulis on 15/5/2026.

import Foundation
import Observation

@MainActor
@Observable
final class ExerciseDetailViewModel {
    let exercise: Exercise
    private let mainStore: MainStore

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

    init(mainStore: MainStore, exercise: Exercise) {
        self.mainStore = mainStore
        self.exercise = exercise
    }
}
