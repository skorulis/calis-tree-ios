// Created by Alex Skorulis on 18/5/2026.

import CoreGraphics
import Foundation

struct ProgressionTreeLayoutMetrics {
    static let avatarSize: CGFloat = 60
    static let nameAreaHeight: CGFloat = 28
    static let columnSpacing: CGFloat = 24
    static let rowSpacing: CGFloat = 16
    static let bandInnerPadding: CGFloat = 12
    static let horizontalContentPadding: CGFloat = 16

    let model: ProgressionTreeModel
    let containerWidth: CGFloat
    private let bandFrames: [CGRect]
    private let nodeFrames: [Exercise.ID: CGRect]

    private static var rowHeight: CGFloat {
        avatarSize + 4 + nameAreaHeight
    }

    var scrollContentWidth: CGFloat {
        max(containerWidth, Self.nodesContentWidth(for: model))
    }

    var contentHeight: CGFloat {
        guard let last = bandFrames.last else { return 120 }
        return last.maxY
    }

    static func exportContentWidth(for model: ProgressionTreeModel) -> CGFloat {
        nodesContentWidth(for: model)
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

    func nodePlacements() -> [ProgressionTreeNodePlacement] {
        model.bands.enumerated().flatMap { bandIndex, band in
            band.rows.enumerated().flatMap { rowIndex, row in
                row.nodes.map { node in
                    ProgressionTreeNodePlacement(
                        node: node,
                        frame: nodeFrame(
                            bandIndex: bandIndex,
                            rowIndex: rowIndex,
                            columnIndex: node.columnIndex
                        )
                    )
                }
            }
        }
    }

    private static func nodesContentWidth(for model: ProgressionTreeModel) -> CGFloat {
        let maxColumns = model.bands.flatMap(\.rows).map(\.nodes.count).max() ?? 1
        let columns = CGFloat(maxColumns)
        return horizontalContentPadding * 2
            + columns * avatarSize
            + max(0, columns - 1) * columnSpacing
    }
}

struct ProgressionTreeNodePlacement: Identifiable {
    let node: ProgressionTreeNode
    let frame: CGRect

    var id: Exercise.ID { node.id }
}
