// Created by Alex Skorulis on 19/5/2026.

import SwiftUI

extension TerminologyLinkIndex {
    func attributedString(for text: String) -> AttributedString {
        var attributed = AttributedString()
        for segment in segments(in: text) {
            switch segment {
            case .plain(let substring):
                attributed.append(AttributedString(substring))
            case .link(let substring, let term):
                var linked = AttributedString(substring)
                linked.underlineStyle = .single
                linked.foregroundColor = .primary
                linked.link = Self.url(for: term)
                attributed.append(linked)
            }
        }
        return attributed
    }
}
