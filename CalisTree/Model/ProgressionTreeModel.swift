// Created by Alex Skorulis on 18/5/2026.

import Foundation

struct ProgressionTreeModel: Sendable {
    let bands: [ProgressionTreeLevelBand]
    let edges: [ProgressionTreeEdge]
}

struct ProgressionTreeLevelBand: Sendable {
    let level: Level
    let rows: [ProgressionTreeRow]
}

struct ProgressionTreeRow: Sendable {
    let nodes: [ProgressionTreeNode]
}

struct ProgressionTreeNode: Sendable, Identifiable {
    let exercise: Exercise
    let rowIndex: Int
    let columnIndex: Int

    var id: Exercise.ID { exercise.id }
}

struct ProgressionTreeEdge: Sendable {
    let fromExerciseId: Exercise.ID
    let toExerciseId: Exercise.ID
}
