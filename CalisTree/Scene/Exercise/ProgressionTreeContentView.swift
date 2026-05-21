// Created by Alex Skorulis on 18/5/2026.

import SwiftUI

struct ProgressionTreeContentView: View {
    let model: ProgressionTreeModel
    let metrics: ProgressionTreeLayoutMetrics
    let masteryProgress: (Exercise) -> ExerciseProgress
    var showsBandBackgrounds: Bool
    var onSelectExercise: ((Exercise) -> Void)?

    init(
        model: ProgressionTreeModel,
        metrics: ProgressionTreeLayoutMetrics,
        masteryProgress: @escaping (Exercise) -> ExerciseProgress,
        showsBandBackgrounds: Bool = true,
        onSelectExercise: ((Exercise) -> Void)? = nil
    ) {
        self.model = model
        self.metrics = metrics
        self.masteryProgress = masteryProgress
        self.showsBandBackgrounds = showsBandBackgrounds
        self.onSelectExercise = onSelectExercise
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if showsBandBackgrounds {
                ForEach(Array(model.bands.enumerated()), id: \.element.level) { bandIndex, band in
                    bandBackground(band: band, bandIndex: bandIndex)
                }
            }

            edgeCanvas

            ForEach(metrics.nodePlacements()) { placement in
                nodeView(placement: placement)
            }
        }
        .frame(
            width: metrics.scrollContentWidth,
            height: metrics.contentHeight,
            alignment: .topLeading
        )
    }

    private var edgeCanvas: some View {
        Canvas { context, _ in
            for edge in model.edges {
                guard
                    let from = metrics.center(for: edge.fromExerciseId),
                    let to = metrics.center(for: edge.toExerciseId)
                else { continue }
                var path = Path()
                path.move(to: from)
                path.addLine(to: to)
                context.stroke(
                    path,
                    with: .color(.secondary.opacity(0.5)),
                    lineWidth: 1.5
                )
            }
        }
        .frame(width: metrics.scrollContentWidth, height: metrics.contentHeight)
        .allowsHitTesting(false)
    }

    private func bandBackground(band: ProgressionTreeLevelBand, bandIndex: Int) -> some View {
        let frame = metrics.bandFrame(bandIndex: bandIndex)
        return Rectangle()
            .fill(band.level.subtleBackgroundColor)
            .frame(width: frame.width, height: frame.height)
            .offset(x: frame.minX, y: frame.minY)
    }

    @ViewBuilder
    private func nodeView(placement: ProgressionTreeNodePlacement) -> some View {
        Button {
            onSelectExercise?(placement.node.exercise)
        } label: {
            ExerciseAvatar(
                exercise: placement.node.exercise,
                masteryProgress: masteryProgress(placement.node.exercise),
                showName: true
            )
            .frame(width: placement.frame.width, height: placement.frame.height, alignment: .topLeading)
        }
        .buttonStyle(.plain)
        .offset(x: placement.frame.minX, y: placement.frame.minY)
        
    }
}
