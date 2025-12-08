import SwiftUI

struct WeatherView: View {
    @State var viewModel: WeatherViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                LoadingView()
            case .loaded(let presentationModel):
                WeatherConditionsView(viewModel: viewModel, weather: presentationModel)
            case .error(let error):
                ErrorView(viewModel: viewModel, error: error)
            }
        }
        .background(Color.backgroundPrimary)
        .animation(.easeInOut(duration: 0.3), value: viewModel.state)
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.reload()
        }
        .task {
            if case .loading = viewModel.state {
                await viewModel.reload()
            }
        }
    }
}
