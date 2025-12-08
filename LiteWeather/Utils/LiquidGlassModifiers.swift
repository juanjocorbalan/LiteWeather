import SwiftUI

// MARK: - Liquid Glass Effects (iOS 26+)

/// Applies liquid glass effect to card backgrounds with iOS 26+ availability check
struct LiquidGlassCardModifier: ViewModifier {
    let baseColor: Color
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            // iOS 26+: Liquid Glass effect
            content
                .glassEffect(.regular.tint(baseColor), in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(baseColor.opacity(0.7))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                )
        }
    }
}

/// Applies interactive liquid glass effect to buttons with iOS 26+ availability check
struct LiquidGlassButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .buttonStyle(.glassProminent)
        } else {
            content
                .background(Color.accentColor.gradient)
                .buttonStyle(.plain)
                .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
}

// MARK: - View Extensions

extension View {
    func liquidGlassCard(baseColor: Color = Color.surface, cornerRadius: CGFloat = 24) -> some View {
        modifier(LiquidGlassCardModifier(baseColor: baseColor, cornerRadius: cornerRadius))
    }

    func liquidGlassButton() -> some View {
        modifier(LiquidGlassButtonModifier())
    }
}
