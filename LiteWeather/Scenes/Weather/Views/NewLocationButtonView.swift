import SwiftUI
#if DEBUG
import DomainTestingUtils
#endif

struct NewLocationButtonView: View {
    @Bindable var viewModel: WeatherViewModel

    var body: some View {
        Button {
            Task {
                await viewModel.reload()
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
    NewLocationButtonView(viewModel: .previewMadrid)
        .padding()
}
#endif
