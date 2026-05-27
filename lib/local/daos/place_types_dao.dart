import 'package:drift/drift.dart';

import '../app_database.dart';

part 'place_types_dao.g.dart';

@DriftAccessor(tables: [PlaceTypesCache])
class PlaceTypesDao extends DatabaseAccessor<AppDatabase>
    with _$PlaceTypesDaoMixin {
  PlaceTypesDao(super.db);

  Future<List<CachedPlaceType>> getAllPlaceTypes() =>
      select(placeTypesCache).get();

  Future<void> upsertPlaceTypes(List<PlaceTypesCacheCompanion> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(placeTypesCache, rows));
  }
}
