// Created by Alex Skorulis on 16/5/2026.

import Foundation

struct Terminology: Codable, Hashable, Identifiable {
    let name: String
    let details: String

    var id: String { name }
}
