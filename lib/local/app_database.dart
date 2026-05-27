import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/areas_dao.dart';
import 'daos/food_visits_dao.dart';
import 'daos/foods_dao.dart';
import 'daos/place_types_dao.dart';
import 'daos/places_dao.dart';
import 'daos/tags_dao.dart';
import 'daos/sync_queue_dao.dart';
import 'daos/visits_dao.dart';

part 'app_database.g.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb);
    if (decoded is! List) return [];
    return List<String>.from(decoded);
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

@DataClassName('CachedFood')
class FoodsCache extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  TextColumn get name => text()();
  BoolColumn get isActive => boolean()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('synced'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CachedPlaceType')
class PlaceTypesCache extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CachedPlace')
class PlacesCache extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  TextColumn get name => text()();
  TextColumn get placeTypeId => text()();
  TextColumn get areaId => text().nullable()();
  TextColumn get areaName => text().nullable()();
  TextColumn get priceRange => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get url => text().withDefault(const Constant(''))();
  RealColumn get avgRating => real().nullable()();
  RealColumn get avgPricePp => real().nullable()();
  IntColumn get visitsCount => integer()();
  DateTimeColumn get lastVisitAt => dateTime().nullable()();
  TextColumn get tags => text().map(const StringListConverter())();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('synced'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CachedArea')
class AreasCache extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CachedTag')
class TagsCache extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CachedVisit')
class VisitsCache extends Table {
  TextColumn get id => text()();
  TextColumn get placeId => text()();
  TextColumn get authorId => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get rating => real().nullable()();
  RealColumn get pricePp => real().nullable()();
  TextColumn get comment => text().withDefault(const Constant(''))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('synced'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CachedFoodVisit')
class FoodVisitsCache extends Table {
  TextColumn get id => text()();
  TextColumn get visitId => text()();
  TextColumn get foodId => text()();
  TextColumn get placeName => text().nullable()();
  DateTimeColumn get date => dateTime()();
  RealColumn get rating => real().nullable()();
  RealColumn get pricePp => real().nullable()();
  TextColumn get comment => text().withDefault(const Constant(''))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('synced'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SyncQueueEntry')
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get operation => text()();
  TextColumn get localEntityId => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retries => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
}

@DriftDatabase(
  tables: [
    FoodsCache,
    PlaceTypesCache,
    PlacesCache,
    AreasCache,
    TagsCache,
    VisitsCache,
    FoodVisitsCache,
    SyncQueue,
  ],
  daos: [
    FoodsDao,
    PlaceTypesDao,
    PlacesDao,
    AreasDao,
    TagsDao,
    VisitsDao,
    FoodVisitsDao,
    SyncQueueDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 14;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(placesCache);
          }
          if (from < 3) {
            await m.createTable(placeTypesCache);
          }
          if (from < 4) {
            await m.addColumn(placesCache, placesCache.description);
            await m.addColumn(placesCache, placesCache.url);
          }
          if (from < 5) {
            await m.createTable(areasCache);
            await m.createTable(tagsCache);
          }
          if (from < 6) {
            await m.createTable(visitsCache);
          }
          if (from < 7) {
            await m.createTable(foodVisitsCache);
          }
          if (from < 8) {
            await m.createTable(syncQueue);
            await m.addColumn(visitsCache, visitsCache.syncStatus);
          }
          if (from < 9) {
            // Defensive migration: handles the case where user_version was already
            // set to 8 but the physical migration did not complete (e.g. app was
            // killed mid-upgrade or schema was bumped before the migration existed).
            final cols = await m.database
                .customSelect('PRAGMA table_info(visits_cache)')
                .get();
            final hasSyncStatus =
                cols.any((r) => r.read<String>('name') == 'sync_status');
            if (!hasSyncStatus) {
              await m.addColumn(visitsCache, visitsCache.syncStatus);
            }

            final tbls = await m.database
                .customSelect(
                  "SELECT name FROM sqlite_master"
                  " WHERE type = 'table' AND name = 'sync_queue'",
                )
                .get();
            if (tbls.isEmpty) {
              await m.createTable(syncQueue);
            }
          }
          if (from < 10) {
            // Backfill rows where sync_status is NULL. This can happen when the
            // column was added via ALTER TABLE without the DEFAULT being physically
            // applied to existing rows (SQLite stores the default as metadata, but
            // some INSERT OR REPLACE paths bypass it). Setting 'synced' here is
            // safe: any genuinely-pending rows use 'pending_create' (set explicitly
            // on insert) and cannot be NULL.
            await m.database.customStatement(
              "UPDATE visits_cache SET sync_status = 'synced'"
              " WHERE sync_status IS NULL",
            );
          }
          if (from < 11) {
            // Defensive: add status column if not already present. Existing rows
            // are all either pending or failed; treating them as 'pending' lets
            // the sync service retry them once, which is the safe choice.
            final cols = await m.database
                .customSelect('PRAGMA table_info(sync_queue)')
                .get();
            final hasStatus =
                cols.any((r) => r.read<String>('name') == 'status');
            if (!hasStatus) {
              await m.addColumn(syncQueue, syncQueue.status);
            }
          }
          if (from < 12) {
            // Defensive: add sync_status to food_visits_cache if not present.
            // Backfill NULL rows as 'synced' — same pattern as v10 for visits_cache.
            final cols = await m.database
                .customSelect('PRAGMA table_info(food_visits_cache)')
                .get();
            final hasSyncStatus =
                cols.any((r) => r.read<String>('name') == 'sync_status');
            if (!hasSyncStatus) {
              await m.addColumn(foodVisitsCache, foodVisitsCache.syncStatus);
            }
            await m.database.customStatement(
              "UPDATE food_visits_cache SET sync_status = 'synced'"
              " WHERE sync_status IS NULL",
            );
          }
          if (from < 13) {
            // Add sync_status to foods_cache. Defensive: check first.
            // Backfill NULL rows as 'synced' — same pattern as prior migrations.
            final cols = await m.database
                .customSelect('PRAGMA table_info(foods_cache)')
                .get();
            final hasSyncStatus =
                cols.any((r) => r.read<String>('name') == 'sync_status');
            if (!hasSyncStatus) {
              await m.addColumn(foodsCache, foodsCache.syncStatus);
            }
            await m.database.customStatement(
              "UPDATE foods_cache SET sync_status = 'synced'"
              " WHERE sync_status IS NULL",
            );
          }
          if (from < 14) {
            // Add sync_status to places_cache. Defensive: check first.
            // Backfill NULL rows as 'synced' — same pattern as prior migrations.
            final cols = await m.database
                .customSelect('PRAGMA table_info(places_cache)')
                .get();
            final hasSyncStatus =
                cols.any((r) => r.read<String>('name') == 'sync_status');
            if (!hasSyncStatus) {
              await m.addColumn(placesCache, placesCache.syncStatus);
            }
            await m.database.customStatement(
              "UPDATE places_cache SET sync_status = 'synced'"
              " WHERE sync_status IS NULL",
            );
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'foodfornenes');
  }
}
