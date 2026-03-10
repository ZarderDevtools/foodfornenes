# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app (debug)
flutter run

# Run on a specific device
flutter run -d <device-id>

# Build APK
flutter build apk

# Analyze and lint
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/path/to/file_test.dart

# Generate JSON serialization code (after modifying models with @JsonSerializable)
flutter pub run build_runner build --delete-conflicting-outputs
```

## Architecture

### Dependency injection pattern
There is no DI framework. `ApiClient` is a singleton created via `ApiClient.create()` (async factory) in `main.dart` and passed down manually through constructors. Repositories and services receive `ApiClient` as a constructor argument. Some flow screens (like `AddFoodFlow`) incorrectly call `ApiClient.create()` again internally — the correct pattern is to pass it from the parent.

### Layer structure
```
screens/           ← UI + navigation logic
  <entity>/
    <entity>_list_screen.dart
    add_<entity>/
      add_<entity>_flow.dart   ← builds AddRecordConfig + calls AddRecordScreen
repositories/      ← API calls, returns typed models
services/          ← api_client.dart (HTTP + auth), places_service.dart, foods_service.dart
models/            ← Plain data classes (fromJson/toJson)
widgets/           ← Reusable UI: BottomBar3Slots, form fields
config/            ← api_config.dart (kBaseUrl), app_images.dart, app_icons.dart
```

### Generic form system (AddRecordScreen)
New record screens follow a declarative pattern:
1. Create an `AddRecordConfig` with a list of `FieldSpec` subclasses and an `onSubmit` callback.
2. Pass it to `AddRecordScreen`, which handles rendering, validation, and submission.

Available `FieldSpec` types: `TextFieldSpec`, `NumberFieldSpec`, `ChoiceFieldSpec<T>`, `RelationFieldSpec<T>`.

`AddFormValues` (a `ChangeNotifier`) holds all field values and errors. Access values with `values.get<T>(key)` or `values.textOrEmpty(key)`.

`FieldValidators` provides reusable validators: `minLen`, `decimalNumber`, `intNumber`, `numberRange`, `nonNegative`.

### Bottom navigation bar
`BottomBar3Slots` (3 fixed slots: left, center, right) is the standard bottom bar. Use `floating: true` inside a `Stack`, or `floating: false` as `Scaffold.bottomNavigationBar`. Convention across screens: left = Home, center = primary action, right = Back.

`BottomAction` is the action model. Use factory constructors: `BottomAction.home()`, `BottomAction.back()`, `BottomAction.primary(icon, onTap)`.

### API client
`ApiClient` uses Dio with JWT auth (Bearer token). Tokens are stored in `flutter_secure_storage`. It handles automatic token refresh on 401 with a queue to prevent duplicate refresh calls. All HTTP errors are converted to `ApiException`.

Base URL: `https://foodfornenes-backend.onrender.com` (configured in `lib/config/api_config.dart`).

API paths follow the pattern `/api/v1/<resource>/`.

### Paginated responses
The backend returns paginated results. Use `PagedResult<T>.fromJson(data, fromJsonItem)` in repositories to parse them.

### Navigation
Named routes are only defined for top-level screens (Login, Home) in `main.dart`. All other navigation uses `Navigator.push` with `MaterialPageRoute`.
