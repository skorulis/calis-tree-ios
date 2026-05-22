// Created by Alex Skorulis on 22/5/2026.

import ASKCoordinator
import Knit
import SwiftUI

struct OnboardingHowToUseView: View {
    @State var viewModel: OnboardingHowToUseViewModel
    @Environment(\.onboardingComplete) private var onboardingComplete

    init(viewModel: OnboardingHowToUseViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("How to use")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.bulletPoints, id: \.self) { point in
                        HStack(alignment: .top, spacing: 10) {
                            Text("•")
                            Text(point)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
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
            viewModel.continueToEquipment()
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
        OnboardingHowToUseView(
            viewModel: CalisTreeAssembly.testing().resolver.onboardingHowToUseViewModel()
        )
    }
    .environment(\.coordinator, Coordinator(root: OnboardingPath.howToUse))
}
