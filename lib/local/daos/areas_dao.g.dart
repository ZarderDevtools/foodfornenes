// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'areas_dao.dart';

// ignore_for_file: type=lint
mixin _$AreasDaoMixin on DatabaseAccessor<AppDatabase> {
  $AreasCacheTable get areasCache => attachedDatabase.areasCache;
  AreasDaoManager get managers => AreasDaoManager(this);
}

class AreasDaoManager {
  final _$AreasDaoMixin _db;
  AreasDaoManager(this._db);
  $$AreasCacheTableTableManager get areasCache =>
      $$AreasCacheTableTableManager(_db.attachedDatabase, _db.areasCache);
}
