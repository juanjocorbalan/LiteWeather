# LiteWeather iOS App

LiteWeather is an iOS application that displays weather information using the OpenWeatherMap API.

---

## Overview

- **Clean Architecture** with strict layer separation (Domain → Data → Presentation)
- **Swift 6** features (typed throws, Sendable, async/await)
- **Comprehensive testing** (14 test files + UI tests)
- **Protocol-oriented design** for maximum testability
- **Zero third-party dependencies** - Pure iOS SDK

### Key Features
- Random global weather with detailed metrics (temperature, humidity, wind, sun times)
- Current location weather via CoreLocation
- Locale-aware formatting
- Full accessibility support with VoiceOver
- UI testing infrastructure with scenario injection
- Liquid Glass UI effects (iOS 26+) with fallback

---

## Architecture

Three-layer Clean Architecture with **zero Domain dependencies**:

### Domain Layer (`Packages/Domain`)
**Pure business logic - platform agnostic**

- **Entities**: Weather, Coordinates, Temperature, Location, WeatherCondition
- **Use Cases**: GetCurrentWeatherUseCase, GetWeatherAtLocationUseCase
- **Protocols**: WeatherRepository, CoordinatesProvider
- **Errors**: Typed throws with `DomainError` (unavailable, unauthorized, invalidData, unknown)

### Data Layer (`Packages/Data`)
**External data sources - depends only on Domain**

- **Remote**: Generic `APIClient` protocol + URLSession implementation with retry logic
- **DTOs**: OpenWeatherMap structure with `DomainRepresentable` mapping
- **Repository**: `WeatherRepositoryImpl` with error translation
- **Error Boundary**: APIError → DomainError mapping
- **Retry Logic**: Exponential backoff for network requests

### Presentation Layer (App)
**SwiftUI-based iOS application**

- **Views**: MainView, WeatherView, WeatherConditionsView, LoadingView, ErrorView
- **State**: @Observable ViewModels + Presentation Models for formatting
- **Navigation**: MainNavigator with type-safe routes
- **DI**: Compile-time safe DependencyContainer
- **UI Testing**: Mock injection via launch arguments (`--uitesting`, `--scenario=success-madrid`)

### Key Design Decisions

- **Sendable conformance**: All types thread-safe for Swift 6 concurrency
- **Typed throws**: `async throws(DomainError)` throughout the stack
- **Dedicated testing utilities**: Separate SPM targets (DomainTestingUtils, DataTestingUtils)
  - Factory methods: `MockGetWeatherAtLocationUseCase.madrid()`, `.errorUnavailable()`
  - Preview helpers: `WeatherViewModel.previewMadrid`, `.previewErrorUnavailable`
- **Three-layer error strategy**: `APIError` → `DomainError` → `LocalizedError`
- **Modern SwiftUI**: @Observable (no Combine/ObservableObject), @Bindable for bindings
- **UI/UX**: Liquid Glass effects (iOS 26+) with fallback, responsive layouts, symbol animations

---

## Testing

### Test Infrastructure

- **DomainTestingUtils**: Mock implementations with factory methods
  ```swift
  MockGetWeatherAtLocationUseCase.madrid()
  MockGetWeatherAtLocationUseCase.errorUnavailable()
  ```
  Weather fixtures: `.madrid`, `.london`, `.newYork`, `.rome`

- **DataTestingUtils**: `URLProtocolStub` for thread-safe network stubbing, JSON fixtures

- **UI Testing**: Scenario-based testing with launch arguments
  ```swift
  app.launchArguments = ["--uitesting", "--scenario=success-madrid", "--delay=2.0"]
  ```
  7 scenarios: success-madrid, success-london, success-newyork, error-unknown, error-unavailable, error-unauthorized, error-invaliddata

- **Preview Helpers**: Static ViewModel properties for SwiftUI previews
  ```swift
  WeatherView(viewModel: .previewMadrid)
  WeatherView(viewModel: .previewErrorUnavailable)
  ```

### Running Tests

```bash
# All tests
⌘U in Xcode

# Specific target
xcodebuild test -scheme LiteWeather -destination 'platform=iOS Simulator,name=iPhone 15'

# Package tests
cd Packages/Domain && swift test
cd Packages/Data && swift test
```

---

## Deliberate Trade-offs

### What was prioritized
- Clean Architecture with comprehensive testing
- Swift 6 adoption (typed throws, Sendable, async/await)
- Protocol-oriented design (every dependency mockable)
- Testing infrastructure (thread-safe URL stubbing, scenario-based UI tests)

### Intentionally Simplified
- **Two-screen app** (Navigator shows multi-screen readiness)
- **Minimal UI polish** (architecture over design)
- **Hardcoded API key** (challenge constraint - production uses Keychain/env vars)

### Why This Approach?

A simple weather app could be much simpler. This architecture includes:
- 2 SPM packages with dedicated testing targets
- 14 test files with focused unit tests
- Thread-safe URL stubbing
- Scenario-based UI testing system
- Full accessibility implementation
- i18n with 2 languages (English/Spanish)

**Goal**: Demonstrate scalable, maintainable iOS architecture.

---

## Building & Running

### Requirements
- Xcode 16.0+ (Swift 6.2)
- iOS 17.6+

### Quick Start
```bash
open LiteWeather.xcodeproj
# Select LiteWeather scheme, choose simulator
# ⌘R to build and run
```

### API Configuration
OpenWeatherMap key hardcoded in `Packages/Data/Sources/Data/Clients/APIConfig.swift` (challenge only—production uses Keychain/environment variables)

Location permissions configured in Info.plist with `NSLocationWhenInUseUsageDescription`

---

## Dependencies

**Zero third-party dependencies** - Uses only iOS SDK frameworks:
- Foundation, SwiftUI, CoreLocation
- Observation (state management)
- XCTest (UI tests)

---

## Design Principles

### SOLID Principles
**Single Responsibility**, **Open/Closed**, **Liskov Substitution**, **Interface Segregation**, **Dependency Inversion**

Examples:
- WeatherViewModel: State management only
- Protocol-based abstractions allow extension without modification
- All implementations perfectly substitutable with mocks
- Focused protocols (single methods, no "fat interfaces")
- Use cases depend on abstractions (WeatherRepository protocol), not implementations

### Additional Patterns
**Repository**, **Use Case**, **Presentation Model**, **Dependency Injection**, **Error Boundary**

---

## Additional Features

- **Localization**: English/Spanish with locale-aware formatting (metric/imperial)
- **Accessibility**: VoiceOver support, Dynamic Type, centralized identifiers
- **Liquid Glass UI**: iOS 26+ glass effects with automatic fallback
- **Symbol Effects**: Bounce animation on temperature changes
- **Responsive Design**: column grids based on device size
