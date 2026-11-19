import SwiftUI

/// Square artwork tile used by the Explore and Search grids.
struct AstroPictureTile: View {
    let title: String
    let date: Date?
    let artwork: AstroArtwork

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            image
            gradientOverlay
            details
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var image: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                switch artwork {
                case let .image(url):
                    AstroImage(imageUrl: url)
                        .scaledToFill()
                case .video, .audio:
                    placeholder
                }
            }
            .clipped()
    }

    private var placeholder: some View {
        ZStack {
            Color.black
            Image(systemName: artwork.placeholderSymbol)
                .font(.title2)
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    private var gradientOverlay: some View {
        LinearGradient(
            colors: [.clear, .black.opacity(0.7)],
            startPoint: .center,
            endPoint: .bottom
        )
        .allowsHitTesting(false)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let date {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
            }

            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .allowsHitTesting(false)
    }

}

extension AstroPictureTile {
    init(picture: AstroPictureModel) {
        let artwork: AstroArtwork =
            picture.mediaType == .image
            ? .image(URL(string: picture.hdURL ?? picture.url))
            : .video

        self.init(title: picture.title, date: picture.date, artwork: artwork)
    }

    init(result: NasaImageSearchResultModel) {
        let artwork: AstroArtwork =
            switch result.mediaType {
            case .image, .other: .image(result.thumbnailURL ?? result.largeURL)
            case .video: .video
            case .audio: .audio
            }

        self.init(title: result.title, date: result.date, artwork: artwork)
    }
}

#Preview("APOD") {
    AstroPictureTile(
        picture: AstroPictureModel(
            date: .now,
            postId: 1,
            title: "A Distant Galaxy",
            mediaType: .image,
            description: "Example",
            credit: "NASA",
            copyRight: nil,
            alt: nil,
            url: "",
            hdURL: nil,
            isFav: false
        )
    )
    .padding()
}

#Preview("Audio") {
    AstroPictureTile(
        title: "Houston We Have a Podcast",
        date: .now,
        artwork: .audio
    )
    .padding()
}
