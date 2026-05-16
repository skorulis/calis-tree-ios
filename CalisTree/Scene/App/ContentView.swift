//
//  ContentView.swift
//  CalisTree
//
//  Created by Alex Skorulis on 15/5/2026.
//

import ASKCoordinator
import Knit
import SwiftUI

private enum RootTab: Hashable {
    case exercises
    case timer
    case terminology
}

struct ContentView: View {
    let resolver: Resolver
    @State private var selectedTab: RootTab = .exercises

    var body: some View {
        TabView(selection: $selectedTab) {
            exercises
                .tag(RootTab.exercises)
            timer
                .tag(RootTab.timer)
            terminology
                .tag(RootTab.terminology)
        }
    }

    private var timer: some View {
        NavigationStack {
            TimerView(voiceListeningShouldBeActive: selectedTab == .timer)
                .navigationTitle("Timer")
        }
        .tabItem {
            Label("Timer", systemImage: "stopwatch")
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

    private var terminology: some View {
        CoordinatorView(
            coordinator: Coordinator(root: MainPath.terminologyList),
            renderers: [],
            useNavigationStack: true,
        )
        .withRenderers(resolver: resolver)
        .tabItem {
            Label("Terminology", systemImage: "book.closed")
        }
    }
}

#Preview {
    ContentView(resolver: CalisTreeAssembly.testing().resolver)
}
