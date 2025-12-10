import SwiftUI
#if DEBUG
import Domain
import DomainTestingUtils
#endif

struct ErrorView: View {
    let error: LocalizedError
    var onRetry: (() async -> Void)? = nil

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.warningOrange)
                    .symbolRenderingMode(.hierarchical)

                Text(String(localized: "weather_unavailable"))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)
                    .accessibilityIdentifier(AccessibilityIdentifiers.Error.title)

                Text(error.localizedDescription)
                    .font(.body)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .accessibilityIdentifier(AccessibilityIdentifiers.Error.message)
            }

            Spacer()

            NewLocationButtonView(onRefresh: onRetry)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#if DEBUG
#Preview {
    ErrorView(error: DomainError.unavailable)
}
#endif
