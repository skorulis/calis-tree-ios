// Created by Alex Skorulis on 15/5/2026.

import ASKCoordinator
import Foundation

enum MainPath: CoordinatorPath {
    case exerciseList
    case exerciseDetail(Exercise)

    var id: String {
        switch self {
        case .exerciseList:
            "exerciseList"
        case .exerciseDetail(let exercise):
            "exerciseDetail:\(exercise.name)"
        }
    }
}
