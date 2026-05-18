// Created by Alex Skorulis on 18/5/2026.

import ASKCoordinator
import Knit
import SwiftUI

struct ProgressionTreeView: View {
    @State var viewModel: ProgressionTreeViewModel

    var body: some View {
        let model = viewModel.treeModel

        GeometryReader { geometry in
            let metrics = ProgressionTreeLayoutMetrics(
                model: model,
                containerWidth: geometry.size.width
            )

            ScrollView {
                ZStack(alignment: .topLeading) {
                    ForEach(Array(model.bands.enumerated()), id: \.element.level) { bandIndex, band in
                        bandBackground(
                            band: band,
                            bandIndex: bandIndex,
                            metrics: metrics
                        )
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        ZStack(alignment: .topLeading) {
                            edgeCanvas(model: model, metrics: metrics)

                            ForEach(nodePlacements(in: model, metrics: metrics)) { placement in
                                nodeButton(placement: placement)
                            }
                        }
                        .frame(
                            width: metrics.scrollContentWidth,
                            height: metrics.contentHeight,
                            alignment: .topLeading
                        )
                    }
                    .frame(height: metrics.contentHeight)
                }
                .frame(width: geometry.size.width, height: metrics.contentHeight, alignment: .topLeading)
            }
            .scrollContentBackground(.hidden)
        }
        .ignoresSafeArea(edges: .horizontal)
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func edgeCanvas(model: ProgressionTreeModel, metrics: ProgressionTreeLayoutMetrics) -> some View {
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

    private func bandBackground(
        band: ProgressionTreeLevelBand,
        bandIndex: Int,
        metrics: ProgressionTreeLayoutMetrics
    ) -> some View {
        let frame = metrics.bandFrame(bandIndex: bandIndex)
        return Rectangle()
            .fill(band.level.subtleBackgroundColor)
            .frame(width: frame.width, height: frame.height)
            .offset(x: frame.minX, y: frame.minY)
    }

    private func nodeButton(placement: ProgressionTreeNodePlacement) -> some View {
        Button {
            viewModel.showDetails(exercise: placement.node.exercise)
        } label: {
            ExerciseAvatar(
                exercise: placement.node.exercise,
                masteryProgress: viewModel.masteryProgress(for: placement.node.exercise),
                showName: true
            )
        }
        .buttonStyle(.plain)
        .frame(width: placement.frame.width, height: placement.frame.height, alignment: .topLeading)
        .offset(x: placement.frame.minX, y: placement.frame.minY)
    }

    private func nodePlacements(
        in model: ProgressionTreeModel,
        metrics: ProgressionTreeLayoutMetrics
    ) -> [ProgressionTreeNodePlacement] {
        model.bands.enumerated().flatMap { bandIndex, band in
            band.rows.enumerated().flatMap { rowIndex, row in
                row.nodes.map { node in
                    ProgressionTreeNodePlacement(
                        node: node,
                        frame: metrics.nodeFrame(
                            bandIndex: bandIndex,
                            rowIndex: rowIndex,
                            columnIndex: node.columnIndex
                        )
                    )
                }
            }
        }
    }
}

private struct ProgressionTreeNodePlacement: Identifiable {
    let node: ProgressionTreeNode
    let frame: CGRect

    var id: Exercise.ID { node.id }
}

// MARK: - Layout metrics

private struct ProgressionTreeLayoutMetrics {
    static let avatarSize: CGFloat = 60
    static let nameAreaHeight: CGFloat = 28
    static let columnSpacing: CGFloat = 24
    static let rowSpacing: CGFloat = 16
    static let bandInnerPadding: CGFloat = 12
    static let horizontalContentPadding: CGFloat = 16

    private let model: ProgressionTreeModel
    private let containerWidth: CGFloat
    private let bandFrames: [CGRect]
    private let nodeFrames: [Exercise.ID: CGRect]

    private static var rowHeight: CGFloat {
        avatarSize + 4 + nameAreaHeight
    }

    /// Width of the horizontally scrollable node/edge layer.
    var scrollContentWidth: CGFloat {
        max(containerWidth, Self.nodesContentWidth(for: model))
    }

    var contentHeight: CGFloat {
        guard let last = bandFrames.last else { return 120 }
        return last.maxY
    }

    init(model: ProgressionTreeModel, containerWidth: CGFloat) {
        self.model = model
        self.containerWidth = containerWidth
        var bands: [CGRect] = []
        var nodes: [Exercise.ID: CGRect] = [:]
        var y: CGFloat = 0

        for band in model.bands {
            let rowCount = band.rows.count
            let rowsHeight = CGFloat(rowCount) * Self.rowHeight
                + CGFloat(max(0, rowCount - 1)) * Self.rowSpacing
            let bandHeight = Self.bandInnerPadding * 2 + rowsHeight
            let bandFrame = CGRect(
                x: 0,
                y: y,
                width: containerWidth,
                height: bandHeight
            )
            bands.append(bandFrame)

            let rowsTop = y + Self.bandInnerPadding
            for (rowIndex, row) in band.rows.enumerated() {
                let rowY = rowsTop + CGFloat(rowIndex) * (Self.rowHeight + Self.rowSpacing)
                for node in row.nodes {
                    let x = Self.horizontalContentPadding
                        + CGFloat(node.columnIndex) * (Self.avatarSize + Self.columnSpacing)
                    nodes[node.id] = CGRect(
                        x: x,
                        y: rowY,
                        width: Self.avatarSize,
                        height: Self.rowHeight
                    )
                }
            }

            y += bandHeight
        }

        bandFrames = bands
        nodeFrames = nodes
    }

    func bandFrame(bandIndex: Int) -> CGRect {
        bandFrames[bandIndex]
    }

    func nodeFrame(bandIndex: Int, rowIndex: Int, columnIndex: Int) -> CGRect {
        guard bandIndex < model.bands.count else { return .zero }
        let band = model.bands[bandIndex]
        guard rowIndex < band.rows.count else { return .zero }
        let row = band.rows[rowIndex]
        guard let node = row.nodes.first(where: { $0.columnIndex == columnIndex }) else { return .zero }
        return nodeFrames[node.id] ?? .zero
    }

    func center(for exerciseId: Exercise.ID) -> CGPoint? {
        guard let frame = nodeFrames[exerciseId] else { return nil }
        return CGPoint(
            x: frame.minX + Self.avatarSize / 2,
            y: frame.minY + Self.avatarSize / 2
        )
    }

    private static func nodesContentWidth(for model: ProgressionTreeModel) -> CGFloat {
        let maxColumns = model.bands.flatMap(\.rows).map(\.nodes.count).max() ?? 1
        let columns = CGFloat(maxColumns)
        return horizontalContentPadding * 2
            + columns * avatarSize
            + max(0, columns - 1) * columnSpacing
    }
}

#Preview {
    let assembler = CalisTreeAssembly.testing()
    let exercise = assembler.resolver.exerciseRepository().exerciseById["planche"]!
    return NavigationStack {
        ProgressionTreeView(
            viewModel: assembler.resolver.progressionTreeViewModel(exercise: exercise)
        )
    }
    .environment(\.coordinator, Coordinator(root: MainPath.exerciseList))
}
