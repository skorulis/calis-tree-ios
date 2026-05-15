// Created by Alex Skorulis on 15/5/2026.

import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {                
                Text(exercise.level.displayTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                YouTubeEmbedView(videoURL: exercise.videoURL)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 8) {
                    Text("Equipment")
                        .font(.headline)
                    ForEach(exercise.equipment, id: \.self) { item in
                        Text(item.description)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ExerciseDetailView(
            exercise: Exercise(
                name: "Hanging L-Sit",
                description: "Hang from the bar in an l sit position",
                level: .beginner,
                imageFile: "l-sit",
                videoURL: "https://www.youtube.com/watch?v=TB4gWro3XaY",
                equipment: [.overheadBar],
                mastery: .time(20),
                requirements: [
                    .init(exerciseName: "Pull Up", amount: .reps(1))
                ]
            )
        )
    }
}
