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

nonisolated struct MasteryProgress: Equatable {
    let current: Int
    let target: Int

    var fraction: Double {
        guard target > 0 else { return 1 }
        return min(1, Double(current) / Double(target))
    }
}

nonisolated struct ExerciseProgress: Equatable {
    var main: MasteryProgress?
    var progression: [String: MasteryProgress]
    
    static var none: ExerciseProgress {
        return .init(main: nil, progression: [:])
    }
    
    var progressionMastery: Double {
        progression.values.map(\.fraction).reduce(0, +) / Double(progression.count)
    }
    
    var fraction: Double {
        if main == nil && progression.count == 0 {
            return 0
        }
        guard let main else {
            return progressionMastery
        }
        let allMastery = (progression.values.map(\.fraction).reduce(0, +) + main.fraction) / Double(progression.count + 1)
        return max(allMastery, main.fraction)
    }
}
