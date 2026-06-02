import 'package:drift/drift.dart';

import '../app_database.dart';

part 'visits_dao.g.dart';

@DriftAccessor(tables: [VisitsCache])
class VisitsDao extends DatabaseAccessor<AppDatabase> with _$VisitsDaoMixin {
  VisitsDao(super.db);

  Future<List<CachedVisit>> getVisitsByPlace(String placeId) =>
      (select(visitsCache)..where((t) => t.placeId.equals(placeId))).get();

  Future<void> upsertVisits(List<VisitsCacheCompanion> rows) async {
    if (rows.isEmpty) return;
    // Do not overwrite rows that have local-only pending state (pending_create,
    // pending_update, sync_failed). Their IDs are filtered out so the global
    // pull cannot clobber uncommitted local edits.
    final pendingIds = await (select(visitsCache)
            ..where((t) => t.syncStatus.isNotIn(['synced'])))
        .get()
        .then((list) => list.map((r) => r.id).toSet());
    final safe = rows
        .where((r) => !pendingIds.contains(r.id.value))
        .toList();
    if (safe.isEmpty) return;
    await batch((b) => b.insertAllOnConflictUpdate(visitsCache, safe));
  }

  Future<void> upsertVisit(VisitsCacheCompanion row) =>
      into(visitsCache).insertOnConflictUpdate(row);

  Future<void> deleteVisitById(String id) async {
    await (delete(visitsCache)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateSyncStatus(String id, String status) async {
    await (update(visitsCache)..where((t) => t.id.equals(id))).write(
      VisitsCacheCompanion(syncStatus: Value(status)),
    );
  }

  Future<List<CachedVisit>> getPendingByPlace(String placeId) =>
      (select(visitsCache)
            ..where(
              (t) =>
                  t.placeId.equals(placeId) &
                  t.syncStatus.equals('pending_create'),
            ))
          .get();

  Future<List<CachedVisit>> getVisitsByIds(List<String> ids) {
    if (ids.isEmpty) return Future.value(const []);
    return (select(visitsCache)..where((t) => t.id.isIn(ids))).get();
  }

  Future<CachedVisit?> getLatestSyncedVisitByPlace(String placeId) =>
      (select(visitsCache)
            ..where(
              (t) =>
                  t.placeId.equals(placeId) &
                  t.syncStatus.equals('synced'),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<void> updatePlaceId(String oldPlaceId, String newPlaceId) =>
      (update(visitsCache)..where((t) => t.placeId.equals(oldPlaceId)))
          .write(VisitsCacheCompanion(placeId: Value(newPlaceId)));
}
