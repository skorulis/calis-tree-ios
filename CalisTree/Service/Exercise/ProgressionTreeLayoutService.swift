// Created by Alex Skorulis on 18/5/2026.

import Foundation

/// Builds a level-banded progression tree layout from a connected exercise subgraph.
struct ProgressionTreeLayoutService {

    private static let columnOrderingIterations = 4

    func build(from exercises: [Exercise]) -> ProgressionTreeModel {
        let exerciseById = Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0) })
        guard !exerciseById.isEmpty else {
            return ProgressionTreeModel(bands: [], edges: [])
        }

        let edges = buildEdges(exerciseById: exerciseById)
        let rowById = buildRowIndices(exerciseById: exerciseById)
        let columnById = orderColumns(
            exercises: exercises,
            exerciseById: exerciseById,
            rowById: rowById,
            edges: edges
        )

        var bands: [ProgressionTreeLevelBand] = []
        for level in Level.allCases {
            let levelExercises = exercises.filter { $0.safeLevel == level }
            guard !levelExercises.isEmpty else { continue }

            var rowsByIndex: [Int: [Exercise]] = [:]
            for exercise in levelExercises {
                let row = rowById[exercise.id] ?? 0
                rowsByIndex[row, default: []].append(exercise)
            }

            let sortedRowIndices = rowsByIndex.keys.sorted()
            let rows: [ProgressionTreeRow] = sortedRowIndices.map { rowIndex in
                let sortedExercises = rowsByIndex[rowIndex]!.sorted {
                    let column0 = columnById[$0.id] ?? 0
                    let column1 = columnById[$1.id] ?? 0
                    if column0 != column1 {
                        return column0 < column1
                    }
                    return Self.stableExerciseSort($0, $1)
                }
                let nodes = sortedExercises.map { exercise in
                    ProgressionTreeNode(
                        exercise: exercise,
                        rowIndex: rowIndex,
                        columnIndex: columnById[exercise.id] ?? 0
                    )
                }
                return ProgressionTreeRow(nodes: nodes)
            }

            bands.append(ProgressionTreeLevelBand(level: level, rows: rows))
        }

        return ProgressionTreeModel(bands: bands, edges: edges)
    }

    private func buildEdges(exerciseById: [Exercise.ID: Exercise]) -> [ProgressionTreeEdge] {
        var edges: [ProgressionTreeEdge] = []
        for exercise in exerciseById.values {
            for prerequisiteId in exercise.prerequisites {
                guard exerciseById[prerequisiteId] != nil else { continue }
                edges.append(
                    ProgressionTreeEdge(
                        fromExerciseId: prerequisiteId,
                        toExerciseId: exercise.id
                    )
                )
            }
        }
        return edges.sorted {
            if $0.fromExerciseId != $1.fromExerciseId {
                return $0.fromExerciseId < $1.fromExerciseId
            }
            return $0.toExerciseId < $1.toExerciseId
        }
    }

    /// Row index within a level band based on same-level prerequisites only.
    private func buildRowIndices(exerciseById: [Exercise.ID: Exercise]) -> [Exercise.ID: Int] {
        var rowById: [Exercise.ID: Int] = [:]
        var visiting: Set<Exercise.ID> = []

        func rowIndex(for id: Exercise.ID) -> Int {
            if let cached = rowById[id] { return cached }
            guard let exercise = exerciseById[id] else { return 0 }

            if visiting.contains(id) {
                // Same-level cycle: fall back to row 0 so layout stays finite.
                return 0
            }
            visiting.insert(id)

            let sameLevelPrerequisiteIds = exercise.prerequisites.filter { prerequisiteId in
                guard let prerequisite = exerciseById[prerequisiteId] else { return false }
                return prerequisite.safeLevel == exercise.safeLevel
            }

            let index: Int
            if sameLevelPrerequisiteIds.isEmpty {
                index = 0
            } else {
                index = 1 + (sameLevelPrerequisiteIds.map { rowIndex(for: $0) }.max() ?? 0)
            }

            visiting.remove(id)
            rowById[id] = index
            return index
        }

        for id in exerciseById.keys.sorted() {
            _ = rowIndex(for: id)
        }
        return rowById
    }

    /// Orders nodes within each layout layer to shorten edges between connected exercises.
    private func orderColumns(
        exercises: [Exercise],
        exerciseById: [Exercise.ID: Exercise],
        rowById: [Exercise.ID: Int],
        edges: [ProgressionTreeEdge]
    ) -> [Exercise.ID: Int] {
        var predecessors: [Exercise.ID: [Exercise.ID]] = [:]
        var successors: [Exercise.ID: [Exercise.ID]] = [:]
        for edge in edges {
            predecessors[edge.toExerciseId, default: []].append(edge.fromExerciseId)
            successors[edge.fromExerciseId, default: []].append(edge.toExerciseId)
        }

        var exercisesByLayer: [LayoutLayer: [Exercise]] = [:]
        for exercise in exercises {
            let layer = LayoutLayer(
                level: exercise.safeLevel,
                rowIndex: rowById[exercise.id] ?? 0
            )
            exercisesByLayer[layer, default: []].append(exercise)
        }

        let layers = exercisesByLayer.keys.sorted()
        var orderByLayer: [LayoutLayer: [Exercise.ID]] = [:]
        for layer in layers {
            let sorted = exercisesByLayer[layer]!.sorted(by: Self.stableExerciseSort)
            orderByLayer[layer] = sorted.map(\.id)
        }

        for _ in 0..<Self.columnOrderingIterations {
            let positions = columnPositions(from: orderByLayer)
            for layer in layers {
                reorderLayer(
                    layer: layer,
                    orderByLayer: &orderByLayer,
                    exerciseById: exerciseById,
                    positions: positions,
                    neighbors: predecessors
                )
            }

            let positionsAfterForward = columnPositions(from: orderByLayer)
            for layer in layers.reversed() {
                reorderLayer(
                    layer: layer,
                    orderByLayer: &orderByLayer,
                    exerciseById: exerciseById,
                    positions: positionsAfterForward,
                    neighbors: successors
                )
            }
        }

        var columnById = assignColumns(
            orderByLayer: orderByLayer,
            layers: layers,
            predecessors: predecessors,
            exerciseById: exerciseById
        )
        refineConvergingNodeColumns(columnById: &columnById, predecessors: predecessors)
        return finalizeColumns(
            columnById: columnById,
            exercises: exercises,
            exerciseById: exerciseById,
            rowById: rowById
        )
    }

    /// Ensures columns are non-negative and unique within each layout layer (row).
    private func finalizeColumns(
        columnById: [Exercise.ID: Int],
        exercises: [Exercise],
        exerciseById: [Exercise.ID: Exercise],
        rowById: [Exercise.ID: Int]
    ) -> [Exercise.ID: Int] {
        var result = columnById
        var idsByLayer: [LayoutLayer: [Exercise.ID]] = [:]
        for exercise in exercises {
            let layer = LayoutLayer(
                level: exercise.safeLevel,
                rowIndex: rowById[exercise.id] ?? 0
            )
            idsByLayer[layer, default: []].append(exercise.id)
        }

        for layer in idsByLayer.keys.sorted() {
            guard let ids = idsByLayer[layer] else { continue }
            let sorted = ids.sorted { lhs, rhs in
                let column0 = result[lhs] ?? 0
                let column1 = result[rhs] ?? 0
                if column0 != column1 {
                    return column0 < column1
                }
                return Self.stableIdSort(lhs, rhs, exerciseById: exerciseById)
            }

            var lastColumn = -1
            for id in sorted {
                var column = result[id] ?? 0
                if column <= lastColumn {
                    column = lastColumn + 1
                }
                result[id] = column
                lastColumn = column
            }
        }

        if let minColumn = result.values.min(), minColumn < 0 {
            for id in result.keys {
                result[id] = (result[id] ?? 0) - minColumn
            }
        }

        return result
    }

    /// Centers nodes that merge multiple assigned prerequisites (e.g. diamond joins).
    private func refineConvergingNodeColumns(
        columnById: inout [Exercise.ID: Int],
        predecessors: [Exercise.ID: [Exercise.ID]]
    ) {
        for (id, prerequisiteIds) in predecessors {
            guard prerequisiteIds.count >= 2 else { continue }
            let predecessorColumns = prerequisiteIds.compactMap { columnById[$0] }
            guard predecessorColumns.count == prerequisiteIds.count,
                  let minColumn = predecessorColumns.min(),
                  let maxColumn = predecessorColumns.max(),
                  minColumn < maxColumn
            else { continue }
            columnById[id] = (minColumn + maxColumn + 1) / 2
        }
    }

    /// Maps ordered layers to global column indices (aligned across rows).
    private func assignColumns(
        orderByLayer: [LayoutLayer: [Exercise.ID]],
        layers: [LayoutLayer],
        predecessors: [Exercise.ID: [Exercise.ID]],
        exerciseById: [Exercise.ID: Exercise]
    ) -> [Exercise.ID: Int] {
        var columnById: [Exercise.ID: Int] = [:]

        for layer in layers {
            guard let ids = orderByLayer[layer] else { continue }

            let connectedIds = ids.filter { !(predecessors[$0] ?? []).isEmpty }
            let unconnectedIds = ids.filter { (predecessors[$0] ?? []).isEmpty }
                .sorted { Self.stableIdSort($0, $1, exerciseById: exerciseById) }

            var targets: [(id: Exercise.ID, x: Double)] = connectedIds.map { id in
                let predecessorColumns = (predecessors[id] ?? []).compactMap { columnById[$0] }.map(Double.init)
                let x = Self.median(predecessorColumns)
                return (id, x)
            }
            targets.sort { lhs, rhs in
                if lhs.x != rhs.x {
                    return lhs.x < rhs.x
                }
                return Self.stableIdSort(lhs.id, rhs.id, exerciseById: exerciseById)
            }

            var lastColumn = -1

            if targets.count >= 2, targets.allSatisfy({ $0.x == targets[0].x }) {
                let tiedIds = targets.map(\.id)
                let spreadWide = hasConvergingSuccessor(
                    ids: tiedIds,
                    predecessors: predecessors
                )
                for (index, item) in targets.enumerated() {
                    let column = spreadWide ? index * 2 : index
                    columnById[item.id] = column
                    lastColumn = max(lastColumn, column)
                }
            } else if targets.count == 1, let item = targets.first {
                let predecessorIds = predecessors[item.id] ?? []
                let predecessorColumns = predecessorIds.compactMap { columnById[$0] }
                let column: Int
                if predecessorIds.count >= 2,
                   predecessorColumns.count == predecessorIds.count,
                   let minColumn = predecessorColumns.min(),
                   let maxColumn = predecessorColumns.max(),
                   minColumn < maxColumn
                {
                    column = (minColumn + maxColumn + 1) / 2
                } else if let onlyColumn = predecessorColumns.first, predecessorColumns.count == 1 {
                    column = onlyColumn
                } else {
                    column = Int(floor(item.x + 0.5))
                }
                columnById[item.id] = column
                lastColumn = column
            } else {
                for item in targets {
                    var column = Int(floor(item.x + 0.5))
                    if column <= lastColumn {
                        column = lastColumn + 1
                    }
                    columnById[item.id] = column
                    lastColumn = column
                }
            }

            for id in unconnectedIds {
                let column = lastColumn + 1
                columnById[id] = column
                lastColumn = column
            }
        }

        return columnById
    }

    /// True when some exercise requires exactly these ids as prerequisites (e.g. a diamond join).
    private func hasConvergingSuccessor(
        ids: [Exercise.ID],
        predecessors: [Exercise.ID: [Exercise.ID]]
    ) -> Bool {
        let pair = Set(ids)
        guard pair.count >= 2 else { return false }

        return predecessors.contains { _, prerequisiteList in
            Set(prerequisiteList) == pair
        }
    }

    private static func stableIdSort(
        _ lhs: Exercise.ID,
        _ rhs: Exercise.ID,
        exerciseById: [Exercise.ID: Exercise]
    ) -> Bool {
        let lhsName = exerciseById[lhs]?.displayName ?? lhs
        let rhsName = exerciseById[rhs]?.displayName ?? rhs
        if lhsName != rhsName {
            return lhsName < rhsName
        }
        return lhs < rhs
    }

    private func reorderLayer(
        layer: LayoutLayer,
        orderByLayer: inout [LayoutLayer: [Exercise.ID]],
        exerciseById: [Exercise.ID: Exercise],
        positions: [Exercise.ID: Double],
        neighbors: [Exercise.ID: [Exercise.ID]]
    ) {
        guard let ids = orderByLayer[layer], ids.count > 1 else { return }

        let indexById = Dictionary(uniqueKeysWithValues: ids.enumerated().map { ($1, $0) })
        let sorted = ids.sorted { lhs, rhs in
            let lhsKey = sortKey(
                for: lhs,
                indexInLayer: indexById[lhs] ?? 0,
                exerciseById: exerciseById,
                positions: positions,
                neighbors: neighbors[lhs] ?? []
            )
            let rhsKey = sortKey(
                for: rhs,
                indexInLayer: indexById[rhs] ?? 0,
                exerciseById: exerciseById,
                positions: positions,
                neighbors: neighbors[rhs] ?? []
            )
            if lhsKey.primary != rhsKey.primary {
                return lhsKey.primary < rhsKey.primary
            }
            if lhsKey.displayName != rhsKey.displayName {
                return lhsKey.displayName < rhsKey.displayName
            }
            return lhsKey.id < rhsKey.id
        }
        orderByLayer[layer] = sorted
    }

    private func sortKey(
        for id: Exercise.ID,
        indexInLayer: Int,
        exerciseById: [Exercise.ID: Exercise],
        positions: [Exercise.ID: Double],
        neighbors: [Exercise.ID]
    ) -> (primary: Double, displayName: String, id: Exercise.ID) {
        let neighborPositions = neighbors.compactMap { positions[$0] }
        let primary: Double
        if neighborPositions.isEmpty {
            primary = Double(indexInLayer)
        } else {
            primary = Self.median(neighborPositions)
        }
        let exercise = exerciseById[id]
        return (
            primary,
            exercise?.displayName ?? id,
            id
        )
    }

    private func columnPositions(from orderByLayer: [LayoutLayer: [Exercise.ID]]) -> [Exercise.ID: Double] {
        var result: [Exercise.ID: Double] = [:]
        for ids in orderByLayer.values {
            for (index, id) in ids.enumerated() {
                result[id] = Double(index)
            }
        }
        return result
    }

    private static func median(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let sorted = values.sorted()
        let mid = sorted.count / 2
        if sorted.count.isMultiple(of: 2) {
            return (sorted[mid - 1] + sorted[mid]) / 2
        }
        return sorted[mid]
    }

    private static func stableExerciseSort(_ lhs: Exercise, _ rhs: Exercise) -> Bool {
        if lhs.displayName != rhs.displayName {
            return lhs.displayName < rhs.displayName
        }
        return lhs.id < rhs.id
    }
}

// MARK: - Layout layers

private struct LayoutLayer: Hashable, Comparable {
    let level: Level
    let rowIndex: Int

    static func < (lhs: LayoutLayer, rhs: LayoutLayer) -> Bool {
        if lhs.level != rhs.level {
            return lhs.level < rhs.level
        }
        return lhs.rowIndex < rhs.rowIndex
    }
}
