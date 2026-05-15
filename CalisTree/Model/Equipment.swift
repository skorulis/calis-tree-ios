// Created by Alex Skorulis on 15/5/2026.

import Foundation

enum Equipment: String, Codable {
    case overheadBar
    case parallelBars
    
    var description: String {
        switch self {
        case .overheadBar:
            return "Overhead Bar"
        case .parallelBars:
            return "Parallel Bars"
        }
    }
}
