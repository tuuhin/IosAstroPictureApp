import SwiftUI

/// Column math shared by the Explore and Search grids.
///
/// Reading the size class alone isn't enough: on a regular iPhone it stays
/// `.compact` in both orientations, so a grid would never reflow on rotation,
/// Split View or resize. Measuring the width actually available adapts to any
/// size change — which is also exactly what iPhone Duo needs.
enum AdaptiveGrid {
    static let spacing: CGFloat = 12
    static let targetTileWidth: CGFloat = 180
    static let horizontalInset: CGFloat = 16

    /// Even column count so the grid divides cleanly either side of a fold. An
    /// even split keeps a full column on each side of the curve instead of a
    /// tile straddling it.
    static func columnCount(for width: CGFloat) -> Int {
        guard width > 0 else { return 2 }

        let usable = max(width - horizontalInset * 2, targetTileWidth)
        let raw = Int((usable + spacing) / (targetTileWidth + spacing))
        return max(2, raw - (raw % 2))
    }

    static func columns(for width: CGFloat) -> [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: spacing),
            count: columnCount(for: width)
        )
    }
}
