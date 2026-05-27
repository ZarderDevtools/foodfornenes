import 'package:drift/drift.dart';

import '../app_database.dart';

part 'places_dao.g.dart';

@DriftAccessor(tables: [PlacesCache])
class PlacesDao extends DatabaseAccessor<AppDatabase> with _$PlacesDaoMixin {
  PlacesDao(super.db);

  Future<List<CachedPlace>> getAllPlaces() => select(placesCache).get();

  Future<void> upsertPlaces(List<PlacesCacheCompanion> rows) async {
    if (rows.isEmpty) return;
    final pendingIds = await (select(placesCache)
            ..where((t) => t.syncStatus.isNotIn(['synced'])))
        .get()
        .then((list) => list.map((r) => r.id).toSet());
    final safe = rows
        .where((r) => !pendingIds.contains(r.id.value))
        .toList();
    if (safe.isEmpty) return;
    await batch((b) => b.insertAllOnConflictUpdate(placesCache, safe));
  }

  Future<void> upsertPlace(PlacesCacheCompanion row) =>
      into(placesCache).insertOnConflictUpdate(row);

  Future<void> deletePlaceById(String id) async {
    await (delete(placesCache)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateSyncStatus(String id, String status) async {
    await (update(placesCache)..where((t) => t.id.equals(id))).write(
      PlacesCacheCompanion(syncStatus: Value(status)),
    );
  }

  Future<List<CachedPlace>> getPlacesByIds(List<String> ids) {
    if (ids.isEmpty) return Future.value(const []);
    return (select(placesCache)..where((t) => t.id.isIn(ids))).get();
  }
}
