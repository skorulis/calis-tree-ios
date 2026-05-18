// Created by Alex Skorulis on 18/5/2026.

import SwiftUI
import UIKit

enum ProgressionTreeImageExporter {

    @MainActor
    static func render(
        model: ProgressionTreeModel,
        masteryProgress: @escaping (Exercise) -> ExerciseProgress
    ) -> UIImage? {
        let exportWidth = ProgressionTreeLayoutMetrics.exportContentWidth(for: model)
        let metrics = ProgressionTreeLayoutMetrics(model: model, containerWidth: exportWidth)
        let content = ProgressionTreeContentView(
            model: model,
            metrics: metrics,
            masteryProgress: masteryProgress
        )
        .background(Color(.systemBackground))

        let renderer = ImageRenderer(content: content)
        renderer.proposedSize = ProposedViewSize(
            width: metrics.scrollContentWidth,
            height: metrics.contentHeight
        )
        renderer.scale = min(UIScreen.main.scale, 2)
        return renderer.uiImage
    }
}
