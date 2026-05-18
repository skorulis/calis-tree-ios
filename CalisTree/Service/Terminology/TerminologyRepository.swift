// Created by Alex Skorulis on 16/5/2026.

import Foundation

final class TerminologyRepository {
    let terms: [Terminology]
    let termByName: [String: Terminology]
    let linkIndex: TerminologyLinkIndex

    init(bundle: Bundle = .main) {
        let url =
            bundle.url(forResource: "terminology", withExtension: "json", subdirectory: "Resource")
            ?? bundle.url(forResource: "terminology", withExtension: "json")
        guard let url else {
            assertionFailure("terminology.json not found in bundle")
            self.terms = []
            self.termByName = [:]
            self.linkIndex = .empty
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let terms = try JSONDecoder().decode([Terminology].self, from: data)
            self.terms = terms
            self.termByName = Dictionary(uniqueKeysWithValues: terms.map { ($0.name, $0) })
            self.linkIndex = TerminologyLinkIndex(terms: terms)
        } catch {
            assertionFailure("Failed to load terminology: \(error)")
            self.terms = []
            self.termByName = [:]
            self.linkIndex = .empty
        }
    }
}
