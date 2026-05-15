// Created by Alex Skorulis on 15/5/2026.

import Foundation

nonisolated enum SetType: Codable {
    // Number of reps
    case reps(Int)
    
    // Time in seconds
    case time(Int)
}
