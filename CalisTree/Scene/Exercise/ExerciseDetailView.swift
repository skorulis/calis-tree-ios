// Created by Alex Skorulis on 15/5/2026.

import ASKCore
import Knit
import SwiftUI

struct ExerciseDetailView: View {
    @State var viewModel: ExerciseDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.exercise.level.displayTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !viewModel.prerequisiteItems.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Prerequisites")
                            .font(.headline)
                        HStack(spacing: 12) {
                            ForEach(viewModel.prerequisiteItems) { item in
                                ExerciseAvatar(
                                    exercise: item.exercise,
                                    masteryProgress: item.masteryProgress
                                )
                            }
                        }
                    }
                }
                YouTubeEmbedView(videoURL: viewModel.exercise.videoURL)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
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
    }
}

#Preview {
    let assembler = CalisTreeAssembly.testing()
    let exercise = assembler.resolver.exerciseRepository().exerciseByName["Tuck front lever hold"]!
    NavigationStack {
        ExerciseDetailView(
            viewModel: assembler.resolver.exerciseDetailViewModel(exercise: exercise)
        )
    }
}
