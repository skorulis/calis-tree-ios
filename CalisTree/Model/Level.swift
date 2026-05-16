// Created by Alex Skorulis on 15/5/2026.

import Foundation
import SwiftUI

enum Level: String, Codable, CaseIterable {
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
}
