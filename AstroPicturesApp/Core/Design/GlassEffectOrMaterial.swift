import SwiftUI

/// Wraps content in a Liquid Glass container on iOS 26+, falling back to an
/// `ultraThinMaterial` background on older systems.
struct GlassEffectOrMaterial<S: Shape>: ViewModifier {
    let shape: S

    init(shape: S) {
        self.shape = shape
    }

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.clear, in: shape)
        }
        else {
            content.background(.ultraThinMaterial, in: shape)
        }
    }
}

extension View {
    /// Wraps the view in a glass container using `shape` (or a material fallback).
    func glassOrMaterial<S: Shape>(_ shape: S) -> some View {
        modifier(GlassEffectOrMaterial(shape: shape))
    }

    /// Convenience for a rounded-rectangle container.
    func glassOrMaterial(cornerRadius: RoundedRectangle = RoundedRectangle(cornerRadius: 16))
        -> some View
    {
        glassOrMaterial(cornerRadius)
    }
}
