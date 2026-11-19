import PaletteKit
import SwiftUI

/// Ambient, palette-driven glow derived from an image.
///
/// PaletteKit extracts the picture's dominant colors, which are rendered as a
/// soft, blurred mesh gradient. Placing it behind a glass surface gives that
/// surface a sense of depth anchored to the picture itself.
struct PaletteGlowBackground: View {
    /// Remote image to sample. Pass `nil` (e.g. for videos) to render nothing.
    let imageURL: URL?

    @State private var palette: Palette?

    var body: some View {
        Group {
            if let palette {
                PaletteMeshGraphic(palette: palette, configuration: .init(gridSize: .standard))
                    .transition(.opacity)
            }
            else {
                Color.clear
            }
        }
        .blur(radius: 70, opaque: false)
        .opacity(0.7)
        .allowsHitTesting(false)
        .animation(.easeInOut(duration: 0.5), value: palette != nil)
        .task(id: imageURL) {
            await loadPalette()
        }
    }

    private func loadPalette() async {
        // A `.task` starts running on the main actor as soon as the view updates,
        // so a state write before the first suspension lands during the update
        // cycle ("Modifying state during view update"). Yield first to defer
        // the write to a later update.
        await Task.yield()
        guard !Task.isCancelled else { return }

        palette = await PaletteLoader.shared.palette(for: imageURL)
    }
}
