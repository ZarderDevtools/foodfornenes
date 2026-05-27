// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visits_dao.dart';

// ignore_for_file: type=lint
mixin _$VisitsDaoMixin on DatabaseAccessor<AppDatabase> {
  $VisitsCacheTable get visitsCache => attachedDatabase.visitsCache;
  VisitsDaoManager get managers => VisitsDaoManager(this);
}

class VisitsDaoManager {
  final _$VisitsDaoMixin _db;
  VisitsDaoManager(this._db);
  $$VisitsCacheTableTableManager get visitsCache =>
      $$VisitsCacheTableTableManager(_db.attachedDatabase, _db.visitsCache);
}
