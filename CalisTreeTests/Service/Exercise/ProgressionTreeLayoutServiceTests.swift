// Created by Alex Skorulis on 18/5/2026.

import Foundation
import Testing
@testable import CalisTree

@Suite(.serialized)
struct ProgressionTreeLayoutServiceTests {

    private let service = ProgressionTreeLayoutService()

    @Test func build_emptyInputReturnsEmptyModel() {
        let model = service.build(from: [])
        #expect(model.bands.isEmpty)
        #expect(model.edges.isEmpty)
    }

    @Test func build_linearChainAcrossLevels() {
        let a = makeExercise(id: "a", level: .foundation, prerequisites: [])
        let b = makeExercise(id: "b", level: .beginner, prerequisites: ["a"])
        let c = makeExercise(id: "c", level: .intermediate, prerequisites: ["b"])

        let model = service.build(from: [a, b, c])

        #expect(model.bands.map(\.level) == [.foundation, .beginner, .intermediate])
        #expect(rowIndex(for: "a", in: model) == 0)
        #expect(rowIndex(for: "b", in: model) == 0)
        #expect(rowIndex(for: "c", in: model) == 0)
        #expect(model.edges.count == 2)
    }

    @Test func build_sameLevelPrerequisitesIncreaseRow() {
        let a = makeExercise(id: "a", level: .beginner, prerequisites: [])
        let b = makeExercise(id: "b", level: .beginner, prerequisites: ["a"])
        let c = makeExercise(id: "c", level: .beginner, prerequisites: ["b"])

        let model = service.build(from: [a, b, c])

        #expect(model.bands.count == 1)
        #expect(model.bands[0].level == .beginner)
        #expect(model.bands[0].rows.count == 3)
        #expect(rowIndex(for: "a", in: model) == 0)
        #expect(rowIndex(for: "b", in: model) == 1)
        #expect(rowIndex(for: "c", in: model) == 2)
    }

    @Test func build_diamondJoinSharesAncestorRow() {
        let root = makeExercise(id: "root", level: .beginner, prerequisites: [])
        let left = makeExercise(id: "left", level: .beginner, prerequisites: ["root"])
        let right = makeExercise(id: "right", level: .beginner, prerequisites: ["root"])
        let join = makeExercise(id: "join", level: .beginner, prerequisites: ["left", "right"])

        let model = service.build(from: [root, left, right, join])

        #expect(rowIndex(for: "root", in: model) == 0)
        #expect(rowIndex(for: "left", in: model) == 1)
        #expect(rowIndex(for: "right", in: model) == 1)
        #expect(rowIndex(for: "join", in: model) == 2)
        #expect(model.edges.count == 4)
    }

    @Test func build_diamondJoin_ordersBranchesAroundJoin() {
        let root = makeExercise(id: "root", level: .beginner, prerequisites: [])
        let left = makeExercise(id: "left", level: .beginner, prerequisites: ["root"])
        let right = makeExercise(id: "right", level: .beginner, prerequisites: ["root"])
        let join = makeExercise(id: "join", level: .beginner, prerequisites: ["left", "right"])

        let model = service.build(from: [root, left, right, join])

        #expect(rowIndex(for: "join", in: model) == 2)

        let leftColumn = columnIndex(for: "left", in: model)
        let rightColumn = columnIndex(for: "right", in: model)
        let joinColumn = columnIndex(for: "join", in: model)

        #expect(leftColumn != nil)
        #expect(rightColumn != nil)
        #expect(joinColumn != nil)
        #expect(leftColumn! < joinColumn!)
        #expect(joinColumn! < rightColumn!)
    }

    @Test func build_forkPlacesChildrenNearParent() {
        let parent = makeExercise(id: "fork_parent", level: .foundation, prerequisites: [])
        let childA = makeExercise(id: "fork_child_a", level: .beginner, prerequisites: ["fork_parent"])
        let childB = makeExercise(id: "fork_child_b", level: .beginner, prerequisites: ["fork_parent"])

        let model = service.build(from: [parent, childA, childB])

        let parentColumn = columnIndex(for: "fork_parent", in: model)!
        let childAColumn = columnIndex(for: "fork_child_a", in: model)!
        let childBColumn = columnIndex(for: "fork_child_b", in: model)!

        #expect(abs(childAColumn - parentColumn) <= 2)
        #expect(abs(childBColumn - parentColumn) <= 2)
        #expect(abs(childAColumn - childBColumn) <= 2)
    }

    @Test func build_ignoresPrerequisitesOutsideInputSet() {
        let target = makeExercise(id: "target", level: .advanced, prerequisites: ["missing"])
        let model = service.build(from: [target])

        #expect(model.edges.isEmpty)
        #expect(model.bands.count == 1)
        #expect(model.bands[0].rows[0].nodes.map(\.id) == ["target"])
    }

    @Test func build_sameLevelCycleDoesNotTrap() {
        let a = makeExercise(id: "a", level: .beginner, prerequisites: ["b"])
        let b = makeExercise(id: "b", level: .beginner, prerequisites: ["a"])
        let model = service.build(from: [a, b])

        #expect(model.bands[0].rows.count >= 1)
        #expect(model.edges.count == 2)
    }

    @Test func build_columnsAreNonNegative() {
        let repository = ExerciseRepository()
        let chain = repository.progressionChain(to: "planche")
        let model = service.build(from: chain)

        for band in model.bands {
            for row in band.rows {
                for node in row.nodes {
                    #expect(node.columnIndex >= 0)
                }
            }
        }
    }

    @Test func build_columnsAreUniqueWithinRow() {
        let repository = ExerciseRepository()
        let chain = repository.progressionChain(to: "planche")
        let model = service.build(from: chain)

        for band in model.bands {
            for row in band.rows {
                let columns = row.nodes.map(\.columnIndex)
                #expect(Set(columns).count == columns.count)
            }
        }
    }

    @Test func build_plancheSubgraphFromRepository() {
        let repository = ExerciseRepository()
        let chain = repository.progressionChain(to: "planche")
        let model = service.build(from: chain)

        #expect(!model.bands.isEmpty)
        #expect(containsExercise(id: "planche", in: model))
        #expect(containsExercise(id: "push_up", in: model))
        #expect(rowIndex(for: "push_up", in: model) == 0)
        #expect(bandLevel(for: "push_up", in: model) == .beginner)
        #expect(bandLevel(for: "planche", in: model) == .advanced)
    }

    // MARK: - Helpers

    private func makeExercise(
        id: Exercise.ID,
        level: Level,
        prerequisites: [Exercise.ID]
    ) -> Exercise {
        Exercise(
            id: id,
            name: id,
            description: nil,
            steps: nil,
            level: level,
            imageFile: nil,
            videoURL: "https://example.com",
            equipment: [],
            mastery: .reps(10),
            progression: nil,
            prerequisites: prerequisites
        )
    }

    private func rowIndex(for id: Exercise.ID, in model: ProgressionTreeModel) -> Int? {
        node(for: id, in: model)?.rowIndex
    }

    private func columnIndex(for id: Exercise.ID, in model: ProgressionTreeModel) -> Int? {
        node(for: id, in: model)?.columnIndex
    }

    private func bandLevel(for id: Exercise.ID, in model: ProgressionTreeModel) -> Level? {
        guard let node = node(for: id, in: model) else { return nil }
        return model.bands.first { band in
            band.rows.contains { $0.nodes.contains { $0.id == node.id } }
        }?.level
    }

    private func containsExercise(id: Exercise.ID, in model: ProgressionTreeModel) -> Bool {
        node(for: id, in: model) != nil
    }

    private func node(for id: Exercise.ID, in model: ProgressionTreeModel) -> ProgressionTreeNode? {
        for band in model.bands {
            for row in band.rows {
                if let node = row.nodes.first(where: { $0.id == id }) {
                    return node
                }
            }
        }
        return nil
    }
}
