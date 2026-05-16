//  Created by Alex Skorulis on 15/5/2026.

import ASKCore
import Foundation
import Knit

final class CalisTreeAssembly: AutoInitModuleAssembly {
    static var dependencies: [any Knit.ModuleAssembly.Type] { [] }
    typealias TargetResolver = Resolver

    private let purpose: IOCPurpose

    init() {
        self.purpose = .testing
    }

    init(purpose: IOCPurpose) {
        self.purpose = purpose
    }

    @MainActor func assemble(container: Container<TargetResolver>) {
        ASKCoreAssembly(purpose: purpose).assemble(container: container)

        registerServices(container: container)
        registerStores(container: container)
        registerViewModels(container: container)
    }

    @MainActor
    private func registerServices(container: Container<TargetResolver>) {
        container.register(ExerciseRepository.self) { _ in
            ExerciseRepository()
        }
        .inObjectScope(.container)

        container.register(TerminologyRepository.self) { _ in
            TerminologyRepository()
        }
        .inObjectScope(.container)
    }

    @MainActor
    private func registerStores(container: Container<TargetResolver>) {
        container.register(MainStore.self) { MainStore.make(resolver: $0) }
            .inObjectScope(.container)
    }

    @MainActor
    private func registerViewModels(container: Container<TargetResolver>) {
        container.register(MainPathRenderer.self) { MainPathRenderer(resolver: $0) }
        
        container.register(ExerciseDetailViewModel.self) { (resolver: Resolver, exercise: Exercise) in
            ExerciseDetailViewModel.make(resolver: resolver, exercise: exercise)
        }

        container.register(ExerciseListViewModel.self) { (resolver: Resolver) in
            ExerciseListViewModel.make(resolver: resolver)
        }

        container.register(TerminologyDetailViewModel.self) { (resolver: Resolver, terminology: Terminology) in
            TerminologyDetailViewModel.make(resolver: resolver, terminology: terminology)
        }

        container.register(TerminologyListViewModel.self) { (resolver: Resolver) in
            TerminologyListViewModel.make(resolver: resolver)
        }
    }
}

extension CalisTreeAssembly {
    @MainActor static func testing() -> ScopedModuleAssembler<Resolver> {
        ScopedModuleAssembler<Resolver>([CalisTreeAssembly()])
    }
}

