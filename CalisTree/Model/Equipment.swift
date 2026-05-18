// Created by Alex Skorulis on 15/5/2026.

import Foundation

enum Equipment: String, Codable, CaseIterable {
    case captainsChair
    case overheadBar
    case parallelBars
    case paralletteBars
    case floor
    case wall
    case rings
    case raisedSurface
    case verticalBar
    case lowBar
    
    var description: String {
        switch self {
        case .captainsChair: "Captains Chair"
        case .overheadBar: "Overhead Bar"
        case .parallelBars: "Parallel Bars"
        case .paralletteBars: "Parallette Bars"
        case .floor: "Floor"
        case .rings: "Rings"
        case .wall: "Wall"
        case .raisedSurface: "Raised Surface"
        case .verticalBar: "Vertical Bar"
        case .lowBar: "Low Bar"
        }
    }
}
