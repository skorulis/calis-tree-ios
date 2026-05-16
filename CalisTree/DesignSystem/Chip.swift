// Created by Alex Skorulis on 15/5/2026.

import SwiftUI

struct Chip: View {
    let text: String
    let color: Color

    init(text: String, color: Color) {
        self.text = text
        self.color = color
    }

    init(level: Level) {
        self.text = level.displayTitle
        self.color = level.chipColor
    }

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.18), in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview("All levels") {
    VStack(alignment: .leading, spacing: 8) {
        ForEach(Level.allCases, id: \.self) { level in
            Chip(level: level)
        }
    }
    .padding()
}
