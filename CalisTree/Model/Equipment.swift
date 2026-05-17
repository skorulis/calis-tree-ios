// Created by Alex Skorulis on 15/5/2026.

import Foundation

enum Equipment: String, Codable, CaseIterable {
    case overheadBar
    case parallelBars
    case paralletteBars
    case floor
    case wall
    case raisedSurface
    case verticalBar
    
    var description: String {
        switch self {
        case .overheadBar: "Overhead Bar"
        case .parallelBars: "Parallel Bars"
        case .paralletteBars: "Parallette Bars"
        case .floor: "Floor"
        case .wall: "Wall"
        case .raisedSurface: "Raised Surface"
        case .verticalBar: "Vertical Bar"
        }
    }
}
