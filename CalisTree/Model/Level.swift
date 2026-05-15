// Created by Alex Skorulis on 15/5/2026.

import Foundation
import SwiftUI

enum Level: String, Codable {
    case foundation
    case beginner
    case intermediate
    case advanced
    case extreme

    var displayTitle: String {
        rawValue.capitalized
    }

    var chipColor: Color {
        switch self {
        case .foundation:
            Color(red: 0.45, green: 0.48, blue: 0.52)
        case .beginner:
            Color(red: 0.2, green: 0.65, blue: 0.45)
        case .intermediate:
            Color(red: 0.25, green: 0.45, blue: 0.85)
        case .advanced:
            Color(red: 0.9, green: 0.5, blue: 0.15)
        case .extreme:
            Color(red: 0.85, green: 0.25, blue: 0.3)
        }
    }
}
