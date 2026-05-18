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
    case settings
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
            settings
                .tag(RootTab.settings)
        }
        .environment(
            \.terminologyLinkIndex,
            resolver.terminologyRepository().linkIndex
        )
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

    private var settings: some View {
        CoordinatorView(
            coordinator: Coordinator(root: MainPath.settings),
            renderers: [],
            useNavigationStack: true,
        )
        .withRenderers(resolver: resolver)
        .tabItem {
            Label("Settings", systemImage: "gearshape")
        }
    }
}

#Preview {
    ContentView(resolver: CalisTreeAssembly.testing().resolver)
}
