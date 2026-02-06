# Rick and Morty App - CLEAN Architecture

This Flutter application follows the CLEAN Architecture pattern for better code organization, testability, and maintainability.

## Project Structure

```
lib/
├── core/
│   └── service_locator.dart          # Dependency Injection setup
├── data/
│   ├── datasources/
│   │   └── character_remote_datasource.dart  # Remote API calls
│   └── repositories/
│       └── character_repository_impl.dart     # Repository implementation
├── domain/
│   ├── repositories/
│   │   └── character_repository.dart          # Repository interface
│   └── usecases/
│       └── character_usecases.dart            # Business logic (Use Cases)
├── models/
│   └── character.dart                # Data models
├── presentation/
│   ├── providers/
│   │   └── character_provider.dart    # State management (Provider pattern)
│   └── pages/
│       └── landing_page.dart          # UI layer
├── main.dart                          # App entry point
└── landing_page.dart                  # Main screen widget

```

## Architecture Layers

### 1. **Presentation Layer** (`presentation/`)
- Contains UI components and pages
- Uses Provider for state management
- `CharacterProvider` manages UI state
- `LandingPage` displays characters with pagination

### 2. **Domain Layer** (`domain/`)
- Contains business logic and use cases
- `CharacterRepository` (abstract) defines the contract
- Use Cases: `GetCharactersUseCase`, `GetCharacterByIdUseCase`, `GetMultipleCharactersUseCase`
- Independent of implementation details
- Framework-agnostic

### 3. **Data Layer** (`data/`)
- Implements domain repositories
- Contains data sources (local/remote)
- `CharacterRemoteDataSourceImpl` handles API calls
- `CharacterRepositoryImpl` implements the repository interface
- Handles all data fetching and transformation

### 4. **Core Layer** (`core/`)
- `ServiceLocator` handles dependency injection
- Sets up all dependencies for the application

## Data Flow

```
UI (LandingPage)
    ↓
CharacterProvider (State Management)
    ↓
Use Cases (GetCharactersUseCase)
    ↓
Repository (CharacterRepositoryImpl)
    ↓
Data Sources (CharacterRemoteDataSourceImpl)
    ↓
Rick and Morty API
```

## Key Benefits

1. **Separation of Concerns**: Each layer has a specific responsibility
2. **Testability**: Easy to mock and test each layer independently
3. **Maintainability**: Changes in one layer don't affect others
4. **Reusability**: Business logic is independent of UI framework
5. **Scalability**: Easy to add new features without modifying existing code
6. **Dependency Injection**: Loose coupling between components

## Dependencies

- `http: ^1.1.0` - HTTP client for API calls
- `provider: ^6.0.0` - State management solution

## Running the App

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Future Improvements

- Add local caching with `hive` or `sqflite`
- Add unit and widget tests
- Implement error handling with custom exception classes
- Add more sophisticated state management if needed
