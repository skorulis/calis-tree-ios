// Created by Alex Skorulis on 15/5/2026.

import Foundation
import SwiftUI

enum Level: String, Codable, CaseIterable, Comparable {
    case foundation
    case beginner
    case intermediate
    case advanced
    case expert

    var displayTitle: String {
        rawValue.capitalized
    }

    var chipColor: Color {
        switch self {
        case .foundation:
            Palette.Level.foundation
        case .beginner:
            Palette.Level.beginner
        case .intermediate:
            Palette.Level.intermediate
        case .advanced:
            Palette.Level.advanced
        case .expert:
            Palette.Level.expert
        }
    }

    var subtleBackgroundColor: Color {
        chipColor.opacity(0.18)
    }

    static func < (lhs: Level, rhs: Level) -> Bool {
        guard let lhsIndex = allCases.firstIndex(of: lhs),
              let rhsIndex = allCases.firstIndex(of: rhs)
        else { return false }
        return lhsIndex < rhsIndex
    }
}
