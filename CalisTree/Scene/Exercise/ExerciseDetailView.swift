// Created by Alex Skorulis on 15/5/2026.

import ASKCore
import SwiftUI

struct ExerciseDetailView: View {
    @State var viewModel: ExerciseDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.exercise.level.displayTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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
    let mainStore = MainStore(keyValueStore: InMemoryDefaults())
    let exercise = Exercise(
        name: "Hanging L-Sit",
        description: "Hang from the bar in an l sit position",
        level: .beginner,
        imageFile: "l-sit",
        videoURL: "https://www.youtube.com/watch?v=TB4gWro3XaY",
        equipment: [.overheadBar],
        mastery: .time(20),
        prerequisites: [
            "Pull Up",
        ]
    )
    return NavigationStack {
        ExerciseDetailView(
            viewModel: ExerciseDetailViewModel(
                mainStore: mainStore,
                exercise: exercise
            )
        )
    }
}
