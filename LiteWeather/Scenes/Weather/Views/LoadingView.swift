import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .tint(Color.textPrimary)

            Text(String(localized: "loading_weather"))
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(localized: "loading_weather"))
        .accessibilityIdentifier(AccessibilityIdentifiers.WeatherView.loadingView)
    }
}
