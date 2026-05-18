// Created by Alex Skorulis on 19/5/2026.

import SwiftUI

struct TerminologyLinkedText: View {
    let text: String
    var onTermTap: (Terminology) -> Void = { _ in }

    @Environment(\.terminologyLinkIndex) private var linkIndex

    var body: some View {
        Text(linkIndex.attributedString(for: text))
            .environment(
                \.openURL,
                OpenURLAction { url in
                    guard let term = linkIndex.terminology(for: url) else {
                        return .systemAction
                    }
                    onTermTap(term)
                    return .handled
                }
            )
    }
}

#Preview {
    let protraction = Terminology(
        name: "Shoulder (scapular) Protraction",
        details: "Shoulder blades slide forward and away from the spine.",
        linkTerms: ["protract your shoulders"]
    )
    let index = TerminologyLinkIndex(terms: [protraction])
    let step =
        "Push through the floor and protract your shoulders by rounding the upper back slightly"

    TerminologyLinkedText(text: step) { _ in }
        .environment(\.terminologyLinkIndex, index)
        .padding()
}
