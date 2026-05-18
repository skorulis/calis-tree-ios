// Created by Alex Skorulis on 19/5/2026.

import SwiftUI

private struct TerminologyLinkIndexKey: EnvironmentKey {
    static let defaultValue = TerminologyLinkIndex.empty
}

extension EnvironmentValues {
    var terminologyLinkIndex: TerminologyLinkIndex {
        get { self[TerminologyLinkIndexKey.self] }
        set { self[TerminologyLinkIndexKey.self] = newValue }
    }
}
