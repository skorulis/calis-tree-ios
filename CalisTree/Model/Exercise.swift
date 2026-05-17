// Created by Alex Skorulis on 15/5/2026.

import Foundation

struct Exercise: Codable {
    let name: String
    let description: String?
    // Steps to perform this exercise 
    let steps: [String]?
    let level: Level
    let imageFile: String?
    let videoURL: String
    let equipment: [Equipment]
    let mastery: SetType?
    let progression: [ExerciseVariation]?
    
    // Exercises that should be mastered before this one
    let prerequisites: [String]
}

struct ExerciseVariation: Codable {
    let name: String
    let description: String?
    let mastery: SetType
}
