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

## Working rules for Claude Code

Claude should behave as a senior Flutter engineer working inside an existing production codebase.

When making changes to this repository:

- Prefer **small, targeted modifications** instead of large refactors.
- **Preserve the current project structure** unless a structural change is clearly justified.
- It is allowed to **modify multiple files** if needed to implement a feature correctly.
- It is allowed to **create new files** when it improves readability or separation of concerns.
- Follow the **existing architecture and patterns already used in the codebase**.

Claude Code should **directly modify repository files** when implementing changes.

After completing a task, Claude should provide a **short summary including**:
- What was changed
- Which files were modified
- If any new files were created
- If `pubspec.yaml` was modified
- Any manual step the developer should perform

Avoid rewriting large parts of the project unless the user explicitly asks for a refactor.

---

## State management

State management should use **Riverpod**.

Guidelines:
- Prefer keeping business logic **outside UI widgets**.
- Use providers or notifiers to manage state.
- Widgets should primarily focus on rendering UI.

Do not introduce other state management libraries unless explicitly requested.

---

## Dependencies policy

External packages may be added **only if they provide clear value**.

Before adding a dependency:
- Prefer solutions already possible with Flutter/Dart standard libraries.
- Ensure the package is **well maintained and widely used**.
- Avoid adding packages for small or trivial functionality.

If a dependency is added:
- Update `pubspec.yaml`
- Briefly explain why the dependency is necessary.

---

## Architecture evolution guidelines

The current architecture should evolve gradually toward a **feature-oriented structure**.

Instead of grouping files only by type (screens, widgets, etc.), future code may progressively move toward:
features/
restaurants/
foods/
visits/


Within each feature the structure may include:
presentation/
data/
domain/


However, **this migration should be gradual**, and existing code should not be reorganized unless there is a clear benefit.

---

## Code quality expectations

All code written or modified should follow professional Flutter best practices:

- Use **null safety correctly**
- Prefer **small reusable widgets**
- Keep **business logic separate from UI**
- Avoid duplicating logic
- Follow existing naming conventions
- Write readable and maintainable code

When possible:
- Extract reusable UI into the `widgets/` folder
- Keep networking logic inside repositories/services
- Keep models as pure data objects

Provide **brief explanations** when introducing non-obvious design decisions.

## Domain model overview

This mobile app is used to register places where the user eats, foods/dishes, and visits made to those places.

### Current top-level app sections

The main functional areas of the app are:

- Authentication
- Home dashboard
- Foods catalog
- Places catalog
- Visit creation
- Generic add-record flows
- Filtering and sorting of lists

### Terminology

- `Place` is the generic entity representing any location related to food (restaurant, bakery, butcher shop, etc.).
- `Restaurant` is not a separate model; it is a `Place` whose `PlaceType` corresponds to restaurants.
- `Food` represents a dish or food item stored in the user's catalog.
- `Visit` represents an event of going to a `Place`, optionally with rating, price per person and comments.
- `PlaceType` represents the category used to classify a `Place`.

### Core domain entities

#### Place
Represents a place where the user can eat or buy food-related items.

Current fields used in the app include:
- `id`
- `householdId`
- `name`
- `placeTypeId`
- `areaId`
- `priceRange`
- `description`
- `url`
- `avgRating`
- `avgPricePp`
- `visitsCount`
- `lastVisitAt`
- `tags`
- `createdAt`
- `updatedAt`

A `Place` belongs to a `PlaceType` and can accumulate many visits over time.

Examples:
- restaurant
- bakery
- butcher shop
- other food-related locations

#### PlaceType
Represents the category of a place.

Current fields:
- `id`
- `name`

Examples:
- Restaurante
- Carnicería
- Panadería

`PlaceType` is used:
- on the home screen to group navigation
- when filtering place lists
- when creating a place
- when creating a visit

#### Food
Represents a food or dish that the user wants to keep in their catalog.

Current fields:
- `id`
- `householdId`
- `name`
- `isActive`
- `createdAt`
- `updatedAt`

Foods are currently managed as an independent catalog.

#### Visit
Represents a real visit to a place.

The app currently creates visits through `AddVisitFlow`, sending data directly to `/api/v1/visits/`.

Current fields used in the creation flow:
- `place`
- `date`
- `rating`
- `price_per_person`
- `comment`

Important:
- there is currently no dedicated `Visit` model in `lib/models`
- there is currently no dedicated `VisitsRepository`
- visits exist in the backend/API flow, but are only partially modeled in the Flutter codebase

### Main user flows

The current app revolves around these main flows:

- Authenticate with JWT
- Browse foods
- Browse places by category
- Filter and sort foods and places
- Create a new food
- Create a new place
- Create a new visit

### Domain relationships

Current conceptual relationships:

- A `Place` has one `PlaceType`
- A `Place` can have many `Visit` records
- A `Visit` belongs to one `Place`
- A `Food` is currently independent in the frontend domain model
- `PlaceType` acts as a catalog entity used to classify places

### Query/filter models

The app currently uses query objects to drive list screens and API filters:

- `PlaceListQuery`
- `FoodListQuery`

These objects are part of the current domain/application contract and should be preserved when extending list/filter behavior.

### Architectural note

The current domain is stronger around:
- places
- place categories
- foods
- visit creation

The visits area is not fully modeled yet in Flutter.
If future work expands visit history, visit lists, or visit detail screens, introducing:
- `Visit` model
- `VisitsRepository`
- dedicated visit list/detail flows

would be the natural evolution.

### Important implementation note

Some creation flows (for example `AddFoodFlow` or `AddVisitFlow`) still instantiate `ApiClient.create()` internally.

The correct long-term pattern is to create the `ApiClient` once in `main.dart` and pass it down through constructors.

When modifying or extending these flows:
- Prefer receiving the existing `ApiClient` from the parent screen
- Avoid creating additional `ApiClient` instances
- Do not perform a large refactor unless the task explicitly requires it