// Created by Alex Skorulis on 15/5/2026.

import Foundation

final class ExerciseRepository {
    let exercises: [Exercise]
    let exerciseByName: [String: Exercise]

    init(bundle: Bundle = .main) {
        let url =
            bundle.url(forResource: "exercises", withExtension: "json", subdirectory: "Resource")
            ?? bundle.url(forResource: "exercises", withExtension: "json")
        guard let url else {
            assertionFailure("exercises.json not found in bundle")
            self.exercises = []
            self.exerciseByName = [:]
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let exercises = try JSONDecoder().decode([Exercise].self, from: data)
            self.exercises = exercises
            self.exerciseByName = Dictionary(uniqueKeysWithValues: exercises.map { ($0.name, $0) })
        } catch {
            assertionFailure("Failed to load exercises: \(error)")
            self.exercises = []
            self.exerciseByName = [:]
        }
    }
}
