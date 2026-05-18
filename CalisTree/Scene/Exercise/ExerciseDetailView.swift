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
                Chip(level: viewModel.exercise.safeLevel)
                
                prerequisiteSection
                
                stepsSection
                progressionSection
                masterySection
                
                videoPlayButton
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Equipment")
                        .font(.headline)
                    ForEach(viewModel.exercise.equipment, id: \.self) { item in
                        Text(item.description)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.margin)
        }
        .navigationTitle(viewModel.exercise.displayName)
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
    private var stepsSection: some View {
        if let steps = viewModel.exercise.steps, !steps.isEmpty {
            DisclosureGroup(isExpanded: $isStepsExpanded) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(index + 1).")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(minWidth: 20, alignment: .trailing)
                            TerminologyLinkedText(text: step) { term in
                                coordinator?.push(MainPath.terminologyDetail(term))
                            }
                        }
                    }
                }
                .padding(.top, 4)
            } label: {
                Text("Steps")
                    .font(.headline)
            }
        }
    }
    
    private var videoPlayButton: some View {
        Button {
            coordinator?.push(MainPath.exerciseVideo(viewModel.exercise))
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                    .aspectRatio(16 / 9, contentMode: .fit)
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 72))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Play video")
    }

    @ViewBuilder
    private var prerequisiteSection: some View {
        if !viewModel.prerequisiteItems.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Button {
                    coordinator?.push(MainPath.exerciseProgression(viewModel.exercise))
                } label: {
                    HStack {
                        Text("Progression")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .contentShape(Rectangle())
                    
                }
                .buttonStyle(.plain)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(sortedPrerequisiteItems) { item in
                            Button {
                                coordinator?.push(MainPath.exerciseDetail(item.exercise))
                            } label: {
                                ExerciseAvatar(
                                    exercise: item.exercise,
                                    masteryProgress: item.masteryProgress,
                                    showName: true
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, .margin)
                }
                .padding(.horizontal, -CGFloat.margin)
            }
        }
    }
    
    @ViewBuilder
    private var progressionSection: some View {
        if !viewModel.progressionItems.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.progressionItems) { item in
                    progressionItem(for: item)
                }
            }
        }
    }
    
    private func progressionItem(for item: ProgressionStepItem) -> some View {
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
        return item.masteryProgress.fraction
    }

    private var sortedPrerequisiteItems: [PrerequisiteItem] {
        viewModel.prerequisiteItems.sorted { lhs, rhs in
            let l = prerequisiteCompletenessFraction(lhs)
            let r = prerequisiteCompletenessFraction(rhs)
            if l != r { return l < r }
            if lhs.exercise.safeLevel != rhs.exercise.safeLevel {
                return lhs.exercise.safeLevel < rhs.exercise.safeLevel
            }
            return lhs.exercise.displayName < rhs.exercise.displayName
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
    .environment(
        \.terminologyLinkIndex,
        assembler.resolver.terminologyRepository().linkIndex
    )
}
