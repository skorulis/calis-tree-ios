// Created by Alex Skorulis on 15/5/2026.

import Foundation
import SwiftUI

enum Equipment: String, Codable, CaseIterable {
    case captainsChair
    case overheadBar
    case parallelBars
    case paralletteBars
    case rings
    case raisedSurface
    case verticalBar
    case lowBar
    case dumbbells
    
    var description: String {
        switch self {
        case .captainsChair: "Captains Chair"
        case .overheadBar: "Overhead Bar"
        case .parallelBars: "Parallel Bars"
        case .paralletteBars: "Parallette Bars"
        case .rings: "Rings"
        case .raisedSurface: "Raised Surface"
        case .verticalBar: "Vertical Bar"
        case .lowBar: "Low Bar"
        case .dumbbells: "Dumbbells"
        }
    }

    var chipColor: Color {
        .secondary
    }
}
