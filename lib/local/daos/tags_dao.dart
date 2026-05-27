import 'package:drift/drift.dart';

import '../app_database.dart';

part 'tags_dao.g.dart';

@DriftAccessor(tables: [TagsCache])
class TagsDao extends DatabaseAccessor<AppDatabase> with _$TagsDaoMixin {
  TagsDao(super.db);

  Future<List<CachedTag>> getAllTags() => select(tagsCache).get();

  Future<void> upsertTags(List<TagsCacheCompanion> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(tagsCache, rows));
  }
}
