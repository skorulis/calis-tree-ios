// Created by Alex Skorulis on 22/5/2026.

import SwiftUI

private struct OnboardingCompleteKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var onboardingComplete: () -> Void {
        get { self[OnboardingCompleteKey.self] }
        set { self[OnboardingCompleteKey.self] = newValue }
    }
}
