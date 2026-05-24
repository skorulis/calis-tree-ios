// Created by Alex Skorulis on 24/5/2026.

import SwiftUI

struct EquipmentAvatar: View {
    let equipment: Equipment

    private static let size: CGFloat = 60
    private static let lineWidth: CGFloat = 3

    var body: some View {
        ZStack {
            image
                .frame(width: Self.size - Self.lineWidth * 2, height: Self.size - Self.lineWidth * 2)
                .background(Color.white)
                .clipShape(Circle())
            Circle()
                .stroke(Palette.Level.foundation, lineWidth: Self.lineWidth)
        }
        .padding(Self.lineWidth / 2)
        .frame(width: Self.size)
        .accessibilityLabel(equipment.name)
    }

    @ViewBuilder
    private var image: some View {
        equipment.image
            .resizable()
            .scaledToFill()
    }
}

#Preview {
    HStack {
        EquipmentAvatar(equipment: .barbell)
        EquipmentAvatar(equipment: .rings)
        EquipmentAvatar(equipment: .captainsChair)
    }
    .padding()
    .background(Palette.Level.beginner.opacity(0.25))
}
