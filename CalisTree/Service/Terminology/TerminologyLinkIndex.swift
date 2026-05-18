// Created by Alex Skorulis on 19/5/2026.

import Foundation

struct TerminologyLinkIndex: Sendable {
    enum Segment: Equatable, Sendable {
        case plain(String)
        case link(String, Terminology)
    }

    struct Pattern: Sendable {
        let phrase: String
        let normalizedPhrase: String
        let term: Terminology
    }

    static let empty = TerminologyLinkIndex(terms: [])

    static let urlScheme = "calistree-terminology"

    let patterns: [Pattern]
    private let termByName: [String: Terminology]

    init(terms: [Terminology]) {
        self.termByName = Dictionary(uniqueKeysWithValues: terms.map { ($0.name, $0) })

        var seenPhrases = Set<String>()
        var collected: [Pattern] = []
        for term in terms {
            let phrases = [term.name] + term.linkTerms
            for phrase in phrases {
                let key = phrase.lowercased()
                guard !key.isEmpty, seenPhrases.insert(key).inserted else { continue }
                collected.append(
                    Pattern(
                        phrase: phrase,
                        normalizedPhrase: key,
                        term: term
                    )
                )
            }
        }
        self.patterns = collected.sorted { $0.phrase.count > $1.phrase.count }
    }

    func segments(in text: String) -> [Segment] {
        guard !text.isEmpty, !patterns.isEmpty else {
            return text.isEmpty ? [] : [.plain(text)]
        }

        var result: [Segment] = []
        var plainStart = text.startIndex
        var index = text.startIndex

        while index < text.endIndex {
            guard let match = firstMatch(in: text, at: index) else {
                index = text.index(after: index)
                continue
            }

            if plainStart < match.range.lowerBound {
                result.append(.plain(String(text[plainStart..<match.range.lowerBound])))
            }
            result.append(.link(String(text[match.range]), match.pattern.term))
            index = match.range.upperBound
            plainStart = index
        }

        if plainStart < text.endIndex {
            result.append(.plain(String(text[plainStart..<text.endIndex])))
        }

        return result
    }

    func terminology(for url: URL) -> Terminology? {
        guard url.scheme == Self.urlScheme else { return nil }
        let name = url.host ?? url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard !name.isEmpty else { return nil }
        let decoded = name.removingPercentEncoding ?? name
        return termByName[decoded]
    }

    static func url(for term: Terminology) -> URL {
        var components = URLComponents()
        components.scheme = urlScheme
        components.host = term.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        return components.url!
    }

    private struct Match {
        let range: Range<String.Index>
        let pattern: Pattern
    }

    private func firstMatch(in text: String, at start: String.Index) -> Match? {
        let lowercased = text[start...].lowercased()
        for pattern in patterns {
            guard lowercased.hasPrefix(pattern.normalizedPhrase) else { continue }
            let end = text.index(start, offsetBy: pattern.phrase.count)
            guard hasWordBoundary(in: text, range: start..<end) else { continue }
            return Match(range: start..<end, pattern: pattern)
        }
        return nil
    }

    private func hasWordBoundary(in text: String, range: Range<String.Index>) -> Bool {
        if range.lowerBound > text.startIndex {
            let before = text[text.index(before: range.lowerBound)]
            if isWordCharacter(before) { return false }
        }
        if range.upperBound < text.endIndex {
            let after = text[range.upperBound]
            if isWordCharacter(after) { return false }
        }
        return true
    }

    private func isWordCharacter(_ character: Character) -> Bool {
        character.isLetter || character.isNumber
    }
}
