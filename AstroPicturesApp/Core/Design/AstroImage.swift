import SwiftUI

struct AstroImage<Placeholder: View, Failure: View>: View {
    let imageUrl: URL
    let placeholder: () -> Placeholder
    let failure: (Error) -> Failure

    init(imageUrl: URL,
         @ViewBuilder placeholder: @escaping () -> Placeholder = { ProgressView().frame(height: 280) },
         @ViewBuilder failure: @escaping (Error) -> Failure = { _ in ContentUnavailableView("Failed to load the image", systemImage: "photo")
         })
    {
        self.imageUrl = imageUrl
        self.placeholder = placeholder
        self.failure = failure
    }

    var body: some View {
        if isPreview {
            Image("APODPreview")
        } else {
            remoteImage
        }
    }

    private var remoteImage: some View {
        AsyncImage(url: imageUrl) { phase in
            switch phase {
            case .empty:
                placeholder()
            case let .success(image):
                image
            case let .failure(error):
                failure(error)
            @unknown default:
                EmptyView()
            }
        }
    }

    private let isPreview: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}
