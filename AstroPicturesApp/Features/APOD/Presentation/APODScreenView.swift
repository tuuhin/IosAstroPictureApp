import SwiftUI

struct APODScreenView: View {
    @State private var viewModel: APODViewModel = .init()

    var body: some View {
        APODContentGroup(
            state: viewModel.state,
            onTryAgain: {
                // Re-subscribing triggers bootstrap again on next stream value
                Task {
                    await viewModel.observe()
                }
            },
            onToggleFavourite: {
                Task {
                    await viewModel.toggleFavourite()
                }
            }
        )
        .task {
            await viewModel.observe()
        }
    }
}
