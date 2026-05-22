// Created by Alex Skorulis on 22/5/2026.

import ASKCoordinator
import Knit
import SwiftUI

struct OnboardingPathRenderer: CoordinatorPathRenderer {
    typealias PathType = OnboardingPath

    let resolver: Resolver

    @ViewBuilder @MainActor
    func render(path: OnboardingPath, in coordinator: Coordinator) -> some View {
        switch path {
        case .welcome:
            OnboardingWelcomeView(
                viewModel: coordinator.apply(resolver.onboardingWelcomeViewModel())
            )
        case .howToUse:
            OnboardingHowToUseView(
                viewModel: coordinator.apply(resolver.onboardingHowToUseViewModel())
            )
        case .equipment:
            OnboardingEquipmentView(
                viewModel: coordinator.apply(resolver.onboardingEquipmentViewModel()),
                settingsViewModel: resolver.settingsViewModel()
            )
        }
    }
}
