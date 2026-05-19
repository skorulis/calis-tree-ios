// Created by Alex Skorulis on 19/5/2026.

import SwiftUI

struct ExerciseListFilterView: View {
    @Binding var filterLevel: Level?
    @Binding var filterEquipment: Equipment?
    @Binding var filterProgress: ExerciseProgressFilter?
    let hasActiveFilters: Bool
    let onClear: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Level") {
                    filterRow(title: "All levels", isSelected: filterLevel == nil) {
                        filterLevel = nil
                    }
                    ForEach(Level.allCases, id: \.self) { level in
                        filterRow(
                            title: level.displayTitle,
                            isSelected: filterLevel == level
                        ) {
                            filterLevel = level
                        }
                    }
                }

                Section("Equipment") {
                    filterRow(title: "All equipment", isSelected: filterEquipment == nil) {
                        filterEquipment = nil
                    }
                    ForEach(Equipment.allCases, id: \.self) { equipment in
                        filterRow(
                            title: equipment.description,
                            isSelected: filterEquipment == equipment
                        ) {
                            filterEquipment = equipment
                        }
                    }
                }

                Section("Status") {
                    filterRow(title: "All statuses", isSelected: filterProgress == nil) {
                        filterProgress = nil
                    }
                    ForEach(ExerciseProgressFilter.allCases, id: \.self) { status in
                        filterRow(
                            title: status.menuTitle,
                            isSelected: filterProgress == status
                        ) {
                            filterProgress = status
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if hasActiveFilters {
                        Button("Clear") {
                            onClear()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func filterRow(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    @Previewable @State var filterLevel: Level? = .beginner
    @Previewable @State var filterEquipment: Equipment?
    @Previewable @State var filterProgress: ExerciseProgressFilter? = .inProgress

    ExerciseListFilterView(
        filterLevel: $filterLevel,
        filterEquipment: $filterEquipment,
        filterProgress: $filterProgress,
        hasActiveFilters: filterLevel != nil || filterEquipment != nil || filterProgress != nil,
        onClear: {
            filterLevel = nil
            filterEquipment = nil
            filterProgress = nil
        }
    )
}
