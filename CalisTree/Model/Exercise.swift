// Created by Alex Skorulis on 15/5/2026.

import Foundation

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
    let progression: [ExerciseVariation]?
    
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
}

struct ExerciseVariation: Codable {
    let id: Exercise.ID
    let name: String
    let description: String?
    let mastery: SetType
}
