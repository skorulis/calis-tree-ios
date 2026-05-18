// Created by Alex Skorulis on 19/5/2026.

import Foundation
import Testing
@testable import CalisTree

struct TerminologyLinkIndexTests {

    private let protraction = Terminology(
        name: "Shoulder (scapular) Protraction",
        details: "Protraction details.",
        linkTerms: ["protract your shoulders"]
    )

    private let pushUpPosition = Terminology(
        name: "Push-up Position",
        details: "Push-up position details."
    )

    private let triceps = Terminology(
        name: "Triceps",
        details: "Triceps details."
    )

    @Test func linksLinkTermInStepCopy() {
        let index = TerminologyLinkIndex(terms: [protraction])
        let text =
            "Push through the floor and protract your shoulders by rounding the upper back slightly"
        let segments = index.segments(in: text)

        let links = segments.compactMap { segment -> Terminology? in
            if case .link(_, let term) = segment { return term }
            return nil
        }
        #expect(links.count == 1)
        #expect(links[0].name == protraction.name)
    }

    @Test func linksNameCaseInsensitively() {
        let index = TerminologyLinkIndex(terms: [pushUpPosition])
        let segments = index.segments(in: "Start in a high push-up position with arms straight")

        let linkText = segments.compactMap { segment -> String? in
            if case .link(let substring, _) = segment { return substring }
            return nil
        }
        #expect(linkText == ["push-up position"])
    }

    @Test func longestPhraseWins() {
        let short = Terminology(
            name: "Shoulder",
            details: "Short.",
            linkTerms: ["your shoulders"]
        )
        let index = TerminologyLinkIndex(terms: [protraction, short])
        let text = "protract your shoulders"
        let segments = index.segments(in: text)

        let links = segments.compactMap { segment -> Terminology? in
            if case .link(_, let term) = segment { return term }
            return nil
        }
        #expect(links.count == 1)
        #expect(links[0].name == protraction.name)
    }

    @Test func doesNotLinkInsideLargerWord() {
        let index = TerminologyLinkIndex(terms: [triceps])
        let segments = index.segments(in: "triceps_dip is an exercise id")

        let hasLink = segments.contains { segment in
            if case .link = segment { return true }
            return false
        }
        #expect(!hasLink)
    }

    @Test func terminologyResolvesURL() {
        let index = TerminologyLinkIndex(terms: [triceps])
        let url = TerminologyLinkIndex.url(for: triceps)
        #expect(index.terminology(for: url)?.name == triceps.name)
    }

    @Test func attributedStringContainsLink() {
        let index = TerminologyLinkIndex(terms: [protraction])
        let attributed = index.attributedString(
            for: "protract your shoulders"
        )
        #expect(attributed.runs.contains { $0.link != nil })
    }
}
