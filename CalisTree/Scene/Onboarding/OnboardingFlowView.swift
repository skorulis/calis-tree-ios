// Created by Alex Skorulis on 22/5/2026.

import ASKCoordinator
import Knit
import SwiftUI

struct OnboardingFlowView: View {
    let resolver: Resolver
    let onComplete: () -> Void

    var body: some View {
        CoordinatorView(
            coordinator: Coordinator(root: OnboardingPath.welcome),
        )
        .withRenderers(resolver: resolver)
        .environment(\.onboardingComplete, onComplete)
    }
}

#Preview {
    let assembler = CalisTreeAssembly.testing()
    OnboardingFlowView(
        resolver: assembler.resolver,
        onComplete: {}
    )
}
