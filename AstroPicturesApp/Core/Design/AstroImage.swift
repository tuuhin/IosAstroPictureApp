import SwiftUI

struct AstroImage<Placeholder: View, Failure: View>: View {
    let imageUrl: URL?
    @ViewBuilder let placeholder: () -> Placeholder
    @ViewBuilder let failure: (Error?) -> Failure

    var body: some View {
        if isXcodePreview {
            // An preview image as this is a xc preview
            Image("APODPreview")
                .resizable()
        } else if let imageUrl {
            // check the imageurl not null if yes load the async image result
            AsyncImage(url: imageUrl) { phase in
                switch phase {
                case .empty:
                    placeholder()
                case let .success(image):
                    image.resizable()
                case let .failure(error):
                    failure(error)
                @unknown default:
                    placeholder()
                }
            }
        } else {
            failure(nil)
        }
    }

    private var isXcodePreview: Bool {
        #if DEBUG
            return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        #else
            return false
        #endif
    }
}

extension AstroImage where Placeholder == ProgressView<EmptyView, EmptyView>, Failure == AnyView {
    init(imageUrl: URL?) {
        self.init(
            imageUrl: imageUrl,
            placeholder: {
                ProgressView()
            },
            failure: { _ in
                AnyView(ContentUnavailableView("Failed to load image", systemImage: "photo"))
            }
        )
    }
}
