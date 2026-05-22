// Created by Alex Skorulis on 16/5/2026.

import Knit
import SwiftUI

struct TerminologyDetailView: View {
    @State var viewModel: TerminologyDetailViewModel

    init(viewModel: TerminologyDetailViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            Text(viewModel.terminology.details)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .navigationTitle(viewModel.terminology.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let term = Terminology(
        name: "Calisthenics",
        details: "A form of strength training that uses primarily bodyweight exercises."
    )
    NavigationStack {
        TerminologyDetailView(
            viewModel: ExerciseTreeAssembly.testing().resolver.terminologyDetailViewModel(terminology: term)
        )
    }
}
