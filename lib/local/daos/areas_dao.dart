import 'package:drift/drift.dart';

import '../app_database.dart';

part 'areas_dao.g.dart';

@DriftAccessor(tables: [AreasCache])
class AreasDao extends DatabaseAccessor<AppDatabase> with _$AreasDaoMixin {
  AreasDao(super.db);

  Future<List<CachedArea>> getAllAreas() => select(areasCache).get();

  Future<void> upsertAreas(List<AreasCacheCompanion> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(areasCache, rows));
  }
}
