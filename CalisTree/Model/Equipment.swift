// Created by Alex Skorulis on 15/5/2026.

import Foundation

enum Equipment: String, Codable, CaseIterable {
    case overheadBar
    case parallelBars
    case floor
    case wall
    case raisedSurface
    
    var description: String {
        switch self {
        case .overheadBar: "Overhead Bar"
        case .parallelBars: "Parallel Bars"
        case .floor: "Floor"
        case .wall: "Wall"
        case .raisedSurface: "Raised Surface"
        }
    }
}
