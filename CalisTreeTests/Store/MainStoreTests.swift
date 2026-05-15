// Created by Alex Skorulis on 15/5/2026.

import ASKCore
import Foundation
import Testing
@testable import CalisTree

@MainActor
struct MainStoreTests {

    @Test func masteryProgressPersistsAcrossInstances() {
        let keyValueStore = InMemoryDefaults()
        let first = MainStore(keyValueStore: keyValueStore)
        first.setMasteryProgress(12, for: "Hanging L-Sit")

        let second = MainStore(keyValueStore: keyValueStore)
        #expect(second.masteryProgress(for: "Hanging L-Sit") == 12)
    }

}
