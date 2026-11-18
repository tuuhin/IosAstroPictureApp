import SwiftUI

struct APODContentView: View {
    let apod: AstroPictureModel
    let onToggleFavorite: @MainActor () -> Void

    @State var isDescriptionExpanded = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                imageWithOverLay
                detailsOverlay
                    .padding(.horizontal)
                    .padding(.bottom, 32)
            }
            .navigationTitle("Astro Picture")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: onToggleFavorite) {
                        Label("Favourite", systemImage: "heart")
                            .symbolVariant(apod.isFav ? .fill : .none)
                    }
                    .tint(apod.isFav ? .pink : .primary)
                    .animation(.easeInOut(duration: 0.2), value: apod.isFav)
                }
            }
        }
    }

    private var imageWithOverLay: some View {
        GeometryReader { geometry in
            ZStack {
                if apod.mediaType == .image {
                    // astro image
                    AstroImage(imageUrl: URL(string: apod.hdURL ?? apod.url))
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    Color.black
                }

                //  Graditent overlay
                LinearGradient(
                    colors: [.clear, .black.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)
            }
        }.ignoresSafeArea()
    }

    private var detailsOverlay: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Tags: Date & Media Type Badge
            HStack(spacing: 8) {
                Label(apod.date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())

                Label(apod.mediaType.rawValue.capitalized, systemImage: apod.mediaType == .image ? "photo.fill" : "play.tv.fill")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())

                Spacer()
            }
            .foregroundColor(.white.opacity(0.9))

            // Title
            Text(apod.title)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            // Description with tap-to-expand
            VStack(alignment: .leading, spacing: 6) {
                Text(apod.htmlToAttributedString)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(isDescriptionExpanded ? nil : 3)
                    .animation(.easeInOut(duration: 0.25), value: isDescriptionExpanded)

                Button {
                    withAnimation(.easeInOut) {
                        isDescriptionExpanded.toggle()
                    }
                } label: {
                    Text(isDescriptionExpanded ? "Show Less" : "Read More")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.blue.opacity(0.8))
                }
            }

            Divider()
                .frame(height: 1.0)
                .background(.regularMaterial, in: Capsule())

            // Footer Badges: Credits & Copyright
            HStack(alignment: .center, spacing: 12) {
                if let credit = apod.plainCredit, !credit.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CREDIT")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                        Text(credit)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                }

                if let copyright = apod.plainCopyright, !copyright.isEmpty {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("COPYRIGHT")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                        Text(copyright)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(24)
        .glassOrMaterial(cornerRadius: RoundedRectangle(cornerRadius: 24.0, style: .continuous))
    }
}

#Preview {
    APODContentView(apod: AstroPictureModel(
        date: Date.now,
        postId: -1,
        title: "Astronomy Picture",
        mediaType: .image,
        description: "This is an example description of the astronomy picture of the day showing nebulas and distant galaxies.",
        credit: "NASA / ESA",
        copyRight: "NASA",
        alt: "Alternate String",
        url: "",
        hdURL: nil,
        isFav: true
    ), onToggleFavorite: {})
}
