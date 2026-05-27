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
repositories/      ← API calls + cache reads/writes, returns typed models
services/          ← api_client.dart (HTTP + auth)
                     global_sync_service.dart (TTL-based full pull + pending flush)
                     pending_sync_service.dart (SyncQueue processor)
                     places_service.dart, foods_service.dart
models/            ← Plain data classes (fromJson/toJson)
widgets/           ← Reusable UI: BottomBar3Slots, form fields
config/            ← api_config.dart (kBaseUrl), app_images.dart, app_icons.dart
local/             ← Drift (SQLite) database
  app_database.dart          ← AppDatabase, table definitions, migration strategy
  daos/                      ← one DAO per table (areas, foods, food_visits,
                                place_types, places, sync_queue, tags, visits)
```

### Generic form system (AddRecordScreen)
New record screens follow a declarative pattern:
1. Create an `AddRecordConfig` with a list of `FieldSpec` subclasses and an `onSubmit` callback.
2. Pass it to `AddRecordScreen`, which handles rendering, validation, and submission.

Available `FieldSpec` types: `TextFieldSpec`, `NumberFieldSpec`, `ChoiceFieldSpec<T>`, `RelationFieldSpec<T>`, `MultiRelationFieldSpec<T>`.

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

The current codebase uses **StatefulWidget + setState** throughout. There is no Riverpod or other state management library in use today.

The architectural target is **Riverpod** for new code or explicit refactors. Until then:
- Business logic should be kept **outside UI widgets** as much as possible (in repositories or services).
- Widgets should primarily focus on rendering UI.
- Do not introduce Riverpod or other state management libraries in a task unless the user explicitly requests it.

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

Model: `lib/models/visit.dart`. Repository: `lib/repositories/visits_repository.dart`. Local cache: `VisitsCache` table.

Current fields:
- `id`
- `placeId`
- `authorId`
- `date`
- `rating`
- `pricePp`
- `comment`
- `createdAt`

Creation flows: `AddVisitFlow` (standalone visit) and `AddFoodVisitFlow` (visit + food visit combined).

#### FoodVisit
Represents a specific food/dish consumed during a `Visit`.

Model: `lib/models/food_visit.dart`. Repository: `VisitsRepository` (food visits section). Local cache: `FoodVisitsCache` table.

Current fields:
- `id`
- `visitId`
- `foodId`
- `placeName`
- `date`
- `rating`
- `pricePp`
- `comment`
- `createdAt`

Creation flow: `AddFoodVisitFlow` (`lib/screens/foods/add_food_visit/`). Reuses or creates a `Visit` automatically before creating the `FoodVisit`.

### Main user flows

The current app revolves around these main flows:

- Authenticate with JWT
- Browse foods
- Browse places by category
- Filter and sort foods and places
- Create a new food
- Create a new place
- Create a new visit (standalone, via `AddVisitFlow`)
- Create a new food visit (food + visit combined, via `AddFoodVisitFlow`)
- View visit history for a place (`PlaceVisitsScreen`)
- View food visit history for a food (`FoodVisitsScreen`)

### Domain relationships

Current conceptual relationships:

- A `Place` has one `PlaceType`
- A `Place` can have many `Visit` records
- A `Visit` belongs to one `Place`
- A `Visit` can have many `FoodVisit` records
- A `FoodVisit` belongs to one `Visit` and one `Food`
- A `Food` is an independent catalog entry; it appears in `FoodVisit` records
- `PlaceType` acts as a catalog entity used to classify places

### Query/filter models

The app currently uses query objects to drive list screens and API filters:

- `PlaceListQuery`
- `FoodListQuery`

These objects are part of the current domain/application contract and should be preserved when extending list/filter behavior.

### Architectural note

The domain is fully modeled in Flutter: `Place`, `PlaceType`, `Food`, `Visit`, and `FoodVisit` all have dedicated models, repositories, cache tables, and list/detail flows. The offline-first sync layer covers all five entities.

---

## Offline / local database

### Overview

The app uses **Drift** (SQLite ORM) for local persistence. `AppDatabase` is defined in `lib/local/app_database.dart` and instantiated once in `main.dart`. Current schema version: **14**.

### Cache tables

| Table | Dart class | Entity |
|---|---|---|
| `FoodsCache` | `CachedFood` | Food |
| `PlacesCache` | `CachedPlace` | Place |
| `PlaceTypesCache` | `CachedPlaceType` | PlaceType |
| `AreasCache` | `CachedArea` | Area |
| `TagsCache` | `CachedTag` | Tag |
| `VisitsCache` | `CachedVisit` | Visit |
| `FoodVisitsCache` | `CachedFoodVisit` | FoodVisit |
| `SyncQueue` | `SyncQueueEntry` | Pending operations |

All entity tables have a `syncStatus TEXT` column with possible values: `synced`, `pending_create`, `sync_failed`.

### SyncQueue

`SyncQueue` stores operations that must be sent to the backend when connectivity is restored.

Key columns: `entityType` (`food`, `place`, `visit`, `food_visit`), `operation` (`create`), `localEntityId`, `payloadJson`, `status` (`pending` / `failed`), `retries`, `lastError`.

Only entries with `status = 'pending'` are retried. `status = 'failed'` (set on definitive 4xx) are skipped.

### Sync services

**`PendingSyncService`** (`lib/services/pending_sync_service.dart`):
- Reads `SyncQueue` entries and POSTs them to the backend in order: foods → places → visits → food_visits.
- On success: swaps local ID → backend ID in the cache table (atomic transaction), deletes the queue entry.
- On definitive 4xx: marks `status = 'failed'` and `syncStatus = 'sync_failed'` in the entity table.
- On 401 / 5xx / network error: leaves pending for the next attempt.
- `food_visit` creates use a **checkpoint**: if the Visit POST succeeds but the FoodVisit POST fails, `backendVisitId` is persisted in `payloadJson` so the Visit is not duplicated on retry.

**`GlobalSyncService`** (`lib/services/global_sync_service.dart`):
- Called from `HomeScreen.initState()`.
- `syncIfNeeded()`: runs only if TTL (30 min) has elapsed. Fire-and-forget from UI.
- `forceSync()`: ignores TTL; used via a debug button in `HomeScreen` (only in `kDebugMode`).
- Both paths call `_runSync()`, which: (1) flushes pending via `PendingSyncService`, then (2) pulls all pages of place types, areas, tags, foods, places, visits, food visits into the cache.

### Cache-first pattern

All list screens and creation flows follow this pattern:

1. Try local cache first (DAO read).
2. If cache is non-empty, show it immediately and trigger a background API refresh.
3. If cache is empty, call the API; on failure, show `_offlineEmpty` friendly state.
4. After API success, save results to cache via repository.

Repositories expose `getCached*()` methods that return `null` (no cache) or a typed list.

### Migrations

Migrations are defensive: each step checks `PRAGMA table_info` before `addColumn` to handle devices where a previous migration was interrupted. All migrations backfill `NULL` rows with the appropriate default (`'synced'`).

### Offline write pattern (creation flows)

When a creation POST fails with a network / 5xx error:
1. Insert the entity into its cache table with `syncStatus = 'pending_create'` and a `local_<microseconds>` ID.
2. Insert a row into `SyncQueue` with the full payload JSON.
3. Both writes happen inside `db.transaction(...)` to guarantee atomicity.
4. The UI proceeds as if the creation succeeded — the entity appears immediately in lists.
5. `PendingSyncService` will swap the local ID for the real backend ID on the next sync.

---

### Important implementation note

Some creation flows (for example `AddFoodFlow` or `AddVisitFlow`) still instantiate `ApiClient.create()` internally.

The correct long-term pattern is to create the `ApiClient` once in `main.dart` and pass it down through constructors.

When modifying or extending these flows:
- Prefer receiving the existing `ApiClient` from the parent screen
- Avoid creating additional `ApiClient` instances
- Do not perform a large refactor unless the task explicitly requires it