//
//  ContentView.swift
//  CalisTree
//
//  Created by Alex Skorulis on 15/5/2026.
//

import ASKCoordinator
import Knit
import SwiftUI

struct ContentView: View {
    let resolver: Resolver

    var body: some View {
        TabView {
            exercises
        }
    }
    
    private var exercises: some View {
        CoordinatorView(
            coordinator: Coordinator(root: MainPath.exerciseList),
            renderers: [],
            useNavigationStack: true,
        )
        .withRenderers(resolver: resolver)
        .tabItem {
            Label("Exercises", systemImage: "figure.strengthtraining.traditional")
        }
    }
}

#Preview {
    ContentView(resolver: CalisTreeAssembly.testing().resolver)
}
