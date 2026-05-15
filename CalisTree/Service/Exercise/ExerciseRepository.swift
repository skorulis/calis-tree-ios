// Created by Alex Skorulis on 15/5/2026.

import Foundation

final class ExerciseRepository {
    let exercises: [Exercise]

    init(bundle: Bundle = .main) {
        let url =
            bundle.url(forResource: "exercises", withExtension: "json", subdirectory: "Resource")
            ?? bundle.url(forResource: "exercises", withExtension: "json")
        guard let url else {
            assertionFailure("exercises.json not found in bundle")
            self.exercises = []
            return
        }
        do {
            let data = try Data(contentsOf: url)
            self.exercises = try JSONDecoder().decode([Exercise].self, from: data)
        } catch {
            assertionFailure("Failed to load exercises: \(error)")
            self.exercises = []
        }
    }
}
