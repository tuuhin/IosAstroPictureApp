import SwiftUI

struct APODContentGroup: View {
    let state: APODScreenState
    let onTryAgain: @MainActor @Sendable () -> Void
    let onToggleFavourite: @MainActor () -> Void

    var body: some View {
        switch state {
        case .idle, .loading:
            ProgressView("Loading Picture of the Day…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case let .success(apod):
            APODContentView(apod: apod, onToggleFavorite: onToggleFavourite)
        case let .failure(error):
            ContentUnavailableView {
                Label("Unable to Load", systemImage: "exclamationmark.triangle")
            } description: {
                Text(error.localizedDescription)
            } actions: {
                Button("Try Again", action: onTryAgain)
                    .buttonStyle(.glassProminent)
            }
        }
    }
}
