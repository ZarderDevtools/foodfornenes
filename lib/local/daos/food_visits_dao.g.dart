// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_visits_dao.dart';

// ignore_for_file: type=lint
mixin _$FoodVisitsDaoMixin on DatabaseAccessor<AppDatabase> {
  $FoodVisitsCacheTable get foodVisitsCache => attachedDatabase.foodVisitsCache;
  FoodVisitsDaoManager get managers => FoodVisitsDaoManager(this);
}

class FoodVisitsDaoManager {
  final _$FoodVisitsDaoMixin _db;
  FoodVisitsDaoManager(this._db);
  $$FoodVisitsCacheTableTableManager get foodVisitsCache =>
      $$FoodVisitsCacheTableTableManager(
        _db.attachedDatabase,
        _db.foodVisitsCache,
      );
}
