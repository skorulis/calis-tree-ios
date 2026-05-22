//  Created by Alex Skorulis on 15/5/2026.

import ASKCore
import Knit
import SwiftUI

@main
struct CalisTreeApp: App {
    
    private let assembler: ScopedModuleAssembler<Resolver> = {
        let assembler = ScopedModuleAssembler<Resolver>(
            [
                ExerciseTreeAssembly(purpose: .normal)
            ]
        )
        return assembler
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView(resolver: assembler.resolver)
        }
    }
}
