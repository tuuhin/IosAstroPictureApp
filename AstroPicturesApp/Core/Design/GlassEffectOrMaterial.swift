import SwiftUI

struct GlassEffectOrMaterial: ViewModifier {
    let cornerRadius: RoundedRectangle

    init(cornerRadius: RoundedRectangle = RoundedRectangle(cornerRadius: 16)) {
        self.cornerRadius = cornerRadius
    }

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.clear, in: cornerRadius)
        } else {
            content.background(.ultraThinMaterial, in: cornerRadius)
        }
    }
}

extension View {
    func glassOrMaterial(cornerRadius: RoundedRectangle = RoundedRectangle(cornerRadius: 16)) -> some View {
        modifier(GlassEffectOrMaterial(cornerRadius: cornerRadius))
    }
}
