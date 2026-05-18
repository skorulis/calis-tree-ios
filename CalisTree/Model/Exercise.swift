// Created by Alex Skorulis on 15/5/2026.

import Foundation

struct FullExercise: Identifiable {
    let exercise: Exercise
    let progression: [ExerciseVariation]
    
    var id: Exercise.ID { exercise.id }
}

struct Exercise: Codable {
    let id: ID
    let name: String?
    let description: String?
    // Steps to perform this exercise 
    let steps: [String]?
    let level: Level
    let imageFile: String?
    let videoURL: String
    let equipment: [Equipment]
    let mastery: SetType?
    let progression: [ID]?
    
    // Exercise IDs that should be mastered before this one
    let prerequisites: [ID]
}

extension Exercise {
    typealias ID = String

    var displayName: String {
        if let name { return name }
        return id
            .split(separator: "_")
            .map { $0.capitalized }
            .joined(separator: " ")
    }

    enum Preview {
        static let pullUp = Exercise(
            id: "pull_up",
            name: "Pull Up",
            description: nil,
            steps: nil,
            level: .beginner,
            imageFile: nil,
            videoURL: "https://www.youtube.com/watch?v=XeErfmGSwfE",
            equipment: [.overheadBar],
            mastery: .reps(20),
            progression: nil,
            prerequisites: []
        )

        static let hangingLSit = Exercise(
            id: "hanging_l_sit",
            name: "Hanging L-Sit",
            description: nil,
            steps: nil,
            level: .beginner,
            imageFile: "l-sit",
            videoURL: "https://www.youtube.com/watch?v=TB4gWro3XaY",
            equipment: [.overheadBar],
            mastery: .time(30),
            progression: nil,
            prerequisites: []
        )

        static let hangingHighKneeRaiseWithoutMastery = Exercise(
            id: "hanging_high_knee_raise",
            name: "Hanging High Knee Raise",
            description: nil,
            steps: nil,
            level: .beginner,
            imageFile: nil,
            videoURL: "https://www.youtube.com/watch?v=oDiqwy0Y964",
            equipment: [.overheadBar],
            mastery: nil,
            progression: nil,
            prerequisites: []
        )
    }
}

struct ExerciseVariation: Codable {
    let id: Exercise.ID
    let name: String
    let description: String?
    let level: Level?
    let mastery: SetType
}
