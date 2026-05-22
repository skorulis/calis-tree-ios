// Created by Alex Skorulis on 22/5/2026.

import ASKCoordinator
import Knit
import SwiftUI

struct OnboardingEquipmentView: View {
    @State var viewModel: OnboardingEquipmentViewModel
    @State var settingsViewModel: SettingsViewModel
    @Environment(\.onboardingComplete) private var onboardingComplete

    init(
        viewModel: OnboardingEquipmentViewModel,
        settingsViewModel: SettingsViewModel
    ) {
        self._viewModel = State(initialValue: viewModel)
        self._settingsViewModel = State(initialValue: settingsViewModel)
    }

    var body: some View {
        List {
            AvailableEquipmentSection(viewModel: settingsViewModel)
        }
        .navigationTitle("Available equipment")
        .safeAreaInset(edge: .bottom) {
            doneButton
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                closeButton
            }
        }
    }

    private var doneButton: some View {
        Button("Done") {
            onboardingComplete()
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
        let assembler = CalisTreeAssembly.testing()
        OnboardingEquipmentView(
            viewModel: assembler.resolver.onboardingEquipmentViewModel(),
            settingsViewModel: assembler.resolver.settingsViewModel()
        )
    }
    .environment(\.coordinator, Coordinator(root: OnboardingPath.equipment))
}
