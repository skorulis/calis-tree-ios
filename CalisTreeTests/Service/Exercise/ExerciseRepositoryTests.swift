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
                    "Exercise '\(exercise.displayName)' has unknown prerequisite '\(prerequisite)'"
                )
            }
        }
    }

    @Test func allProgressionVariationIdsReferenceExistingVariations() {
        let repository = ExerciseRepository()
        #expect(!repository.variations.isEmpty)

        for exercise in repository.exercises {
            for variationId in exercise.progression ?? [] {
                #expect(
                    repository.variationById[variationId] != nil,
                    "Exercise '\(exercise.id)' references unknown variation '\(variationId)'"
                )
            }
        }
    }

    @Test func fullExerciseResolvesAllProgressionVariations() {
        let repository = ExerciseRepository()
        for exercise in repository.exercises {
            guard let progressionIds = exercise.progression, !progressionIds.isEmpty else { continue }
            let fullExercise = repository.fullExercise(for: exercise.id)
            #expect(fullExercise != nil)
            #expect(fullExercise?.progression.count == progressionIds.count)
        }
    }

    @Test func progressionChain_linearPrerequisites() {
        let repository = ExerciseRepository()
        let chain = repository.progressionChain(to: "one_arm_elbow_lever")
        #expect(chain.map(\.id) == ["wall_push_up", "push_up", "elbow_lever", "one_arm_elbow_lever"])
    }

    @Test func progressionChain_deduplicatesSharedAncestors() {
        let repository = ExerciseRepository()
        let chain = repository.progressionChain(to: "archer_push_up")
        #expect(chain.map(\.id) == ["wall_push_up", "push_up", "diamond_push_up", "wide_push_up", "archer_push_up"])
    }

    @Test func progressionChain_multiBranchPrerequisites() {
        let repository = ExerciseRepository()
        let chain = repository.progressionChain(to: "planche")
        #expect(
            chain.map(\.id) == [
                "reverse_leg_raises",
                "l_sit_kicks",
                "knee_plank",
                "plank",
                "boat_hold",
                "seated_leg_raise",
                "l_sit",
                "wall_push_up",
                "push_up",
                "decline_push_up",
                "planche_lean",
                "pseudo_planche_push_up",
                "tuck_planche",
                "bench_dip",
                "chest_dip",
                "bent_arm_tuck_planche",
                "planche",
            ]
        )
    }

    @Test func progressionChain_unknownExerciseReturnsEmpty() {
        let repository = ExerciseRepository()
        #expect(repository.progressionChain(to: "nonexistent").isEmpty)
    }

    @Test func progressionChain_noPrerequisitesReturnsTargetOnly() {
        let repository = ExerciseRepository()
        let chain = repository.progressionChain(to: "wall_push_up")
        #expect(chain.map(\.id) == ["wall_push_up"])
    }

}
