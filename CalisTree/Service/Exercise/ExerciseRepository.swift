// Created by Alex Skorulis on 15/5/2026.

import Foundation

final class ExerciseRepository {
    let variations: [ExerciseVariation]
    let variationById: [Exercise.ID: ExerciseVariation]
    let exercises: [Exercise]
    let exerciseById: [Exercise.ID: Exercise]

    init(bundle: Bundle = .main) {
        let variationsResult = Self.loadVariations(bundle: bundle)
        self.variations = variationsResult.variations
        self.variationById = variationsResult.variationById

        let exercisesResult = Self.loadExercises(bundle: bundle)
        self.exercises = exercisesResult.exercises
        self.exerciseById = exercisesResult.exerciseById
    }

    var fullExercises: [FullExercise] {
        exercises.compactMap { fullExercise(for: $0.id) }
    }

    func fullExercise(for id: Exercise.ID) -> FullExercise? {
        guard let exercise = exerciseById[id] else { return nil }
        let progression = (exercise.progression ?? []).compactMap { variationById[$0] }
        return FullExercise(exercise: exercise, progression: progression)
    }

    /// Ordered path from foundational prerequisites to `exerciseId`, earliest first.
    func progressionChain(to exerciseId: Exercise.ID) -> [Exercise] {
        guard let target = exerciseById[exerciseId] else { return [] }

        var visited = Set<Exercise.ID>()
        var result: [Exercise] = []

        func appendAncestors(of id: Exercise.ID) {
            guard let exercise = exerciseById[id] else { return }
            for prerequisiteId in exercise.prerequisites {
                appendAncestors(of: prerequisiteId)
            }
            guard !visited.contains(id) else { return }
            visited.insert(id)
            result.append(exercise)
        }

        for prerequisiteId in target.prerequisites {
            appendAncestors(of: prerequisiteId)
        }
        if !visited.contains(target.id) {
            result.append(target)
        }
        return result
    }

    private static func loadVariations(bundle: Bundle) -> (
        variations: [ExerciseVariation],
        variationById: [Exercise.ID: ExerciseVariation]
    ) {
        let url =
            bundle.url(
                forResource: "exercise_variations",
                withExtension: "json",
                subdirectory: "Resource"
            )
            ?? bundle.url(forResource: "exercise_variations", withExtension: "json")
        guard let url else {
            assertionFailure("exercise_variations.json not found in bundle")
            return ([], [:])
        }
        do {
            let data = try Data(contentsOf: url)
            let variations = try JSONDecoder().decode([ExerciseVariation].self, from: data)
            let variationById = Dictionary(uniqueKeysWithValues: variations.map { ($0.id, $0) })
            return (variations, variationById)
        } catch {
            assertionFailure("Failed to load exercise variations: \(error)")
            return ([], [:])
        }
    }

    private static func loadExercises(bundle: Bundle) -> (
        exercises: [Exercise],
        exerciseById: [Exercise.ID: Exercise]
    ) {
        let url =
            bundle.url(forResource: "exercises", withExtension: "json", subdirectory: "Resource")
            ?? bundle.url(forResource: "exercises", withExtension: "json")
        guard let url else {
            assertionFailure("exercises.json not found in bundle")
            return ([], [:])
        }
        do {
            let data = try Data(contentsOf: url)
            let exercises = try JSONDecoder().decode([Exercise].self, from: data)
            let exerciseById = Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0) })
            return (exercises, exerciseById)
        } catch {
            assertionFailure("Failed to load exercises: \(error)")
            return ([], [:])
        }
    }
}
