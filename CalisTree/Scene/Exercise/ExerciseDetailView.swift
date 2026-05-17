// Created by Alex Skorulis on 15/5/2026.

import ASKCoordinator
import ASKCore
import Knit
import SwiftUI

struct ExerciseDetailView: View {
    @State var viewModel: ExerciseDetailViewModel
    @State private var isStepsExpanded = false
    @Environment(\.coordinator) private var coordinator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Chip(level: viewModel.exercise.level)
                
                prerequisiteSection
                
                if let steps = viewModel.exercise.steps, !steps.isEmpty {
                    DisclosureGroup(isExpanded: $isStepsExpanded) {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("\(index + 1).")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .frame(minWidth: 20, alignment: .trailing)
                                    Text(step)
                                }
                            }
                        }
                        .padding(.top, 4)
                    } label: {
                        Text("Steps")
                            .font(.headline)
                    }
                }
                progressionSection
                masterySection
                
                YouTubeEmbedView(videoURL: viewModel.exercise.videoURL)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Equipment")
                        .font(.headline)
                    ForEach(viewModel.exercise.equipment, id: \.self) { item in
                        Text(item.description)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle(viewModel.exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.isFavorite.toggle()
                } label: {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(viewModel.isFavorite ? Color.red : Color.primary)
                }
                .accessibilityLabel(
                    viewModel.isFavorite ? "Remove from favorites" : "Add to favorites"
                )
            }
        }
    }
    
    @ViewBuilder
    private var prerequisiteSection: some View {
        if !viewModel.prerequisiteItems.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Button {
                    coordinator?.push(MainPath.exerciseProgression(viewModel.exercise))
                } label: {
                    Text("Prerequisites")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
                HStack(spacing: 12) {
                    ForEach(sortedPrerequisiteItems) { item in
                        Button {
                            coordinator?.push(MainPath.exerciseDetail(item.exercise))
                        } label: {
                            ExerciseAvatar(
                                exercise: item.exercise,
                                masteryProgress: item.masteryProgress
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var progressionSection: some View {
        if !viewModel.progressionItems.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.progressionItems) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(item.variation.name)")
                            .font(.headline)
                        if let description = item.variation.description {
                            Text(description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Slider(
                            value: Binding(
                                get: {
                                    Double(viewModel.progressionMasteryProgress(for: item.variation.id))
                                },
                                set: {
                                    viewModel.setProgressionMasteryProgress(
                                        Int($0.rounded()),
                                        for: item.variation.id
                                    )
                                }
                            ),
                            in: 0...Double(item.variation.mastery.intValue),
                            step: 1
                        )
                        Text(viewModel.progressionMasteryLabel(for: item.variation))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        stepArrow
                    }
                }
            }
        }
    }
    
    private var stepArrow: some View {
        HStack {
            Spacer()
            Image(systemName: "arrowshape.down")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .foregroundStyle(.gray)
            Spacer()
        }
    }

    @ViewBuilder
    private var masterySection: some View {
        if viewModel.showsMastery, let target = viewModel.masteryTarget {
            VStack(alignment: .leading, spacing: 8) {
                Text("Mastery")
                    .font(.headline)
                Slider(
                    value: Binding(
                        get: { Double(viewModel.masteryProgress) },
                        set: { viewModel.masteryProgress = Int($0.rounded()) }
                    ),
                    in: 0...Double(target.intValue),
                    step: 1
                )
                Text(viewModel.masteryLabel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    /// Fraction toward mastery (`0…1`). Exercises without a mastery goal count as complete (`1`).
    private func prerequisiteCompletenessFraction(_ item: PrerequisiteItem) -> Double {
        guard let mastery = item.exercise.mastery else { return 1 }
        return item.masteryProgress.fraction
    }

    private var sortedPrerequisiteItems: [PrerequisiteItem] {
        viewModel.prerequisiteItems.sorted { lhs, rhs in
            let l = prerequisiteCompletenessFraction(lhs)
            let r = prerequisiteCompletenessFraction(rhs)
            if l != r { return l < r }
            return lhs.exercise.name < rhs.exercise.name
        }
    }
}

#Preview {
    let assembler = CalisTreeAssembly.testing()
    let exercise = assembler.resolver.exerciseRepository().exerciseById["elbow_lever"]!
    NavigationStack {
        ExerciseDetailView(
            viewModel: assembler.resolver.exerciseDetailViewModel(exercise: exercise)
        )
    }
    .environment(\.coordinator, Coordinator(root: MainPath.exerciseList))
}
