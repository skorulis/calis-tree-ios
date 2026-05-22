// Created by Alex Skorulis on 22/5/2026.

import SwiftUI

struct ContinueButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(Color.black.opacity(0.85))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(backgroundColor(isPressed: configuration.isPressed), in: RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        guard isEnabled else {
            return Palette.Base.gold.opacity(0.4)
        }
        return Palette.Base.gold.opacity(isPressed ? 0.85 : 1)
    }
}

extension ButtonStyle where Self == ContinueButtonStyle {
    static var continueButton: ContinueButtonStyle { ContinueButtonStyle() }
}

#Preview {
    VStack(spacing: 16) {
        Button("Continue") {}
            .buttonStyle(.continueButton)

        Button("Done") {}
            .buttonStyle(.continueButton)
            .disabled(true)
    }
    .padding(.margin)
}
