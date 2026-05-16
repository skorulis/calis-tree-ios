// Created by Alex Skorulis on 16/5/2026.

import ASKCoordinator
import Foundation
import Knit
import KnitMacros
import Observation

@MainActor
@Observable
final class TerminologyListViewModel: CoordinatorViewModel {
    private let repository: TerminologyRepository

    weak var coordinator: Coordinator?

    @Resolvable<Resolver>
    init(repository: TerminologyRepository) {
        self.repository = repository
    }

    var terms: [Terminology] {
        repository.terms.sorted {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }

    func showDetails(_ term: Terminology) {
        coordinator?.push(MainPath.terminologyDetail(term))
    }
}
