// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'places_dao.dart';

// ignore_for_file: type=lint
mixin _$PlacesDaoMixin on DatabaseAccessor<AppDatabase> {
  $PlacesCacheTable get placesCache => attachedDatabase.placesCache;
  PlacesDaoManager get managers => PlacesDaoManager(this);
}

class PlacesDaoManager {
  final _$PlacesDaoMixin _db;
  PlacesDaoManager(this._db);
  $$PlacesCacheTableTableManager get placesCache =>
      $$PlacesCacheTableTableManager(_db.attachedDatabase, _db.placesCache);
}
