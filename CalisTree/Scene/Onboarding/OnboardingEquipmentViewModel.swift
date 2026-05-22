// Created by Alex Skorulis on 22/5/2026.

import ASKCoordinator
import Knit
import KnitMacros
import Observation

@MainActor
@Observable
final class OnboardingEquipmentViewModel: CoordinatorViewModel {
    weak var coordinator: Coordinator?

    @Resolvable<Resolver>
    init() {}
}
