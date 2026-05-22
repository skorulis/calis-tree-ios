// Created by Alex Skorulis on 17/5/2026.

import Knit
import SwiftUI

struct ExerciseVideoView: View {
    let exercise: Exercise

    var body: some View {
        YouTubeEmbedView(videoURL: exercise.videoURL)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            .background(Color.black)
            .navigationTitle("Video")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let assembler = ExerciseTreeAssembly.testing()
    let exercise = assembler.resolver.exerciseRepository().exerciseById["elbow_lever"]!
    NavigationStack {
        ExerciseVideoView(exercise: exercise)
    }
}
