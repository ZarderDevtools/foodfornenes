import 'package:drift/drift.dart';

import '../app_database.dart';

part 'foods_dao.g.dart';

@DriftAccessor(tables: [FoodsCache])
class FoodsDao extends DatabaseAccessor<AppDatabase> with _$FoodsDaoMixin {
  FoodsDao(super.db);

  Future<List<CachedFood>> getAllFoods() => select(foodsCache).get();

  Future<void> upsertFoods(List<FoodsCacheCompanion> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(foodsCache, rows));
  }
}
