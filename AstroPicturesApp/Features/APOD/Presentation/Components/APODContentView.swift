import SwiftUI

struct APODContentView: View {
    let apod: AstroPictureModel
    let onToggleFavorite: @MainActor () -> Void

    var body: some View {
        NavigationStack {
            AstroPictureDetailView(
                picture: apod,
                isFavourite: apod.isFav,
                onToggleFavourite: onToggleFavorite
            )
            .navigationTitle("Astro Picture")
        }
    }
}

#Preview {
    APODContentView(apod: .preview, onToggleFavorite: {})
}

extension AstroPictureModel {
    fileprivate static let preview = AstroPictureModel(
        date: Date.now,
        postId: -1,
        title: "Astronomy Picture",
        mediaType: .image,
        description:
            "This is an example description of the astronomy picture of the day showing nebulas and distant galaxies.",
        credit: "NASA / ESA",
        copyRight: "NASA",
        alt: "Alternate String",
        url: "",
        hdURL: nil,
        isFav: true
    )
}
