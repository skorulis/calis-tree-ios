// Created by Alex Skorulis on 15/5/2026.

import ASKCoordinator
import Foundation

enum MainPath: CoordinatorPath {
    case exercises
    
    var id: String {
        switch self {
        case .exercises: "exercises"
        }
    }
}
