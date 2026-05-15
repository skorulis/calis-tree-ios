// Created by Alex Skorulis on 15/5/2026.

import Foundation

nonisolated enum SetType: Codable {
    // Number of reps
    case reps(Int)
    
    // Time in seconds
    case time(Int)

    var intValue: Int {
        switch self {
        case let .reps(value), let .time(value):
            value
        }
    }

    var unitLabel: String {
        switch self {
        case .reps:
            "reps"
        case .time:
            "sec"
        }
    }
}
