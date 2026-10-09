import SwiftUI

struct APODContentView: View {
    let apod: APODModel

    init(apod: APODModel) {
        self.apod = apod

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Image("APODPreview")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                detailsOverlay
                    .padding(.horizontal, 20.0)
            }
            .navigationTitle("Picture of the day")
        }
    }

    /// Details overlay view handling version fallback
    private var detailsOverlay: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(apod.title)
                .font(.title2)
                .bold()
                .foregroundColor(.white)

            Text(apod.description)
                .font(.subheadline)
                .foregroundColor(.white)
                .lineLimit(3)

            if let credit = apod.credit {
                Text("Credit: \(credit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20.0)
        .glassOrMaterial()
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    APODContentView(apod: APODModel(
        date: Date.now,
        postId: -1,
        title: "Astronomy Picture",
        mediaType: .image,
        description: "This is an example description of the astronomy picture of the day showing nebulas and distant galaxies.",
        credit: "NASA / ESA",
        copyRight: "NASA",
        alt: "Alternate String",
        url: "",
        hdURL: nil
    ))
}
