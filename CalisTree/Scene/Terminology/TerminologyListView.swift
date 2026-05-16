// Created by Alex Skorulis on 16/5/2026.

import ASKCoordinator
import Knit
import Observation
import SwiftUI

struct TerminologyListView: View {
    @State var viewModel: TerminologyListViewModel

    init(viewModel: TerminologyListViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List(viewModel.terms) { term in
            Button {
                viewModel.showDetails(term)
            } label: {
                Text(term.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
        .navigationTitle("Terminology")
    }
}

#Preview {
    NavigationStack {
        TerminologyListView(
            viewModel: CalisTreeAssembly.testing().resolver.terminologyListViewModel()
        )
    }
    .environment(\.coordinator, Coordinator(root: MainPath.terminologyList))
}
