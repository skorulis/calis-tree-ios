// Created by Alex Skorulis on 22/5/2026.

import ASKCoordinator
import Knit
import KnitMacros
import Observation

@MainActor
@Observable
final class OnboardingHowToUseViewModel: CoordinatorViewModel {
    weak var coordinator: Coordinator?

    var bulletPoints: [String] = [
        "Pick your goal exercise, what you hope to achieve",
        "Work through the suggested progression exercises to make sure you're ready to move to the next level",
        "Watch the included videos for tips on how to correctly perform the exercises",
        "Make sure you maintain correct form to prevent injury. Cheating on easier exercises won't prepare you for the next",
        "Once you become comfortable with exercises they become the basis for your repeatable strength training routine",
    ]

    @Resolvable<Resolver>
    init() {}
}

extension OnboardingHowToUseViewModel {
    func continueToEquipment() {
        coordinator?.push(OnboardingPath.equipment)
    }
}
