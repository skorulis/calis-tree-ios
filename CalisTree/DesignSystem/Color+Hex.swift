// Created by Alex Skorulis on 16/5/2026.

import SwiftUI

extension Color {
    /// Creates a color from a 24-bit RGB hex value (e.g. `0xFF00AA`).
    init(hex: UInt32, opacity: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
}
