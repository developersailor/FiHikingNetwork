# Copilot Instructions for FiHikingNetwork

## Project Overview
FiHikingNetwork is a hiking companion app designed to help users stay connected and avoid getting lost during hikes. The app leverages iBeacon technology and Apple Maps to provide real-time location tracking and group management features. The project follows the MVVM (Model-View-ViewModel) architecture.

### Key Components
- **Models**: Define the data structures (e.g., `BeaconInfo`, `Group`, `User`).
- **ViewModels**: Handle business logic and data management (e.g., `BeaconManager`, `GroupViewModel`, `MapViewModel`, `UserViewModel`).
- **Views**: SwiftUI-based UI components (e.g., `CreateGroupView`, `GroupMapView`, `ProfileView`).
- **Helpers**: Utility classes for specific tasks (e.g., `LocationHelper`, `QRCodeHelper`).
- **SwiftData**: Manages local data storage (e.g., `LocalDataManager`).

## Development Guidelines

### Architecture
- Follow the MVVM pattern:
  - **Model**: Represents the data.
  - **ViewModel**: Contains business logic and communicates with models.
  - **View**: Displays the UI and binds to ViewModels.

### Coding Standards
- Use Swift 6.2.
- Follow SwiftLint rules:
  - camelCase naming.
  - Maximum line length: 120 characters.
  - Function length: Max 40 lines.
- Avoid magic numbers; use constants (`let`).
- Write readable, reusable, and testable code.

### Dependency Management
- Use Swift Package Manager (SPM) for external libraries.
- Avoid using Podfile or Carthage unless necessary.
- Pin package versions and review updates regularly.

### Testing
- Write unit tests for all ViewModels and business logic.
- Use mock objects to isolate dependencies.
- Create UI tests for core user flows.
- Aim for at least 80% test coverage.

### Accessibility
- Add accessibility labels to all visual components.
- Support Dynamic Type and VoiceOver.
- Use color palettes suitable for color blindness and low vision.
- Test regularly with Accessibility Inspector.

### Localization
- Manage all user-facing text via `Localizable.strings`.
- Support at least English and Turkish.
- Automatically adjust date, time, and currency formats based on the user's region.

## Key Files and Directories
- **`FiHikingNetworkApp.swift`**: Entry point of the app.
- **`Models/`**: Data structures.
- **`ViewModels/`**: Business logic and data management.
- **`Views/`**: SwiftUI components.
- **`Helpers/`**: Utility classes.
- **`SwiftData/LocalDataManager.swift`**: Local data management.
- **`Info.plist`**: App configuration, including background modes for iBeacon and location services.

## Integration Points
- **iBeacon**: Use CoreLocation for beacon scanning and region monitoring.
- **Apple Maps**: Provide real-time location tracking and group visualization.
- **Firebase**: Manage user authentication and Firestore data storage.

## Developer Workflows

### Building and Running
- Open `FiHikingNetwork.xcodeproj` in Xcode.
- Select the appropriate scheme and device.
- Build and run the app using `Cmd + R`.

### Testing
- Run unit tests with `Cmd + U`.
- Use the `FiHikingNetworkTests` and `FiHikingNetworkUITests` targets for testing.

### Debugging
- Use Xcode's debugger and logging tools.
- Test iBeacon functionality with physical devices.

## Patterns and Conventions
- **SwiftUI Components**: Modular and reusable.
- **Error Handling**: Catch all errors in network and data operations. Log critical errors and display user-friendly messages.
- **Theming**: Consistent color palette with light and dark mode support.

## Notes for AI Agents
- Follow the MVVM architecture strictly.
- Ensure all new features include unit tests and adhere to coding standards.
- Use the `.cursor/rules/` directory for additional project-specific guidelines (e.g., `accessibility.mdc`, `ibeaconlogic.mdc`).
