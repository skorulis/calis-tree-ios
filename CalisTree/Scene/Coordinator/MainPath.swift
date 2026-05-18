// Created by Alex Skorulis on 15/5/2026.

import ASKCoordinator
import Foundation

enum MainPath: CoordinatorPath {
    case exerciseList
    case exerciseDetail(Exercise)
    case exerciseVideo(Exercise)
    case exerciseProgression(Exercise)
    case exerciseProgressionTree(Exercise)
    case terminologyList
    case terminologyDetail(Terminology)

    var id: String {
        switch self {
        case .exerciseList:
            "exerciseList"
        case .exerciseDetail(let exercise):
            "exerciseDetail:\(exercise.id)"
        case .exerciseVideo(let exercise):
            "exerciseVideo:\(exercise.id)"
        case .exerciseProgression(let exercise):
            "exerciseProgression:\(exercise.id)"
        case .exerciseProgressionTree(let exercise):
            "exerciseProgressionTree:\(exercise.id)"
        case .terminologyList:
            "terminologyList"
        case .terminologyDetail(let term):
            "terminologyDetail:\(term.name)"
        }
    }
}
