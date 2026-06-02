import 'package:drift/drift.dart';

import '../app_database.dart';

part 'food_visits_dao.g.dart';

@DriftAccessor(tables: [FoodVisitsCache])
class FoodVisitsDao extends DatabaseAccessor<AppDatabase>
    with _$FoodVisitsDaoMixin {
  FoodVisitsDao(super.db);

  Future<List<CachedFoodVisit>> getFoodVisitsByFood(String foodId) =>
      (select(foodVisitsCache)..where((t) => t.foodId.equals(foodId))).get();

  Future<void> upsertFoodVisits(List<FoodVisitsCacheCompanion> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(foodVisitsCache, rows));
  }

  Future<void> upsertFoodVisit(FoodVisitsCacheCompanion row) =>
      into(foodVisitsCache).insertOnConflictUpdate(row);

  Future<void> deleteFoodVisitById(String id) =>
      (delete(foodVisitsCache)..where((t) => t.id.equals(id))).go();

  Future<List<CachedFoodVisit>> getPendingByFood(String foodId) =>
      (select(foodVisitsCache)
            ..where(
              (t) =>
                  t.foodId.equals(foodId) &
                  (t.syncStatus.equals('pending_create') |
                      t.syncStatus.equals('sync_failed')),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<void> updateSyncStatus(String id, String status) =>
      (update(foodVisitsCache)..where((t) => t.id.equals(id)))
          .write(FoodVisitsCacheCompanion(syncStatus: Value(status)));

  Future<void> updateFoodId(String oldFoodId, String newFoodId) =>
      (update(foodVisitsCache)..where((t) => t.foodId.equals(oldFoodId)))
          .write(FoodVisitsCacheCompanion(foodId: Value(newFoodId)));
}
