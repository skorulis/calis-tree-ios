// Created by Alex Skorulis on 15/5/2026.

import SwiftUI

struct MasteryIndicatorView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.25), lineWidth: 3)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 28, height: 28)
        .accessibilityLabel("Mastery progress")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

#Preview {
    HStack(spacing: 24) {
        MasteryIndicatorView(progress: 0.35)
        MasteryIndicatorView(progress: 0.75)
    }
    .padding()
}
