import SwiftUI
#if DEBUG
import DomainTestingUtils
#endif

struct WeatherView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var viewModel: WeatherViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                LoadingView()
            case .loaded(let presentationModel):
                WeatherConditionsView(
                    weather: presentationModel,
                    isReloading: viewModel.isReloading,
                    onRefresh: { await viewModel.reload() }
                )
            case .error(let error):
                ErrorView(
                    error: error,
                    onRetry: { await viewModel.reload() }
                )
            }
        }
        .background(Color.backgroundPrimary)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: viewModel.state)
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if case .loading = viewModel.state {
                await viewModel.reload()
            }
        }
    }
}

#if DEBUG
#Preview("Success - Madrid") {
    NavigationStack {
        WeatherView(viewModel: .previewMadrid)
    }
}

#Preview("Error - Unknown") {
    NavigationStack {
        WeatherView(viewModel: .previewErrorUnknown)
    }
}

#Preview("Error - Unavailable") {
    NavigationStack {
        WeatherView(viewModel: .previewErrorUnavailable)
    }
}
#endif
