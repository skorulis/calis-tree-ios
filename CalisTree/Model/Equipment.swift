// Created by Alex Skorulis on 15/5/2026.

import Foundation

enum Equipment: String, Codable {
    case overheadBar
    case parallelBars
    case floor
    case wall
    
    var description: String {
        switch self {
        case .overheadBar:
            return "Overhead Bar"
        case .parallelBars:
            return "Parallel Bars"
        case .floor:
            return "Floor"
        case .wall:
            return "Wall"
        }
    }
}
