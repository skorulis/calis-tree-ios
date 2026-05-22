// Created by Alex Skorulis on 22/5/2026.

import ASKCoordinator
import Foundation

enum OnboardingPath: CoordinatorPath {
    case welcome
    case howToUse
    case equipment

    var id: String {
        switch self {
        case .welcome:
            "onboardingWelcome"
        case .howToUse:
            "onboardingHowToUse"
        case .equipment:
            "onboardingEquipment"
        }
    }
}
