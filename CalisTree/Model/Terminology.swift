// Created by Alex Skorulis on 16/5/2026.

import Foundation

struct Terminology: Codable, Hashable, Identifiable {
    let name: String
    let details: String
    let linkTerms: [String]

    var id: String { name }

    init(name: String, details: String, linkTerms: [String] = []) {
        self.name = name
        self.details = details
        self.linkTerms = linkTerms
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        details = try container.decode(String.self, forKey: .details)
        linkTerms = try container.decodeIfPresent([String].self, forKey: .linkTerms) ?? []
    }
}
