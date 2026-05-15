// Created by Alex Skorulis on 15/5/2026.

import ASKCoordinator
import SwiftUI

struct ExerciseListView: View {
    let repository: ExerciseRepository

    @Environment(\.coordinator) private var coordinator

    var body: some View {
        List {
            ForEach(repository.exercises, id: \.name) { exercise in
                Button {
                    coordinator?.push(MainPath.exerciseDetail(exercise))
                } label: {
                    HStack(spacing: 12) {
                        Image(exercise.imageFile)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(exercise.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text(exercise.level.displayTitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Exercises")
    }
}

#Preview {
    NavigationStack {
        ExerciseListView(repository: ExerciseRepository())
    }
    .environment(\.coordinator, Coordinator(root: MainPath.exerciseList))
}
