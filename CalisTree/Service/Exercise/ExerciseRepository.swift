// Created by Alex Skorulis on 15/5/2026.

import Foundation

final class ExerciseRepository {
    let exercises: [Exercise]
    let exerciseById: [Exercise.ID: Exercise]

    init(bundle: Bundle = .main) {
        let url =
            bundle.url(forResource: "exercises", withExtension: "json", subdirectory: "Resource")
            ?? bundle.url(forResource: "exercises", withExtension: "json")
        guard let url else {
            assertionFailure("exercises.json not found in bundle")
            self.exercises = []
            self.exerciseById = [:]
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let exercises = try JSONDecoder().decode([Exercise].self, from: data)
            self.exercises = exercises
            self.exerciseById = Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0) })
        } catch {
            assertionFailure("Failed to load exercises: \(error)")
            self.exercises = []
            self.exerciseById = [:]
        }
    }
}
