import PaletteKit
import SwiftUI

/// Shared detail screen for a picture-like asset. It renders whichever source
/// produced the asset: APOD (HTML description, favourite toggle) or an image
/// library search hit (plain description, nothing to favourite).
struct AstroPictureDetailView: View {

    /// Everything the screen draws, normalised away from its source.
    struct Content {
        struct Chip {
            let icon: String
            let text: String
        }

        let title: String
        let chips: [Chip]
        let artwork: AstroArtwork
        let description: String
        /// APOD descriptions are HTML; search descriptions are plain text.
        let parsesHTMLDescription: Bool

        /// The styled description, built off the update cycle by the view.
        var preparedDescription: AttributedString {
            if parsesHTMLDescription {
                return description.htmlDetailDescription
            }
            return description.plainDetailDescription
        }
    }

    private let content: Content
    private let isFavourite: Bool
    private let showsFavouriteButton: Bool
    private let onToggleFavourite: () -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var palette: Palette?
    @State private var isDescriptionExpanded = false
    @State private var attributedDescription = AttributedString()

    private static let artworkCornerRadius: CGFloat = 16

    var body: some View {
        ZStack {
            background
            if horizontalSizeClass == .regular {
                regularLayout
            }
            else {
                compactLayout
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            if showsFavouriteButton {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: onToggleFavourite) {
                        Label("Favourite", systemImage: "heart")
                            .symbolVariant(isFavourite ? .fill : .none)
                    }
                    .tint(isFavourite ? .pink : .primary)
                    .animation(.easeInOut(duration: 0.2), value: isFavourite)
                }
            }
        }
        .task(id: imageURL) {
            await loadPalette()
        }
        .task(id: content.description) {
            // Parsing the HTML description uses NSAttributedString's WebKit
            // parser, which is main-thread-only and reentrant. Doing it in the
            // body corrupts the layout, so build it off the update cycle.
            await Task.yield()
            guard !Task.isCancelled else { return }
            attributedDescription = content.preparedDescription
        }
    }

    // MARK: - Background

    /// Full-bleed fill of the picture's dominant color, with a soft dark scrim
    /// toward the bottom so the white text stays legible.
    private var background: some View {
        ZStack {
            if let dominant = palette?.dominant {
                Color(cgColor: dominant.cgColor)
            }
            else {
                Color.black
            }

            LinearGradient(
                colors: [.clear, .black.opacity(0.55)],
                startPoint: .center,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.5), value: palette?.dominant)
    }

    // MARK: - Layout

    private var compactLayout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                artwork
                    .frame(maxWidth: 380)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)

                chipsRow
                thumbnailChip
                title
                descriptionSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private var regularLayout: some View {
        HStack(spacing: 0) {
            VStack {
                Spacer(minLength: 0)
                artwork
                    .frame(maxWidth: 460)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .padding(32)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    chipsRow
                    thumbnailChip
                    title
                    descriptionSection
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(32)
            }
            .scrollBounceBehavior(.basedOnSize)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Artwork

    private var artwork: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay { artworkContent }
            .clipShape(
                RoundedRectangle(cornerRadius: Self.artworkCornerRadius, style: .continuous)
            )
            .shadow(color: .black.opacity(0.35), radius: 24, y: 12)
    }

    @ViewBuilder
    private var artworkContent: some View {
        switch content.artwork {
        case let .image(url):
            AstroImage(imageUrl: url)
                .scaledToFill()
        case .video, .audio:
            placeholder
        }
    }

    private var placeholder: some View {
        ZStack {
            Color.black
            Image(systemName: content.artwork.placeholderSymbol)
                .font(.largeTitle)
                .foregroundStyle(.white.opacity(0.85))
        }
    }

    // MARK: - Chips

    /// Date, credit and copyright as an edge-scrolling row of icon + text chips.
    private var chipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(content.chips.enumerated()), id: \.offset) { _, chip in
                    statChip(icon: chip.icon, text: chip.text)
                }
            }
        }
    }

    private func statChip(icon: String, text: String) -> some View {
        Label(text, systemImage: icon)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .lineLimit(1)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .glassOrMaterial(Capsule())
    }

    /// Small rounded thumbnail of the picture, sitting on the line above the title.
    private var thumbnailChip: some View {
        Color.clear
            .frame(width: 44, height: 44)
            .overlay { artworkContent }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(.white.opacity(0.25), lineWidth: 1)
            }
    }

    // MARK: - Title & description

    private var title: some View {
        Text(content.title)
            .font(.largeTitle)
            .bold()
            .foregroundStyle(.white)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var descriptionSection: some View {
        if !content.description.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(attributedDescription)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .tint(.white)
                    .lineLimit(isDescriptionExpanded ? nil : 4)
                    .fixedSize(horizontal: false, vertical: true)
                    .animation(.easeInOut(duration: 0.25), value: isDescriptionExpanded)

                Button {
                    withAnimation(.easeInOut) {
                        isDescriptionExpanded.toggle()
                    }
                } label: {
                    Text(isDescriptionExpanded ? "Show Less" : "Read More")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
        }
    }

    // MARK: - Palette

    /// Image used both for the artwork and to sample the palette.
    private var imageURL: URL? {
        content.artwork.imageURL
    }

    private func loadPalette() async {
        // Defer the state write off the view-update cycle.
        await Task.yield()
        guard !Task.isCancelled else { return }
        palette = await PaletteLoader.shared.palette(for: imageURL)
    }
}

// MARK: - Initialisers

extension AstroPictureDetailView {
    init(
        picture: AstroPictureModel,
        isFavourite: Bool,
        onToggleFavourite: @escaping () -> Void
    ) {
        self.content = Content(picture: picture)
        self.isFavourite = isFavourite
        self.showsFavouriteButton = true
        self.onToggleFavourite = onToggleFavourite
    }

    /// Search hits are never persisted, so there is nothing to favourite.
    init(result: NasaImageSearchResultModel) {
        self.content = Content(result: result)
        self.isFavourite = false
        self.showsFavouriteButton = false
        self.onToggleFavourite = {}
    }
}

extension AstroPictureDetailView.Content {
    init(picture: AstroPictureModel) {
        var chips = [
            Chip(
                icon: "calendar",
                text: picture.date.formatted(date: .abbreviated, time: .omitted)
            )
        ]

        if let credit = picture.plainCredit, !credit.isEmpty {
            chips.append(Chip(icon: "camera", text: credit))
        }

        if let copyright = picture.plainCopyright, !copyright.isEmpty {
            chips.append(Chip(icon: "c.circle", text: copyright))
        }

        // `url` points at the article page for APOD, so prefer `hdURL`.
        let raw = picture.hdURL ?? picture.url
        let artwork: AstroArtwork =
            picture.mediaType == .image
            ? .image(raw.isEmpty ? nil : URL(string: raw))
            : .video

        self.init(
            title: picture.title,
            chips: chips,
            artwork: artwork,
            description: picture.description,
            parsesHTMLDescription: true
        )
    }

    init(result: NasaImageSearchResultModel) {
        var chips: [Chip] = []

        if let date = result.date {
            chips.append(
                Chip(
                    icon: "calendar",
                    text: date.formatted(date: .abbreviated, time: .omitted)
                )
            )
        }

        if let center = result.center, !center.isEmpty {
            chips.append(Chip(icon: "building.columns", text: center))
        }

        switch result.mediaType {
        case .video:
            chips.append(Chip(icon: "play.tv.fill", text: "Video"))
        case .audio:
            chips.append(Chip(icon: "music.note", text: "Audio"))
        case .image, .other:
            break
        }

        let artwork: AstroArtwork =
            switch result.mediaType {
            case .video: .video
            case .audio: .audio
            case .image, .other: .image(result.largeURL ?? result.thumbnailURL)
            }

        self.init(
            title: result.title,
            chips: chips,
            artwork: artwork,
            description: result.description ?? "",
            parsesHTMLDescription: false
        )
    }
}

#Preview("Compact") {
    NavigationStack {
        AstroPictureDetailView(picture: .preview, isFavourite: false, onToggleFavourite: {})
            .navigationTitle("Astro Picture")
    }
}

#Preview("Regular") {
    NavigationStack {
        AstroPictureDetailView(picture: .preview, isFavourite: true, onToggleFavourite: {})
            .navigationTitle("Astro Picture")
    }
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("Search Result") {
    NavigationStack {
        AstroPictureDetailView(
            result: NasaImageSearchResultModel(
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
        )
        .navigationTitle("Search Result")
    }
}

extension AstroPictureModel {
    fileprivate static let preview = AstroPictureModel(
        date: Date.now,
        postId: -1,
        title: "A Distant Galaxy",
        mediaType: .image,
        description:
            "This is an example description of an astronomy picture showing nebulas and distant galaxies. "
            + "See the <a href=\"https://apod.nasa.gov\">APOD archive</a> for more.",
        credit: "NASA / ESA",
        copyRight: "NASA",
        alt: "Alternate String",
        url: "",
        hdURL: nil,
        isFav: false
    )
}
