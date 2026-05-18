// Created by Alex Skorulis on 19/5/2026.

import ASKCoordinator
import Knit
import SwiftUI

struct SettingsView: View {
    @State var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            Section {
                ForEach(viewModel.equipmentItems, id: \.self) { equipment in
                    Toggle(
                        equipment.description,
                        isOn: viewModel.availabilityBinding(for: equipment)
                    )
                }
            } header: {
                Text("Available equipment")
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView(
            viewModel: CalisTreeAssembly.testing().resolver.settingsViewModel()
        )
    }
    .environment(\.coordinator, Coordinator(root: MainPath.settings))
}
