// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_types_dao.dart';

// ignore_for_file: type=lint
mixin _$PlaceTypesDaoMixin on DatabaseAccessor<AppDatabase> {
  $PlaceTypesCacheTable get placeTypesCache => attachedDatabase.placeTypesCache;
  PlaceTypesDaoManager get managers => PlaceTypesDaoManager(this);
}

class PlaceTypesDaoManager {
  final _$PlaceTypesDaoMixin _db;
  PlaceTypesDaoManager(this._db);
  $$PlaceTypesCacheTableTableManager get placeTypesCache =>
      $$PlaceTypesCacheTableTableManager(
        _db.attachedDatabase,
        _db.placeTypesCache,
      );
}
