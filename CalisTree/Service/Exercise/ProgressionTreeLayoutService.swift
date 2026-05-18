// Created by Alex Skorulis on 18/5/2026.

import Foundation

/// Builds a level-banded progression tree layout from a connected exercise subgraph.
struct ProgressionTreeLayoutService {

    func build(from exercises: [Exercise]) -> ProgressionTreeModel {
        let exerciseById = Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0) })
        guard !exerciseById.isEmpty else {
            return ProgressionTreeModel(bands: [], edges: [])
        }

        let edges = buildEdges(exerciseById: exerciseById)
        let rowById = buildRowIndices(exerciseById: exerciseById)

        var bands: [ProgressionTreeLevelBand] = []
        for level in Level.allCases {
            let levelExercises = exercises.filter { $0.level == level }
            guard !levelExercises.isEmpty else { continue }

            var rowsByIndex: [Int: [Exercise]] = [:]
            for exercise in levelExercises {
                let row = rowById[exercise.id] ?? 0
                rowsByIndex[row, default: []].append(exercise)
            }

            let sortedRowIndices = rowsByIndex.keys.sorted()
            let rows: [ProgressionTreeRow] = sortedRowIndices.map { rowIndex in
                let sortedExercises = rowsByIndex[rowIndex]!.sorted {
                    if $0.displayName != $1.displayName {
                        return $0.displayName < $1.displayName
                    }
                    return $0.id < $1.id
                }
                let nodes = sortedExercises.enumerated().map { columnIndex, exercise in
                    ProgressionTreeNode(
                        exercise: exercise,
                        rowIndex: rowIndex,
                        columnIndex: columnIndex
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
                return prerequisite.level == exercise.level
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

        for id in exerciseById.keys {
            _ = rowIndex(for: id)
        }
        return rowById
    }
}
