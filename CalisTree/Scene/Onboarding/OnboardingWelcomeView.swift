// Created by Alex Skorulis on 22/5/2026.

import ASKCoordinator
import Knit
import SwiftUI

struct OnboardingWelcomeView: View {
    @State var viewModel: OnboardingWelcomeViewModel
    @Environment(\.onboardingComplete) private var onboardingComplete

    init(viewModel: OnboardingWelcomeViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Welcome to Exercise Tree")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(
                    "Exercise Tree is a reference guide showing progression schemes for moving from beginner to advanced exercises. It does not give you an exact workout plan, but rather the exercises you may want to incorporate to reach your goals."
                )
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            continueButton
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                closeButton
            }
        }
    }

    private var continueButton: some View {
        Button("Continue") {
            viewModel.continueToHowToUse()
        }
        .buttonStyle(.continueButton)
        .padding(.margin)
    }

    private var closeButton: some View {
        Button {
            onboardingComplete()
        } label: {
            Image(systemName: "xmark")
        }
        .accessibilityLabel("Close")
    }
}

#Preview {
    NavigationStack {
        OnboardingWelcomeView(
            viewModel: ExerciseTreeAssembly.testing().resolver.onboardingWelcomeViewModel()
        )
    }
    .environment(\.coordinator, Coordinator(root: OnboardingPath.welcome))
}
