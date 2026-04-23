// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foods_dao.dart';

// ignore_for_file: type=lint
mixin _$FoodsDaoMixin on DatabaseAccessor<AppDatabase> {
  $FoodsCacheTable get foodsCache => attachedDatabase.foodsCache;
  FoodsDaoManager get managers => FoodsDaoManager(this);
}

class FoodsDaoManager {
  final _$FoodsDaoMixin _db;
  FoodsDaoManager(this._db);
  $$FoodsCacheTableTableManager get foodsCache =>
      $$FoodsCacheTableTableManager(_db.attachedDatabase, _db.foodsCache);
}
