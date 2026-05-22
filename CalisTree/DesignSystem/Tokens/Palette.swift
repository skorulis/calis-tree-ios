// Created by Alex Skorulis on 16/5/2026.

import SwiftUI

enum Palette {
    enum Base {
        static let gold = Color(hex: 0xFFC700)
        static let yellow = Color(hex: 0xFFC700)
        static let slate = Color(hex: 0x737A85)
        static let green = Color(hex: 0x33A673)
        static let blue = Color(hex: 0x4073D9)
        static let orange = Color(hex: 0xE68026)
        static let red = Color(hex: 0xD9404D)
    }

    enum Progress {
        static let inProgress = Base.yellow
        static let complete = Base.green
    }

    enum Level {
        static let foundation = Base.slate
        static let beginner = Base.green
        static let intermediate = Base.blue
        static let advanced = Base.orange
        static let expert = Base.red
    }
}
