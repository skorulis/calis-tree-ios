// Created by Alex Skorulis on 22/5/2026.

import Knit
import SwiftUI

struct AvailableEquipmentSection: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
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
}

#Preview {
    let assembler = ExerciseTreeAssembly.testing()
    List {
        AvailableEquipmentSection(
            viewModel: assembler.resolver.settingsViewModel()
        )
    }
}
