import SwiftUI
#if DEBUG
import DomainTestingUtils
#endif

struct NewLocationButtonView: View {
    var onRefresh: (() async -> Void)? = nil

    var body: some View {
        Button {
            Task {
                await onRefresh?()
            }
        } label: {
            Label(String(localized: "refresh"), systemImage: "arrow.triangle.2.circlepath")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(.white)
        }
        .liquidGlassButton()
        .accessibilityLabel(String(localized: "refresh"))
        .accessibilityHint(String(localized: "retries_loading_data"))
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(AccessibilityIdentifiers.Actions.reloadButton)
    }
}

#if DEBUG
#Preview("Refresh Button") {
    NewLocationButtonView()
        .padding()
}
#endif
