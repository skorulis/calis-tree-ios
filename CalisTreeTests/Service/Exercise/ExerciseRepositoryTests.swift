// Created by Alex Skorulis on 15/5/2026.

import Foundation
import Testing
@testable import CalisTree

struct ExerciseRepositoryTests {

    @Test func allPrerequisitesReferenceExistingExercises() {
        let repository = ExerciseRepository()
        #expect(!repository.exercises.isEmpty)

        for exercise in repository.exercises {
            for prerequisite in exercise.prerequisites {
                #expect(
                    repository.exerciseById[prerequisite] != nil,
                    "Exercise '\(exercise.name)' has unknown prerequisite '\(prerequisite)'"
                )
            }
        }
    }

}
