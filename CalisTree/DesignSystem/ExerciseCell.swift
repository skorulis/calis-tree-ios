// Created by Alex Skorulis on 15/5/2026.

import Foundation
import SwiftUI

struct ExerciseCell: View {
    let exercise: Exercise
    
    var body: some View {
        HStack(spacing: 12) {
            image
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
    
    @ViewBuilder
    private var image: some View {
        if let imageFile = exercise.imageFile {
            Image(imageFile)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFill()
                .frame(width: 32, height: 32)
                .padding(12)
        }
        
    }
}
