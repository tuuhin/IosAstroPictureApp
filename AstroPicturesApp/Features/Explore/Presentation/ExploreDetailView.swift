import SwiftUI

/// Detail screen pushed from the Explore grid. Renders the shared
/// ``AstroPictureDetailView`` and adds the hero (zoom) transition back to the
/// tapped tile.
struct ExploreDetailView: View {
    let picture: AstroPictureModel
    let heroNamespace: Namespace.ID
    let onToggleFavourite: @MainActor (AstroPictureModel) -> Void

    @State private var isFavourite: Bool

    init(
        picture: AstroPictureModel,
        heroNamespace: Namespace.ID,
        onToggleFavourite: @escaping @MainActor (AstroPictureModel) -> Void
    ) {
        self.picture = picture
        self.heroNamespace = heroNamespace
        self.onToggleFavourite = onToggleFavourite
        _isFavourite = State(initialValue: picture.isFav)
    }

    var body: some View {
        AstroPictureDetailView(
            picture: picture,
            isFavourite: isFavourite,
            onToggleFavourite: toggleFavourite
        )
        .navigationTransition(.zoom(sourceID: picture.postId, in: heroNamespace))
        .navigationTitle(picture.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggleFavourite() {
        isFavourite.toggle()
        var updated = picture
        updated.isFav = isFavourite
        onToggleFavourite(updated)
    }
}

#Preview {
    ExploreDetailPreview()
}

private struct ExploreDetailPreview: View {
    @Namespace private var heroNamespace

    var body: some View {
        NavigationStack {
            ExploreDetailView(
                picture: .preview,
                heroNamespace: heroNamespace,
                onToggleFavourite: { _ in }
            )
        }
    }
}

extension AstroPictureModel {
    fileprivate static let preview = AstroPictureModel(
        date: Date.now,
        postId: -1,
        title: "A Distant Galaxy",
        mediaType: .image,
        description:
            "This is an example description of an astronomy picture showing nebulas and distant galaxies.",
        credit: "NASA / ESA",
        copyRight: "NASA",
        alt: "Alternate String",
        url: "",
        hdURL: nil,
        isFav: false
    )
}
