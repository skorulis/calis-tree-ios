// Created by Alex Skorulis on 15/5/2026.

import Foundation

struct Exercise: Codable {
    let name: String
    let description: String?
    let level: Level
    let imageFile: String?
    let videoURL: String
    let equipment: [Equipment]
    let mastery: SetType?
    
    // Exercises that should be mastered before this one
    let prerequisites: [String]
}
