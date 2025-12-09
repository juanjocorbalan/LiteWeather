import SwiftUI
#if DEBUG
import Data
import DomainTestingUtils
#endif

struct WeatherConditionsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @ScaledMetric private var iconHeight: CGFloat = 64
    @ScaledMetric private var tempHeight: CGFloat = 54
    @Bindable var viewModel: WeatherViewModel
    let weather: WeatherPresentationModel
    
    private var isWideScreen: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .regular
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                locationHeader(weather)
                mainWeatherSection(weather)
                weatherDetailsGrid(weather)
                NewLocationButtonView(viewModel: viewModel)
            }
            .padding()
        }
        .overlay {
            if viewModel.isReloading {
                Color.backgroundPrimary.opacity(0.7)
                    .overlay {
                        LoadingView()
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel(String(localized: "loading_weather"))
            }
        }
        .accessibilityIdentifier(AccessibilityIdentifiers.WeatherView.contentView)
    }
    
    // MARK: - Location Header
    
    private func locationHeader(_ weather: WeatherPresentationModel) -> some View {
        VStack(spacing: 0) {
            Text(weather.location)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(Color.textPrimary)
                .accessibilityIdentifier(AccessibilityIdentifiers.WeatherContent.locationName)
            Text(weather.timestamp)
                .font(.caption2)
                .foregroundStyle(Color.secondary)
                .accessibilityIdentifier(AccessibilityIdentifiers.WeatherContent.locationTimestamp)
        }
        .accessibilityAddTraits(.isHeader)
    }
    
    // MARK: - Main Weather Section
    
    private func mainWeatherSection(_ weather: WeatherPresentationModel) -> some View {
        let numColumns = isWideScreen ? 2 : 1
        let columns = Array(repeating: GridItem(.flexible()), count: numColumns)
        
        return LazyVGrid(columns: columns, spacing: 16) {
            VStack(spacing: 0) {
                // Weather Icon
                Group {
                    if reduceMotion {
                        Image(systemName: weather.weatherIcon)
                            .font(.system(size: iconHeight))
                            .foregroundStyle(weather.weatherIconColor.gradient)
                            .symbolRenderingMode(.hierarchical)
                    } else {
                        Image(systemName: weather.weatherIcon)
                            .font(.system(size: iconHeight))
                            .foregroundStyle(weather.weatherIconColor.gradient)
                            .symbolRenderingMode(.hierarchical)
                            .symbolEffect(.bounce, value: weather)
                    }
                }
                .frame(height: iconHeight)
                .accessibilityLabel(weather.weatherDescription)
                .accessibilityIdentifier(AccessibilityIdentifiers.WeatherContent.weatherIcon)
                
                // Description
                if !weather.weatherDescription.isEmpty {
                    Text(weather.weatherDescription)
                        .font(.title3)
                        .foregroundStyle(Color.textSecondary)
                        .accessibilityIdentifier(AccessibilityIdentifiers.WeatherContent.weatherDescription)
                }
            }
            .accessibilityElement(children: .combine)
            
            VStack(spacing: 0) {
                Text(weather.currentTemperature)
                    .contentTransition(reduceMotion ? .identity : .numericText())
                    .font(.system(size: tempHeight, weight: .thin))
                    .foregroundStyle(Color.textPrimary)
                    .accessibilityIdentifier(AccessibilityIdentifiers.WeatherContent.currentTemperature)
                
                Text(weather.feelsLike)
                    .font(.subheadline)
                    .foregroundStyle(Color.textTertiary)
                    .accessibilityIdentifier(AccessibilityIdentifiers.WeatherContent.feelsLike)
            }
            .accessibilityElement(children: .combine)
        }
    }
    
    // MARK: - Weather Details Grid
    
    private func weatherDetailsGrid(_ weather: WeatherPresentationModel) -> some View {
        let numColumns = isWideScreen ? 3 : 2
        let columns = Array(repeating: GridItem(.flexible()), count: numColumns)
        
        return LazyVGrid(columns: columns, spacing: 16) {
            detailCard(
                icon: "thermometer.low",
                label: String(localized: "min_temp"),
                value: weather.minTemperature,
                color: Color.infoBlue,
                identifier: AccessibilityIdentifiers.WeatherContent.minTemperature
            )
            
            detailCard(
                icon: "thermometer.high",
                label: String(localized: "max_temp"),
                value: weather.maxTemperature,
                color: Color.warningOrange,
                identifier: AccessibilityIdentifiers.WeatherContent.maxTemperature
            )
            
            detailCard(
                icon: "wind",
                label: String(localized: "wind"),
                value: weather.windSpeed,
                color: Color.textSecondary,
                identifier: AccessibilityIdentifiers.WeatherContent.windSpeed
            )
            
            detailCard(
                icon: "humidity.fill",
                label: String(localized: "humidity"),
                value: weather.humidity,
                color: Color.infoBlue,
                identifier: AccessibilityIdentifiers.WeatherContent.humidity
            )
            
            detailCard(
                icon: "sunrise.fill",
                label: String(localized: "sunrise"),
                value: weather.sunrise,
                color: Color.warningOrange,
                identifier: AccessibilityIdentifiers.WeatherContent.sunrise
            )
            
            detailCard(
                icon: "sunset.fill",
                label: String(localized: "sunset"),
                value: weather.sunset,
                color: Color.warningOrange,
                identifier: AccessibilityIdentifiers.WeatherContent.sunset
            )
        }
    }
    
    // MARK: - Detail Card
    
    private func detailCard(icon: String, label: String, value: String, color: Color, identifier: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.textSecondary)
                .accessibilityHidden(true)
            
            Text(value)
                .contentTransition(reduceMotion ? .identity : .numericText())
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.textPrimary)
                .accessibilityLabel("\(label): \(value)")
                .accessibilityIdentifier(identifier)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .liquidGlassCard(baseColor: Color.surface, cornerRadius: 24)
    }
}

#if DEBUG
#Preview("Weather Conditions - Madrid") {
    let presentationModel = WeatherPresentationModel(weather: .madrid, measurementSystem: .metric)
    return WeatherConditionsView(viewModel: .previewMadrid, weather: presentationModel)
}

#Preview("Weather Conditions - Imperial System") {
    let presentationModel = WeatherPresentationModel(weather: .london, measurementSystem: .imperial)
    return WeatherConditionsView(viewModel: .previewLondon, weather: presentationModel)
}
#endif
