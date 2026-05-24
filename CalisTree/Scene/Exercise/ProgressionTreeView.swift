// Created by Alex Skorulis on 18/5/2026.

import ASKCoordinator
import Knit
import SwiftUI

struct ProgressionTreeView: View {
    @State var viewModel: ProgressionTreeViewModel
    @Bindable private var mainStore: MainStore
    @State private var shareImage: UIImage?
    @State private var isShareSheetPresented = false

    init(viewModel: ProgressionTreeViewModel, mainStore: MainStore) {
        self._viewModel = State(initialValue: viewModel)
        self._mainStore = Bindable(mainStore)
    }

    var body: some View {
        let _ = mainStore.availableEquipment
        let model = viewModel.treeModel

        GeometryReader { geometry in
            let metrics = ProgressionTreeLayoutMetrics(
                model: model,
                containerWidth: geometry.size.width
            )

            ScrollView {
                ZStack(alignment: .topLeading) {
                    ForEach(Array(model.bands.enumerated()), id: \.element.level) { bandIndex, band in
                        bandBackground(band: band, bandIndex: bandIndex, metrics: metrics)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        ProgressionTreeContentView(
                            model: model,
                            metrics: metrics,
                            masteryProgress: viewModel.masteryProgress(for:),
                            showsBandBackgrounds: false,
                            onSelectExercise: { viewModel.showDetails(exercise: $0) }
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    shareTree()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .accessibilityLabel("Share progression tree")
            }
        }
        .sheet(isPresented: $isShareSheetPresented) {
            if let shareImage {
                ProgressionTreeShareSheet(image: shareImage)
                    .ignoresSafeArea()
            }
        }
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

    private func shareTree() {
        guard let image = viewModel.shareImage() else { return }
        shareImage = image
        isShareSheetPresented = true
    }
}

#Preview {
    let assembler = ExerciseTreeAssembly.testing()
    let exercise = assembler.resolver.exerciseRepository().exerciseById["planche"]!
    return NavigationStack {
        ProgressionTreeView(
            viewModel: assembler.resolver.progressionTreeViewModel(exercise: exercise),
            mainStore: assembler.resolver.mainStore()
        )
    }
    .environment(\.coordinator, Coordinator(root: MainPath.exerciseList))
}
