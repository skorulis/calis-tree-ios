// Created by Alex Skorulis on 16/5/2026.

import Foundation
import Knit
import KnitMacros
import Observation

@MainActor
@Observable
final class TerminologyDetailViewModel {
    let terminology: Terminology

    @Resolvable<Resolver>
    init(@Argument terminology: Terminology) {
        self.terminology = terminology
    }
}
