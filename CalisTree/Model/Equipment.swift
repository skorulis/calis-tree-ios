// Created by Alex Skorulis on 15/5/2026.

import Foundation
import SwiftUI

enum Equipment: String, Codable, CaseIterable {
    case captainsChair
    case overheadBar
    case parallelBars
    case paralletteBars
    case rings
    case bench
    case verticalBar
    case lowBar
    case dumbbells
    case barbell
    
    var name: String {
        switch self {
        case .barbell: "Barbell"
        case .captainsChair: "Captains Chair"
        case .overheadBar: "Overhead Bar"
        case .parallelBars: "Parallel Bars"
        case .paralletteBars: "Parallette Bars"
        case .rings: "Rings"
        case .bench: "Bench"
        case .verticalBar: "Vertical Bar"
        case .lowBar: "Low Bar"
        case .dumbbells: "Dumbbells"
        }
    }

    var description: String {
        switch self {
        case .barbell:
            "A long metal bar with weights plates on each end."
        case .captainsChair:
            "A station with padded armrests and back support. Lets you brace your forearms for leg raises and core work without hanging from a bar."
        case .overheadBar:
            "A fixed horizontal bar mounted above your head. Used for pull-ups, chin-ups, and other hanging skills."
        case .parallelBars:
            "Two sturdy horizontal bars set side by side at about chest height. Used for dips, support holds, and pushing skills."
        case .paralletteBars:
            "Short parallel bars close to the ground, often portable. Used for push-ups, L-sits, and planche progressions."
        case .rings:
            "Gymnastic rings hung from straps that can swing and rotate. Adds instability for rows, dips, and advanced holds."
        case .bench:
            "A flat or padded raised surface, or a sturdy chair. Used for dips, elevated push-ups, and support during rows or core work."
        case .verticalBar:
            "A vertical pole or upright bar you grip with both hands. Used for flag-style skills and leverage moves along the post."
        case .lowBar:
            "A horizontal bar set around waist to chest height. Used for inverted rows and moves you can reach without jumping."
        case .dumbbells:
            "Hand-held weights you lift one or both at a time. Add resistance to squats, presses, rows, and similar exercises."
        }
    }

    var chipColor: Color {
        .secondary
    }
}
