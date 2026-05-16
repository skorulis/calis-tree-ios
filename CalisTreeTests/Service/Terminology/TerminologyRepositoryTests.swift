// Created by Alex Skorulis on 16/5/2026.

import Foundation
import Testing
@testable import CalisTree

struct TerminologyRepositoryTests {

    @Test func loadsTerms() {
        let repository = TerminologyRepository()
        #expect(!repository.terms.isEmpty)
    }

    @Test func termNamesAreUnique() {
        let repository = TerminologyRepository()
        let names = repository.terms.map(\.name)
        #expect(names.count == Set(names).count)
    }

    @Test func termByNameMatchesTerms() {
        let repository = TerminologyRepository()
        for term in repository.terms {
            #expect(repository.termByName[term.name]?.details == term.details)
        }
    }
}
