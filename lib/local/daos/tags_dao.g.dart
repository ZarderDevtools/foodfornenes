// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags_dao.dart';

// ignore_for_file: type=lint
mixin _$TagsDaoMixin on DatabaseAccessor<AppDatabase> {
  $TagsCacheTable get tagsCache => attachedDatabase.tagsCache;
  TagsDaoManager get managers => TagsDaoManager(this);
}

class TagsDaoManager {
  final _$TagsDaoMixin _db;
  TagsDaoManager(this._db);
  $$TagsCacheTableTableManager get tagsCache =>
      $$TagsCacheTableTableManager(_db.attachedDatabase, _db.tagsCache);
}
