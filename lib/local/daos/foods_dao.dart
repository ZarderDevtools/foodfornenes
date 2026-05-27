import 'package:drift/drift.dart';

import '../app_database.dart';

part 'foods_dao.g.dart';

@DriftAccessor(tables: [FoodsCache])
class FoodsDao extends DatabaseAccessor<AppDatabase> with _$FoodsDaoMixin {
  FoodsDao(super.db);

  Future<List<CachedFood>> getAllFoods() => select(foodsCache).get();

  Future<void> upsertFoods(List<FoodsCacheCompanion> rows) async {
    if (rows.isEmpty) return;
    // Do not overwrite rows that have local-only pending state.
    final pendingIds = await (select(foodsCache)
            ..where((t) => t.syncStatus.isNotIn(['synced'])))
        .get()
        .then((list) => list.map((r) => r.id).toSet());
    final safe = rows
        .where((r) => !pendingIds.contains(r.id.value))
        .toList();
    if (safe.isEmpty) return;
    await batch((b) => b.insertAllOnConflictUpdate(foodsCache, safe));
  }

  Future<void> upsertFood(FoodsCacheCompanion row) =>
      into(foodsCache).insertOnConflictUpdate(row);

  Future<void> deleteFoodById(String id) async {
    await (delete(foodsCache)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateSyncStatus(String id, String status) async {
    await (update(foodsCache)..where((t) => t.id.equals(id))).write(
      FoodsCacheCompanion(syncStatus: Value(status)),
    );
  }

  Future<List<CachedFood>> getPendingFoods() =>
      (select(foodsCache)
            ..where((t) => t.syncStatus.equals('pending_create')))
          .get();
}
