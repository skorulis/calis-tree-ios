// Created by Alex Skorulis on 19/5/2026.

import Foundation
import Knit
import KnitMacros
import Observation
import SwiftUI

@MainActor
@Observable
final class SettingsViewModel {
    private let mainStore: MainStore

    @Resolvable<Resolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
    }

    var equipmentItems: [Equipment] {
        Equipment.allCases.sorted {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }

    func availabilityBinding(for equipment: Equipment) -> Binding<Bool> {
        Binding(
            get: { self.mainStore.isEquipmentAvailable(equipment) },
            set: { self.mainStore.setEquipmentAvailable($0, for: equipment) }
        )
    }
}
