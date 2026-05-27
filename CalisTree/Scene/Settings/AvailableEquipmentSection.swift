// Created by Alex Skorulis on 22/5/2026.

import Knit
import SwiftUI

struct AvailableEquipmentSection: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        ForEach(viewModel.equipmentSections) { section in
            Section {
                ForEach(section.items, id: \.self) { equipment in
                    Toggle(
                        isOn: viewModel.availabilityBinding(for: equipment)
                    ) {
                        AvailableEquipmentRow(equipment: equipment)
                    }
                }
            } header: {
                Text(section.category.name)
            }
        }
    }
}

private struct AvailableEquipmentRow: View {
    let equipment: Equipment

    var body: some View {
        HStack(spacing: 12) {
            EquipmentAvatar(equipment: equipment)
            VStack(alignment: .leading, spacing: 4) {
                Text(equipment.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(equipment.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
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
