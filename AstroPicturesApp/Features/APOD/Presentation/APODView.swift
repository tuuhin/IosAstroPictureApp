import SwiftUI

struct APODView: View {
    @State private var viewModel: APODViewModel = .init()

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Loading Picture of the Day…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case let .success(apod):
                APODContentView(apod: apod)
            case let .failure(error):
                ContentUnavailableView {
                    Label("Unable to Load", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error.localizedDescription)
                } actions: {
                    Button("Try Again") {
                        Task {
                            await viewModel.fetchToday()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .task {
            if case .idle = viewModel.state {
                await viewModel.fetchToday()
            }
        }
    }
}

#Preview {
    APODView()
}
