// Created by Alex Skorulis on 15/5/2026.

import Foundation

struct Exercise: Codable {
    let name: String
    let level: Level
    let imageFile: String
    let videoURL: String
    let equipment: [Equipment]
}
