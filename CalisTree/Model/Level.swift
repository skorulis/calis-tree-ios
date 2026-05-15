// Created by Alex Skorulis on 15/5/2026.

import Foundation

enum Level: String, Codable {
    case foundations
    case beginner
    case intermediate
    case advanced
    case extreme

    var displayTitle: String {
        rawValue.capitalized
    }
}
