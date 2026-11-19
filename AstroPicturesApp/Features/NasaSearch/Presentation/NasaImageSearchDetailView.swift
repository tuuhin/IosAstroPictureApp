import SwiftUI

/// Detail screen pushed from the search grid. Renders the shared
/// ``AstroPictureDetailView`` and adds the hero (zoom) transition back to the
/// tapped tile.
struct NasaImageSearchDetailView: View {
    let result: NasaImageSearchResultModel
    let heroNamespace: Namespace.ID

    var body: some View {
        AstroPictureDetailView(result: result)
            .navigationTransition(.zoom(sourceID: result.id, in: heroNamespace))
            .navigationTitle(result.title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SearchDetailPreview()
}

private struct SearchDetailPreview: View {
    @Namespace private var heroNamespace

    var body: some View {
        NavigationStack {
            NasaImageSearchDetailView(result: .preview, heroNamespace: heroNamespace)
        }
    }
}

extension NasaImageSearchResultModel {
    fileprivate static let preview = NasaImageSearchResultModel(
        nasaId: "PIA21837",
        title: "NASA's Hubble Sees Martian Moon Orbiting the Red Planet",
        description:
            "The sharp eye of NASA's Hubble Space Telescope has captured the tiny moon "
            + "Phobos during its orbital trek around Mars.",
        mediaType: .image,
        center: "JPL",
        date: .now,
        keywords: ["MARS", "PHOBOS"],
        thumbnailURL: nil,
        largeURL: nil,
        manifestURL: nil
    )
}
