// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FoodsCacheTable extends FoodsCache
    with TableInfo<$FoodsCacheTable, CachedFood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    name,
    isActive,
    syncStatus,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'foods_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedFood> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedFood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedFood(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FoodsCacheTable createAlias(String alias) {
    return $FoodsCacheTable(attachedDatabase, alias);
  }
}

class CachedFood extends DataClass implements Insertable<CachedFood> {
  final String id;
  final String householdId;
  final String name;
  final bool isActive;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CachedFood({
    required this.id,
    required this.householdId,
    required this.name,
    required this.isActive,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['name'] = Variable<String>(name);
    map['is_active'] = Variable<bool>(isActive);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FoodsCacheCompanion toCompanion(bool nullToAbsent) {
    return FoodsCacheCompanion(
      id: Value(id),
      householdId: Value(householdId),
      name: Value(name),
      isActive: Value(isActive),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CachedFood.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedFood(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      name: serializer.fromJson<String>(json['name']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'name': serializer.toJson<String>(name),
      'isActive': serializer.toJson<bool>(isActive),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CachedFood copyWith({
    String? id,
    String? householdId,
    String? name,
    bool? isActive,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CachedFood(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    name: name ?? this.name,
    isActive: isActive ?? this.isActive,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CachedFood copyWithCompanion(FoodsCacheCompanion data) {
    return CachedFood(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      name: data.name.present ? data.name.value : this.name,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedFood(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    householdId,
    name,
    isActive,
    syncStatus,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedFood &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.name == this.name &&
          other.isActive == this.isActive &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FoodsCacheCompanion extends UpdateCompanion<CachedFood> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<String> name;
  final Value<bool> isActive;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FoodsCacheCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.name = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodsCacheCompanion.insert({
    required String id,
    required String householdId,
    required String name,
    required bool isActive,
    this.syncStatus = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       name = Value(name),
       isActive = Value(isActive),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CachedFood> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<String>? name,
    Expression<bool>? isActive,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodsCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<String>? name,
    Value<bool>? isActive,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FoodsCacheCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodsCacheCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaceTypesCacheTable extends PlaceTypesCache
    with TableInfo<$PlaceTypesCacheTable, CachedPlaceType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaceTypesCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'place_types_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedPlaceType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedPlaceType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedPlaceType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $PlaceTypesCacheTable createAlias(String alias) {
    return $PlaceTypesCacheTable(attachedDatabase, alias);
  }
}

class CachedPlaceType extends DataClass implements Insertable<CachedPlaceType> {
  final String id;
  final String name;
  const CachedPlaceType({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  PlaceTypesCacheCompanion toCompanion(bool nullToAbsent) {
    return PlaceTypesCacheCompanion(id: Value(id), name: Value(name));
  }

  factory CachedPlaceType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedPlaceType(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  CachedPlaceType copyWith({String? id, String? name}) =>
      CachedPlaceType(id: id ?? this.id, name: name ?? this.name);
  CachedPlaceType copyWithCompanion(PlaceTypesCacheCompanion data) {
    return CachedPlaceType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedPlaceType(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedPlaceType &&
          other.id == this.id &&
          other.name == this.name);
}

class PlaceTypesCacheCompanion extends UpdateCompanion<CachedPlaceType> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const PlaceTypesCacheCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaceTypesCacheCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<CachedPlaceType> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaceTypesCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return PlaceTypesCacheCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaceTypesCacheCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlacesCacheTable extends PlacesCache
    with TableInfo<$PlacesCacheTable, CachedPlace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlacesCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeTypeIdMeta = const VerificationMeta(
    'placeTypeId',
  );
  @override
  late final GeneratedColumn<String> placeTypeId = GeneratedColumn<String>(
    'place_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaIdMeta = const VerificationMeta('areaId');
  @override
  late final GeneratedColumn<String> areaId = GeneratedColumn<String>(
    'area_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaNameMeta = const VerificationMeta(
    'areaName',
  );
  @override
  late final GeneratedColumn<String> areaName = GeneratedColumn<String>(
    'area_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceRangeMeta = const VerificationMeta(
    'priceRange',
  );
  @override
  late final GeneratedColumn<String> priceRange = GeneratedColumn<String>(
    'price_range',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _avgRatingMeta = const VerificationMeta(
    'avgRating',
  );
  @override
  late final GeneratedColumn<double> avgRating = GeneratedColumn<double>(
    'avg_rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avgPricePpMeta = const VerificationMeta(
    'avgPricePp',
  );
  @override
  late final GeneratedColumn<double> avgPricePp = GeneratedColumn<double>(
    'avg_price_pp',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visitsCountMeta = const VerificationMeta(
    'visitsCount',
  );
  @override
  late final GeneratedColumn<int> visitsCount = GeneratedColumn<int>(
    'visits_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastVisitAtMeta = const VerificationMeta(
    'lastVisitAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastVisitAt = GeneratedColumn<DateTime>(
    'last_visit_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>(
        'tags',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($PlacesCacheTable.$convertertags);
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    name,
    placeTypeId,
    areaId,
    areaName,
    priceRange,
    description,
    url,
    avgRating,
    avgPricePp,
    visitsCount,
    lastVisitAt,
    tags,
    syncStatus,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'places_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedPlace> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('place_type_id')) {
      context.handle(
        _placeTypeIdMeta,
        placeTypeId.isAcceptableOrUnknown(
          data['place_type_id']!,
          _placeTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_placeTypeIdMeta);
    }
    if (data.containsKey('area_id')) {
      context.handle(
        _areaIdMeta,
        areaId.isAcceptableOrUnknown(data['area_id']!, _areaIdMeta),
      );
    }
    if (data.containsKey('area_name')) {
      context.handle(
        _areaNameMeta,
        areaName.isAcceptableOrUnknown(data['area_name']!, _areaNameMeta),
      );
    }
    if (data.containsKey('price_range')) {
      context.handle(
        _priceRangeMeta,
        priceRange.isAcceptableOrUnknown(data['price_range']!, _priceRangeMeta),
      );
    } else if (isInserting) {
      context.missing(_priceRangeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('avg_rating')) {
      context.handle(
        _avgRatingMeta,
        avgRating.isAcceptableOrUnknown(data['avg_rating']!, _avgRatingMeta),
      );
    }
    if (data.containsKey('avg_price_pp')) {
      context.handle(
        _avgPricePpMeta,
        avgPricePp.isAcceptableOrUnknown(
          data['avg_price_pp']!,
          _avgPricePpMeta,
        ),
      );
    }
    if (data.containsKey('visits_count')) {
      context.handle(
        _visitsCountMeta,
        visitsCount.isAcceptableOrUnknown(
          data['visits_count']!,
          _visitsCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_visitsCountMeta);
    }
    if (data.containsKey('last_visit_at')) {
      context.handle(
        _lastVisitAtMeta,
        lastVisitAt.isAcceptableOrUnknown(
          data['last_visit_at']!,
          _lastVisitAtMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedPlace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedPlace(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      placeTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_type_id'],
      )!,
      areaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_id'],
      ),
      areaName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_name'],
      ),
      priceRange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}price_range'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      avgRating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_rating'],
      ),
      avgPricePp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_price_pp'],
      ),
      visitsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}visits_count'],
      )!,
      lastVisitAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_visit_at'],
      ),
      tags: $PlacesCacheTable.$convertertags.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tags'],
        )!,
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlacesCacheTable createAlias(String alias) {
    return $PlacesCacheTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertertags =
      const StringListConverter();
}

class CachedPlace extends DataClass implements Insertable<CachedPlace> {
  final String id;
  final String householdId;
  final String name;
  final String placeTypeId;
  final String? areaId;
  final String? areaName;
  final String priceRange;
  final String description;
  final String url;
  final double? avgRating;
  final double? avgPricePp;
  final int visitsCount;
  final DateTime? lastVisitAt;
  final List<String> tags;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CachedPlace({
    required this.id,
    required this.householdId,
    required this.name,
    required this.placeTypeId,
    this.areaId,
    this.areaName,
    required this.priceRange,
    required this.description,
    required this.url,
    this.avgRating,
    this.avgPricePp,
    required this.visitsCount,
    this.lastVisitAt,
    required this.tags,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['name'] = Variable<String>(name);
    map['place_type_id'] = Variable<String>(placeTypeId);
    if (!nullToAbsent || areaId != null) {
      map['area_id'] = Variable<String>(areaId);
    }
    if (!nullToAbsent || areaName != null) {
      map['area_name'] = Variable<String>(areaName);
    }
    map['price_range'] = Variable<String>(priceRange);
    map['description'] = Variable<String>(description);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || avgRating != null) {
      map['avg_rating'] = Variable<double>(avgRating);
    }
    if (!nullToAbsent || avgPricePp != null) {
      map['avg_price_pp'] = Variable<double>(avgPricePp);
    }
    map['visits_count'] = Variable<int>(visitsCount);
    if (!nullToAbsent || lastVisitAt != null) {
      map['last_visit_at'] = Variable<DateTime>(lastVisitAt);
    }
    {
      map['tags'] = Variable<String>(
        $PlacesCacheTable.$convertertags.toSql(tags),
      );
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlacesCacheCompanion toCompanion(bool nullToAbsent) {
    return PlacesCacheCompanion(
      id: Value(id),
      householdId: Value(householdId),
      name: Value(name),
      placeTypeId: Value(placeTypeId),
      areaId: areaId == null && nullToAbsent
          ? const Value.absent()
          : Value(areaId),
      areaName: areaName == null && nullToAbsent
          ? const Value.absent()
          : Value(areaName),
      priceRange: Value(priceRange),
      description: Value(description),
      url: Value(url),
      avgRating: avgRating == null && nullToAbsent
          ? const Value.absent()
          : Value(avgRating),
      avgPricePp: avgPricePp == null && nullToAbsent
          ? const Value.absent()
          : Value(avgPricePp),
      visitsCount: Value(visitsCount),
      lastVisitAt: lastVisitAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastVisitAt),
      tags: Value(tags),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CachedPlace.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedPlace(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      name: serializer.fromJson<String>(json['name']),
      placeTypeId: serializer.fromJson<String>(json['placeTypeId']),
      areaId: serializer.fromJson<String?>(json['areaId']),
      areaName: serializer.fromJson<String?>(json['areaName']),
      priceRange: serializer.fromJson<String>(json['priceRange']),
      description: serializer.fromJson<String>(json['description']),
      url: serializer.fromJson<String>(json['url']),
      avgRating: serializer.fromJson<double?>(json['avgRating']),
      avgPricePp: serializer.fromJson<double?>(json['avgPricePp']),
      visitsCount: serializer.fromJson<int>(json['visitsCount']),
      lastVisitAt: serializer.fromJson<DateTime?>(json['lastVisitAt']),
      tags: serializer.fromJson<List<String>>(json['tags']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'name': serializer.toJson<String>(name),
      'placeTypeId': serializer.toJson<String>(placeTypeId),
      'areaId': serializer.toJson<String?>(areaId),
      'areaName': serializer.toJson<String?>(areaName),
      'priceRange': serializer.toJson<String>(priceRange),
      'description': serializer.toJson<String>(description),
      'url': serializer.toJson<String>(url),
      'avgRating': serializer.toJson<double?>(avgRating),
      'avgPricePp': serializer.toJson<double?>(avgPricePp),
      'visitsCount': serializer.toJson<int>(visitsCount),
      'lastVisitAt': serializer.toJson<DateTime?>(lastVisitAt),
      'tags': serializer.toJson<List<String>>(tags),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CachedPlace copyWith({
    String? id,
    String? householdId,
    String? name,
    String? placeTypeId,
    Value<String?> areaId = const Value.absent(),
    Value<String?> areaName = const Value.absent(),
    String? priceRange,
    String? description,
    String? url,
    Value<double?> avgRating = const Value.absent(),
    Value<double?> avgPricePp = const Value.absent(),
    int? visitsCount,
    Value<DateTime?> lastVisitAt = const Value.absent(),
    List<String>? tags,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CachedPlace(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    name: name ?? this.name,
    placeTypeId: placeTypeId ?? this.placeTypeId,
    areaId: areaId.present ? areaId.value : this.areaId,
    areaName: areaName.present ? areaName.value : this.areaName,
    priceRange: priceRange ?? this.priceRange,
    description: description ?? this.description,
    url: url ?? this.url,
    avgRating: avgRating.present ? avgRating.value : this.avgRating,
    avgPricePp: avgPricePp.present ? avgPricePp.value : this.avgPricePp,
    visitsCount: visitsCount ?? this.visitsCount,
    lastVisitAt: lastVisitAt.present ? lastVisitAt.value : this.lastVisitAt,
    tags: tags ?? this.tags,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CachedPlace copyWithCompanion(PlacesCacheCompanion data) {
    return CachedPlace(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      name: data.name.present ? data.name.value : this.name,
      placeTypeId: data.placeTypeId.present
          ? data.placeTypeId.value
          : this.placeTypeId,
      areaId: data.areaId.present ? data.areaId.value : this.areaId,
      areaName: data.areaName.present ? data.areaName.value : this.areaName,
      priceRange: data.priceRange.present
          ? data.priceRange.value
          : this.priceRange,
      description: data.description.present
          ? data.description.value
          : this.description,
      url: data.url.present ? data.url.value : this.url,
      avgRating: data.avgRating.present ? data.avgRating.value : this.avgRating,
      avgPricePp: data.avgPricePp.present
          ? data.avgPricePp.value
          : this.avgPricePp,
      visitsCount: data.visitsCount.present
          ? data.visitsCount.value
          : this.visitsCount,
      lastVisitAt: data.lastVisitAt.present
          ? data.lastVisitAt.value
          : this.lastVisitAt,
      tags: data.tags.present ? data.tags.value : this.tags,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedPlace(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('name: $name, ')
          ..write('placeTypeId: $placeTypeId, ')
          ..write('areaId: $areaId, ')
          ..write('areaName: $areaName, ')
          ..write('priceRange: $priceRange, ')
          ..write('description: $description, ')
          ..write('url: $url, ')
          ..write('avgRating: $avgRating, ')
          ..write('avgPricePp: $avgPricePp, ')
          ..write('visitsCount: $visitsCount, ')
          ..write('lastVisitAt: $lastVisitAt, ')
          ..write('tags: $tags, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    householdId,
    name,
    placeTypeId,
    areaId,
    areaName,
    priceRange,
    description,
    url,
    avgRating,
    avgPricePp,
    visitsCount,
    lastVisitAt,
    tags,
    syncStatus,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedPlace &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.name == this.name &&
          other.placeTypeId == this.placeTypeId &&
          other.areaId == this.areaId &&
          other.areaName == this.areaName &&
          other.priceRange == this.priceRange &&
          other.description == this.description &&
          other.url == this.url &&
          other.avgRating == this.avgRating &&
          other.avgPricePp == this.avgPricePp &&
          other.visitsCount == this.visitsCount &&
          other.lastVisitAt == this.lastVisitAt &&
          other.tags == this.tags &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlacesCacheCompanion extends UpdateCompanion<CachedPlace> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<String> name;
  final Value<String> placeTypeId;
  final Value<String?> areaId;
  final Value<String?> areaName;
  final Value<String> priceRange;
  final Value<String> description;
  final Value<String> url;
  final Value<double?> avgRating;
  final Value<double?> avgPricePp;
  final Value<int> visitsCount;
  final Value<DateTime?> lastVisitAt;
  final Value<List<String>> tags;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PlacesCacheCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.name = const Value.absent(),
    this.placeTypeId = const Value.absent(),
    this.areaId = const Value.absent(),
    this.areaName = const Value.absent(),
    this.priceRange = const Value.absent(),
    this.description = const Value.absent(),
    this.url = const Value.absent(),
    this.avgRating = const Value.absent(),
    this.avgPricePp = const Value.absent(),
    this.visitsCount = const Value.absent(),
    this.lastVisitAt = const Value.absent(),
    this.tags = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlacesCacheCompanion.insert({
    required String id,
    required String householdId,
    required String name,
    required String placeTypeId,
    this.areaId = const Value.absent(),
    this.areaName = const Value.absent(),
    required String priceRange,
    this.description = const Value.absent(),
    this.url = const Value.absent(),
    this.avgRating = const Value.absent(),
    this.avgPricePp = const Value.absent(),
    required int visitsCount,
    this.lastVisitAt = const Value.absent(),
    required List<String> tags,
    this.syncStatus = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       name = Value(name),
       placeTypeId = Value(placeTypeId),
       priceRange = Value(priceRange),
       visitsCount = Value(visitsCount),
       tags = Value(tags),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CachedPlace> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<String>? name,
    Expression<String>? placeTypeId,
    Expression<String>? areaId,
    Expression<String>? areaName,
    Expression<String>? priceRange,
    Expression<String>? description,
    Expression<String>? url,
    Expression<double>? avgRating,
    Expression<double>? avgPricePp,
    Expression<int>? visitsCount,
    Expression<DateTime>? lastVisitAt,
    Expression<String>? tags,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (name != null) 'name': name,
      if (placeTypeId != null) 'place_type_id': placeTypeId,
      if (areaId != null) 'area_id': areaId,
      if (areaName != null) 'area_name': areaName,
      if (priceRange != null) 'price_range': priceRange,
      if (description != null) 'description': description,
      if (url != null) 'url': url,
      if (avgRating != null) 'avg_rating': avgRating,
      if (avgPricePp != null) 'avg_price_pp': avgPricePp,
      if (visitsCount != null) 'visits_count': visitsCount,
      if (lastVisitAt != null) 'last_visit_at': lastVisitAt,
      if (tags != null) 'tags': tags,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlacesCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<String>? name,
    Value<String>? placeTypeId,
    Value<String?>? areaId,
    Value<String?>? areaName,
    Value<String>? priceRange,
    Value<String>? description,
    Value<String>? url,
    Value<double?>? avgRating,
    Value<double?>? avgPricePp,
    Value<int>? visitsCount,
    Value<DateTime?>? lastVisitAt,
    Value<List<String>>? tags,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PlacesCacheCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      placeTypeId: placeTypeId ?? this.placeTypeId,
      areaId: areaId ?? this.areaId,
      areaName: areaName ?? this.areaName,
      priceRange: priceRange ?? this.priceRange,
      description: description ?? this.description,
      url: url ?? this.url,
      avgRating: avgRating ?? this.avgRating,
      avgPricePp: avgPricePp ?? this.avgPricePp,
      visitsCount: visitsCount ?? this.visitsCount,
      lastVisitAt: lastVisitAt ?? this.lastVisitAt,
      tags: tags ?? this.tags,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (placeTypeId.present) {
      map['place_type_id'] = Variable<String>(placeTypeId.value);
    }
    if (areaId.present) {
      map['area_id'] = Variable<String>(areaId.value);
    }
    if (areaName.present) {
      map['area_name'] = Variable<String>(areaName.value);
    }
    if (priceRange.present) {
      map['price_range'] = Variable<String>(priceRange.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (avgRating.present) {
      map['avg_rating'] = Variable<double>(avgRating.value);
    }
    if (avgPricePp.present) {
      map['avg_price_pp'] = Variable<double>(avgPricePp.value);
    }
    if (visitsCount.present) {
      map['visits_count'] = Variable<int>(visitsCount.value);
    }
    if (lastVisitAt.present) {
      map['last_visit_at'] = Variable<DateTime>(lastVisitAt.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(
        $PlacesCacheTable.$convertertags.toSql(tags.value),
      );
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlacesCacheCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('name: $name, ')
          ..write('placeTypeId: $placeTypeId, ')
          ..write('areaId: $areaId, ')
          ..write('areaName: $areaName, ')
          ..write('priceRange: $priceRange, ')
          ..write('description: $description, ')
          ..write('url: $url, ')
          ..write('avgRating: $avgRating, ')
          ..write('avgPricePp: $avgPricePp, ')
          ..write('visitsCount: $visitsCount, ')
          ..write('lastVisitAt: $lastVisitAt, ')
          ..write('tags: $tags, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AreasCacheTable extends AreasCache
    with TableInfo<$AreasCacheTable, CachedArea> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AreasCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'areas_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedArea> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedArea map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedArea(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $AreasCacheTable createAlias(String alias) {
    return $AreasCacheTable(attachedDatabase, alias);
  }
}

class CachedArea extends DataClass implements Insertable<CachedArea> {
  final String id;
  final String name;
  const CachedArea({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  AreasCacheCompanion toCompanion(bool nullToAbsent) {
    return AreasCacheCompanion(id: Value(id), name: Value(name));
  }

  factory CachedArea.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedArea(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  CachedArea copyWith({String? id, String? name}) =>
      CachedArea(id: id ?? this.id, name: name ?? this.name);
  CachedArea copyWithCompanion(AreasCacheCompanion data) {
    return CachedArea(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedArea(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedArea && other.id == this.id && other.name == this.name);
}

class AreasCacheCompanion extends UpdateCompanion<CachedArea> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const AreasCacheCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AreasCacheCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<CachedArea> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AreasCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return AreasCacheCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AreasCacheCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsCacheTable extends TagsCache
    with TableInfo<$TagsCacheTable, CachedTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedTag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $TagsCacheTable createAlias(String alias) {
    return $TagsCacheTable(attachedDatabase, alias);
  }
}

class CachedTag extends DataClass implements Insertable<CachedTag> {
  final String id;
  final String name;
  const CachedTag({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  TagsCacheCompanion toCompanion(bool nullToAbsent) {
    return TagsCacheCompanion(id: Value(id), name: Value(name));
  }

  factory CachedTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedTag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  CachedTag copyWith({String? id, String? name}) =>
      CachedTag(id: id ?? this.id, name: name ?? this.name);
  CachedTag copyWithCompanion(TagsCacheCompanion data) {
    return CachedTag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedTag(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedTag && other.id == this.id && other.name == this.name);
}

class TagsCacheCompanion extends UpdateCompanion<CachedTag> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const TagsCacheCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCacheCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<CachedTag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return TagsCacheCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCacheCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitsCacheTable extends VisitsCache
    with TableInfo<$VisitsCacheTable, CachedVisit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeIdMeta = const VerificationMeta(
    'placeId',
  );
  @override
  late final GeneratedColumn<String> placeId = GeneratedColumn<String>(
    'place_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pricePpMeta = const VerificationMeta(
    'pricePp',
  );
  @override
  late final GeneratedColumn<double> pricePp = GeneratedColumn<double>(
    'price_pp',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    placeId,
    authorId,
    date,
    rating,
    pricePp,
    comment,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visits_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedVisit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('place_id')) {
      context.handle(
        _placeIdMeta,
        placeId.isAcceptableOrUnknown(data['place_id']!, _placeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_placeIdMeta);
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('price_pp')) {
      context.handle(
        _pricePpMeta,
        pricePp.isAcceptableOrUnknown(data['price_pp']!, _pricePpMeta),
      );
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedVisit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedVisit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      placeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_id'],
      )!,
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      ),
      pricePp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_pp'],
      ),
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VisitsCacheTable createAlias(String alias) {
    return $VisitsCacheTable(attachedDatabase, alias);
  }
}

class CachedVisit extends DataClass implements Insertable<CachedVisit> {
  final String id;
  final String placeId;
  final String authorId;
  final DateTime date;
  final double? rating;
  final double? pricePp;
  final String comment;
  final String syncStatus;
  final DateTime createdAt;
  const CachedVisit({
    required this.id,
    required this.placeId,
    required this.authorId,
    required this.date,
    this.rating,
    this.pricePp,
    required this.comment,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['place_id'] = Variable<String>(placeId);
    map['author_id'] = Variable<String>(authorId);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    if (!nullToAbsent || pricePp != null) {
      map['price_pp'] = Variable<double>(pricePp);
    }
    map['comment'] = Variable<String>(comment);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VisitsCacheCompanion toCompanion(bool nullToAbsent) {
    return VisitsCacheCompanion(
      id: Value(id),
      placeId: Value(placeId),
      authorId: Value(authorId),
      date: Value(date),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      pricePp: pricePp == null && nullToAbsent
          ? const Value.absent()
          : Value(pricePp),
      comment: Value(comment),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory CachedVisit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedVisit(
      id: serializer.fromJson<String>(json['id']),
      placeId: serializer.fromJson<String>(json['placeId']),
      authorId: serializer.fromJson<String>(json['authorId']),
      date: serializer.fromJson<DateTime>(json['date']),
      rating: serializer.fromJson<double?>(json['rating']),
      pricePp: serializer.fromJson<double?>(json['pricePp']),
      comment: serializer.fromJson<String>(json['comment']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'placeId': serializer.toJson<String>(placeId),
      'authorId': serializer.toJson<String>(authorId),
      'date': serializer.toJson<DateTime>(date),
      'rating': serializer.toJson<double?>(rating),
      'pricePp': serializer.toJson<double?>(pricePp),
      'comment': serializer.toJson<String>(comment),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CachedVisit copyWith({
    String? id,
    String? placeId,
    String? authorId,
    DateTime? date,
    Value<double?> rating = const Value.absent(),
    Value<double?> pricePp = const Value.absent(),
    String? comment,
    String? syncStatus,
    DateTime? createdAt,
  }) => CachedVisit(
    id: id ?? this.id,
    placeId: placeId ?? this.placeId,
    authorId: authorId ?? this.authorId,
    date: date ?? this.date,
    rating: rating.present ? rating.value : this.rating,
    pricePp: pricePp.present ? pricePp.value : this.pricePp,
    comment: comment ?? this.comment,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  CachedVisit copyWithCompanion(VisitsCacheCompanion data) {
    return CachedVisit(
      id: data.id.present ? data.id.value : this.id,
      placeId: data.placeId.present ? data.placeId.value : this.placeId,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      date: data.date.present ? data.date.value : this.date,
      rating: data.rating.present ? data.rating.value : this.rating,
      pricePp: data.pricePp.present ? data.pricePp.value : this.pricePp,
      comment: data.comment.present ? data.comment.value : this.comment,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedVisit(')
          ..write('id: $id, ')
          ..write('placeId: $placeId, ')
          ..write('authorId: $authorId, ')
          ..write('date: $date, ')
          ..write('rating: $rating, ')
          ..write('pricePp: $pricePp, ')
          ..write('comment: $comment, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    placeId,
    authorId,
    date,
    rating,
    pricePp,
    comment,
    syncStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedVisit &&
          other.id == this.id &&
          other.placeId == this.placeId &&
          other.authorId == this.authorId &&
          other.date == this.date &&
          other.rating == this.rating &&
          other.pricePp == this.pricePp &&
          other.comment == this.comment &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class VisitsCacheCompanion extends UpdateCompanion<CachedVisit> {
  final Value<String> id;
  final Value<String> placeId;
  final Value<String> authorId;
  final Value<DateTime> date;
  final Value<double?> rating;
  final Value<double?> pricePp;
  final Value<String> comment;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VisitsCacheCompanion({
    this.id = const Value.absent(),
    this.placeId = const Value.absent(),
    this.authorId = const Value.absent(),
    this.date = const Value.absent(),
    this.rating = const Value.absent(),
    this.pricePp = const Value.absent(),
    this.comment = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitsCacheCompanion.insert({
    required String id,
    required String placeId,
    required String authorId,
    required DateTime date,
    this.rating = const Value.absent(),
    this.pricePp = const Value.absent(),
    this.comment = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       placeId = Value(placeId),
       authorId = Value(authorId),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<CachedVisit> custom({
    Expression<String>? id,
    Expression<String>? placeId,
    Expression<String>? authorId,
    Expression<DateTime>? date,
    Expression<double>? rating,
    Expression<double>? pricePp,
    Expression<String>? comment,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (placeId != null) 'place_id': placeId,
      if (authorId != null) 'author_id': authorId,
      if (date != null) 'date': date,
      if (rating != null) 'rating': rating,
      if (pricePp != null) 'price_pp': pricePp,
      if (comment != null) 'comment': comment,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitsCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? placeId,
    Value<String>? authorId,
    Value<DateTime>? date,
    Value<double?>? rating,
    Value<double?>? pricePp,
    Value<String>? comment,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return VisitsCacheCompanion(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      authorId: authorId ?? this.authorId,
      date: date ?? this.date,
      rating: rating ?? this.rating,
      pricePp: pricePp ?? this.pricePp,
      comment: comment ?? this.comment,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (placeId.present) {
      map['place_id'] = Variable<String>(placeId.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (pricePp.present) {
      map['price_pp'] = Variable<double>(pricePp.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitsCacheCompanion(')
          ..write('id: $id, ')
          ..write('placeId: $placeId, ')
          ..write('authorId: $authorId, ')
          ..write('date: $date, ')
          ..write('rating: $rating, ')
          ..write('pricePp: $pricePp, ')
          ..write('comment: $comment, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoodVisitsCacheTable extends FoodVisitsCache
    with TableInfo<$FoodVisitsCacheTable, CachedFoodVisit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodVisitsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitIdMeta = const VerificationMeta(
    'visitId',
  );
  @override
  late final GeneratedColumn<String> visitId = GeneratedColumn<String>(
    'visit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<String> foodId = GeneratedColumn<String>(
    'food_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeNameMeta = const VerificationMeta(
    'placeName',
  );
  @override
  late final GeneratedColumn<String> placeName = GeneratedColumn<String>(
    'place_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pricePpMeta = const VerificationMeta(
    'pricePp',
  );
  @override
  late final GeneratedColumn<double> pricePp = GeneratedColumn<double>(
    'price_pp',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    visitId,
    foodId,
    placeName,
    date,
    rating,
    pricePp,
    comment,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_visits_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedFoodVisit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('visit_id')) {
      context.handle(
        _visitIdMeta,
        visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_visitIdMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('place_name')) {
      context.handle(
        _placeNameMeta,
        placeName.isAcceptableOrUnknown(data['place_name']!, _placeNameMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('price_pp')) {
      context.handle(
        _pricePpMeta,
        pricePp.isAcceptableOrUnknown(data['price_pp']!, _pricePpMeta),
      );
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedFoodVisit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedFoodVisit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      visitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_id'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_id'],
      )!,
      placeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_name'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      ),
      pricePp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_pp'],
      ),
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FoodVisitsCacheTable createAlias(String alias) {
    return $FoodVisitsCacheTable(attachedDatabase, alias);
  }
}

class CachedFoodVisit extends DataClass implements Insertable<CachedFoodVisit> {
  final String id;
  final String visitId;
  final String foodId;
  final String? placeName;
  final DateTime date;
  final double? rating;
  final double? pricePp;
  final String comment;
  final String syncStatus;
  final DateTime createdAt;
  const CachedFoodVisit({
    required this.id,
    required this.visitId,
    required this.foodId,
    this.placeName,
    required this.date,
    this.rating,
    this.pricePp,
    required this.comment,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['visit_id'] = Variable<String>(visitId);
    map['food_id'] = Variable<String>(foodId);
    if (!nullToAbsent || placeName != null) {
      map['place_name'] = Variable<String>(placeName);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    if (!nullToAbsent || pricePp != null) {
      map['price_pp'] = Variable<double>(pricePp);
    }
    map['comment'] = Variable<String>(comment);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FoodVisitsCacheCompanion toCompanion(bool nullToAbsent) {
    return FoodVisitsCacheCompanion(
      id: Value(id),
      visitId: Value(visitId),
      foodId: Value(foodId),
      placeName: placeName == null && nullToAbsent
          ? const Value.absent()
          : Value(placeName),
      date: Value(date),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      pricePp: pricePp == null && nullToAbsent
          ? const Value.absent()
          : Value(pricePp),
      comment: Value(comment),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory CachedFoodVisit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedFoodVisit(
      id: serializer.fromJson<String>(json['id']),
      visitId: serializer.fromJson<String>(json['visitId']),
      foodId: serializer.fromJson<String>(json['foodId']),
      placeName: serializer.fromJson<String?>(json['placeName']),
      date: serializer.fromJson<DateTime>(json['date']),
      rating: serializer.fromJson<double?>(json['rating']),
      pricePp: serializer.fromJson<double?>(json['pricePp']),
      comment: serializer.fromJson<String>(json['comment']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'visitId': serializer.toJson<String>(visitId),
      'foodId': serializer.toJson<String>(foodId),
      'placeName': serializer.toJson<String?>(placeName),
      'date': serializer.toJson<DateTime>(date),
      'rating': serializer.toJson<double?>(rating),
      'pricePp': serializer.toJson<double?>(pricePp),
      'comment': serializer.toJson<String>(comment),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CachedFoodVisit copyWith({
    String? id,
    String? visitId,
    String? foodId,
    Value<String?> placeName = const Value.absent(),
    DateTime? date,
    Value<double?> rating = const Value.absent(),
    Value<double?> pricePp = const Value.absent(),
    String? comment,
    String? syncStatus,
    DateTime? createdAt,
  }) => CachedFoodVisit(
    id: id ?? this.id,
    visitId: visitId ?? this.visitId,
    foodId: foodId ?? this.foodId,
    placeName: placeName.present ? placeName.value : this.placeName,
    date: date ?? this.date,
    rating: rating.present ? rating.value : this.rating,
    pricePp: pricePp.present ? pricePp.value : this.pricePp,
    comment: comment ?? this.comment,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  CachedFoodVisit copyWithCompanion(FoodVisitsCacheCompanion data) {
    return CachedFoodVisit(
      id: data.id.present ? data.id.value : this.id,
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      placeName: data.placeName.present ? data.placeName.value : this.placeName,
      date: data.date.present ? data.date.value : this.date,
      rating: data.rating.present ? data.rating.value : this.rating,
      pricePp: data.pricePp.present ? data.pricePp.value : this.pricePp,
      comment: data.comment.present ? data.comment.value : this.comment,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedFoodVisit(')
          ..write('id: $id, ')
          ..write('visitId: $visitId, ')
          ..write('foodId: $foodId, ')
          ..write('placeName: $placeName, ')
          ..write('date: $date, ')
          ..write('rating: $rating, ')
          ..write('pricePp: $pricePp, ')
          ..write('comment: $comment, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    visitId,
    foodId,
    placeName,
    date,
    rating,
    pricePp,
    comment,
    syncStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedFoodVisit &&
          other.id == this.id &&
          other.visitId == this.visitId &&
          other.foodId == this.foodId &&
          other.placeName == this.placeName &&
          other.date == this.date &&
          other.rating == this.rating &&
          other.pricePp == this.pricePp &&
          other.comment == this.comment &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class FoodVisitsCacheCompanion extends UpdateCompanion<CachedFoodVisit> {
  final Value<String> id;
  final Value<String> visitId;
  final Value<String> foodId;
  final Value<String?> placeName;
  final Value<DateTime> date;
  final Value<double?> rating;
  final Value<double?> pricePp;
  final Value<String> comment;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FoodVisitsCacheCompanion({
    this.id = const Value.absent(),
    this.visitId = const Value.absent(),
    this.foodId = const Value.absent(),
    this.placeName = const Value.absent(),
    this.date = const Value.absent(),
    this.rating = const Value.absent(),
    this.pricePp = const Value.absent(),
    this.comment = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodVisitsCacheCompanion.insert({
    required String id,
    required String visitId,
    required String foodId,
    this.placeName = const Value.absent(),
    required DateTime date,
    this.rating = const Value.absent(),
    this.pricePp = const Value.absent(),
    this.comment = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       visitId = Value(visitId),
       foodId = Value(foodId),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<CachedFoodVisit> custom({
    Expression<String>? id,
    Expression<String>? visitId,
    Expression<String>? foodId,
    Expression<String>? placeName,
    Expression<DateTime>? date,
    Expression<double>? rating,
    Expression<double>? pricePp,
    Expression<String>? comment,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (visitId != null) 'visit_id': visitId,
      if (foodId != null) 'food_id': foodId,
      if (placeName != null) 'place_name': placeName,
      if (date != null) 'date': date,
      if (rating != null) 'rating': rating,
      if (pricePp != null) 'price_pp': pricePp,
      if (comment != null) 'comment': comment,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodVisitsCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? visitId,
    Value<String>? foodId,
    Value<String?>? placeName,
    Value<DateTime>? date,
    Value<double?>? rating,
    Value<double?>? pricePp,
    Value<String>? comment,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FoodVisitsCacheCompanion(
      id: id ?? this.id,
      visitId: visitId ?? this.visitId,
      foodId: foodId ?? this.foodId,
      placeName: placeName ?? this.placeName,
      date: date ?? this.date,
      rating: rating ?? this.rating,
      pricePp: pricePp ?? this.pricePp,
      comment: comment ?? this.comment,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<String>(foodId.value);
    }
    if (placeName.present) {
      map['place_name'] = Variable<String>(placeName.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (pricePp.present) {
      map['price_pp'] = Variable<double>(pricePp.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodVisitsCacheCompanion(')
          ..write('id: $id, ')
          ..write('visitId: $visitId, ')
          ..write('foodId: $foodId, ')
          ..write('placeName: $placeName, ')
          ..write('date: $date, ')
          ..write('rating: $rating, ')
          ..write('pricePp: $pricePp, ')
          ..write('comment: $comment, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localEntityIdMeta = const VerificationMeta(
    'localEntityId',
  );
  @override
  late final GeneratedColumn<String> localEntityId = GeneratedColumn<String>(
    'local_entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retriesMeta = const VerificationMeta(
    'retries',
  );
  @override
  late final GeneratedColumn<int> retries = GeneratedColumn<int>(
    'retries',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    operation,
    localEntityId,
    payloadJson,
    createdAt,
    retries,
    lastError,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('local_entity_id')) {
      context.handle(
        _localEntityIdMeta,
        localEntityId.isAcceptableOrUnknown(
          data['local_entity_id']!,
          _localEntityIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localEntityIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retries')) {
      context.handle(
        _retriesMeta,
        retries.isAcceptableOrUnknown(data['retries']!, _retriesMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      localEntityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_entity_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      retries: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retries'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueEntry extends DataClass implements Insertable<SyncQueueEntry> {
  final int id;
  final String entityType;
  final String operation;
  final String localEntityId;
  final String payloadJson;
  final DateTime createdAt;
  final int retries;
  final String? lastError;
  final String status;
  const SyncQueueEntry({
    required this.id,
    required this.entityType,
    required this.operation,
    required this.localEntityId,
    required this.payloadJson,
    required this.createdAt,
    required this.retries,
    this.lastError,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['operation'] = Variable<String>(operation);
    map['local_entity_id'] = Variable<String>(localEntityId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retries'] = Variable<int>(retries);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      operation: Value(operation),
      localEntityId: Value(localEntityId),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      retries: Value(retries),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      status: Value(status),
    );
  }

  factory SyncQueueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueEntry(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      operation: serializer.fromJson<String>(json['operation']),
      localEntityId: serializer.fromJson<String>(json['localEntityId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retries: serializer.fromJson<int>(json['retries']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'operation': serializer.toJson<String>(operation),
      'localEntityId': serializer.toJson<String>(localEntityId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retries': serializer.toJson<int>(retries),
      'lastError': serializer.toJson<String?>(lastError),
      'status': serializer.toJson<String>(status),
    };
  }

  SyncQueueEntry copyWith({
    int? id,
    String? entityType,
    String? operation,
    String? localEntityId,
    String? payloadJson,
    DateTime? createdAt,
    int? retries,
    Value<String?> lastError = const Value.absent(),
    String? status,
  }) => SyncQueueEntry(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    operation: operation ?? this.operation,
    localEntityId: localEntityId ?? this.localEntityId,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    retries: retries ?? this.retries,
    lastError: lastError.present ? lastError.value : this.lastError,
    status: status ?? this.status,
  );
  SyncQueueEntry copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueEntry(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      operation: data.operation.present ? data.operation.value : this.operation,
      localEntityId: data.localEntityId.present
          ? data.localEntityId.value
          : this.localEntityId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retries: data.retries.present ? data.retries.value : this.retries,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntry(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('operation: $operation, ')
          ..write('localEntityId: $localEntityId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retries: $retries, ')
          ..write('lastError: $lastError, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    operation,
    localEntityId,
    payloadJson,
    createdAt,
    retries,
    lastError,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueEntry &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.operation == this.operation &&
          other.localEntityId == this.localEntityId &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.retries == this.retries &&
          other.lastError == this.lastError &&
          other.status == this.status);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueEntry> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> operation;
  final Value<String> localEntityId;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> retries;
  final Value<String?> lastError;
  final Value<String> status;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.operation = const Value.absent(),
    this.localEntityId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retries = const Value.absent(),
    this.lastError = const Value.absent(),
    this.status = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String operation,
    required String localEntityId,
    required String payloadJson,
    required DateTime createdAt,
    this.retries = const Value.absent(),
    this.lastError = const Value.absent(),
    this.status = const Value.absent(),
  }) : entityType = Value(entityType),
       operation = Value(operation),
       localEntityId = Value(localEntityId),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueEntry> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? operation,
    Expression<String>? localEntityId,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? retries,
    Expression<String>? lastError,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (operation != null) 'operation': operation,
      if (localEntityId != null) 'local_entity_id': localEntityId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (retries != null) 'retries': retries,
      if (lastError != null) 'last_error': lastError,
      if (status != null) 'status': status,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<String>? operation,
    Value<String>? localEntityId,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<int>? retries,
    Value<String?>? lastError,
    Value<String>? status,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      operation: operation ?? this.operation,
      localEntityId: localEntityId ?? this.localEntityId,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      retries: retries ?? this.retries,
      lastError: lastError ?? this.lastError,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (localEntityId.present) {
      map['local_entity_id'] = Variable<String>(localEntityId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retries.present) {
      map['retries'] = Variable<int>(retries.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('operation: $operation, ')
          ..write('localEntityId: $localEntityId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retries: $retries, ')
          ..write('lastError: $lastError, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FoodsCacheTable foodsCache = $FoodsCacheTable(this);
  late final $PlaceTypesCacheTable placeTypesCache = $PlaceTypesCacheTable(
    this,
  );
  late final $PlacesCacheTable placesCache = $PlacesCacheTable(this);
  late final $AreasCacheTable areasCache = $AreasCacheTable(this);
  late final $TagsCacheTable tagsCache = $TagsCacheTable(this);
  late final $VisitsCacheTable visitsCache = $VisitsCacheTable(this);
  late final $FoodVisitsCacheTable foodVisitsCache = $FoodVisitsCacheTable(
    this,
  );
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final FoodsDao foodsDao = FoodsDao(this as AppDatabase);
  late final PlaceTypesDao placeTypesDao = PlaceTypesDao(this as AppDatabase);
  late final PlacesDao placesDao = PlacesDao(this as AppDatabase);
  late final AreasDao areasDao = AreasDao(this as AppDatabase);
  late final TagsDao tagsDao = TagsDao(this as AppDatabase);
  late final VisitsDao visitsDao = VisitsDao(this as AppDatabase);
  late final FoodVisitsDao foodVisitsDao = FoodVisitsDao(this as AppDatabase);
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    foodsCache,
    placeTypesCache,
    placesCache,
    areasCache,
    tagsCache,
    visitsCache,
    foodVisitsCache,
    syncQueue,
  ];
}

typedef $$FoodsCacheTableCreateCompanionBuilder =
    FoodsCacheCompanion Function({
      required String id,
      required String householdId,
      required String name,
      required bool isActive,
      Value<String> syncStatus,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$FoodsCacheTableUpdateCompanionBuilder =
    FoodsCacheCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<String> name,
      Value<bool> isActive,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$FoodsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $FoodsCacheTable> {
  $$FoodsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodsCacheTable> {
  $$FoodsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodsCacheTable> {
  $$FoodsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FoodsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodsCacheTable,
          CachedFood,
          $$FoodsCacheTableFilterComposer,
          $$FoodsCacheTableOrderingComposer,
          $$FoodsCacheTableAnnotationComposer,
          $$FoodsCacheTableCreateCompanionBuilder,
          $$FoodsCacheTableUpdateCompanionBuilder,
          (
            CachedFood,
            BaseReferences<_$AppDatabase, $FoodsCacheTable, CachedFood>,
          ),
          CachedFood,
          PrefetchHooks Function()
        > {
  $$FoodsCacheTableTableManager(_$AppDatabase db, $FoodsCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodsCacheCompanion(
                id: id,
                householdId: householdId,
                name: name,
                isActive: isActive,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                required String name,
                required bool isActive,
                Value<String> syncStatus = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FoodsCacheCompanion.insert(
                id: id,
                householdId: householdId,
                name: name,
                isActive: isActive,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodsCacheTable,
      CachedFood,
      $$FoodsCacheTableFilterComposer,
      $$FoodsCacheTableOrderingComposer,
      $$FoodsCacheTableAnnotationComposer,
      $$FoodsCacheTableCreateCompanionBuilder,
      $$FoodsCacheTableUpdateCompanionBuilder,
      (CachedFood, BaseReferences<_$AppDatabase, $FoodsCacheTable, CachedFood>),
      CachedFood,
      PrefetchHooks Function()
    >;
typedef $$PlaceTypesCacheTableCreateCompanionBuilder =
    PlaceTypesCacheCompanion Function({
      required String id,
      required String name,
      Value<int> rowid,
    });
typedef $$PlaceTypesCacheTableUpdateCompanionBuilder =
    PlaceTypesCacheCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> rowid,
    });

class $$PlaceTypesCacheTableFilterComposer
    extends Composer<_$AppDatabase, $PlaceTypesCacheTable> {
  $$PlaceTypesCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaceTypesCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaceTypesCacheTable> {
  $$PlaceTypesCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaceTypesCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaceTypesCacheTable> {
  $$PlaceTypesCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$PlaceTypesCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaceTypesCacheTable,
          CachedPlaceType,
          $$PlaceTypesCacheTableFilterComposer,
          $$PlaceTypesCacheTableOrderingComposer,
          $$PlaceTypesCacheTableAnnotationComposer,
          $$PlaceTypesCacheTableCreateCompanionBuilder,
          $$PlaceTypesCacheTableUpdateCompanionBuilder,
          (
            CachedPlaceType,
            BaseReferences<
              _$AppDatabase,
              $PlaceTypesCacheTable,
              CachedPlaceType
            >,
          ),
          CachedPlaceType,
          PrefetchHooks Function()
        > {
  $$PlaceTypesCacheTableTableManager(
    _$AppDatabase db,
    $PlaceTypesCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaceTypesCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaceTypesCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaceTypesCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaceTypesCacheCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => PlaceTypesCacheCompanion.insert(
                id: id,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaceTypesCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaceTypesCacheTable,
      CachedPlaceType,
      $$PlaceTypesCacheTableFilterComposer,
      $$PlaceTypesCacheTableOrderingComposer,
      $$PlaceTypesCacheTableAnnotationComposer,
      $$PlaceTypesCacheTableCreateCompanionBuilder,
      $$PlaceTypesCacheTableUpdateCompanionBuilder,
      (
        CachedPlaceType,
        BaseReferences<_$AppDatabase, $PlaceTypesCacheTable, CachedPlaceType>,
      ),
      CachedPlaceType,
      PrefetchHooks Function()
    >;
typedef $$PlacesCacheTableCreateCompanionBuilder =
    PlacesCacheCompanion Function({
      required String id,
      required String householdId,
      required String name,
      required String placeTypeId,
      Value<String?> areaId,
      Value<String?> areaName,
      required String priceRange,
      Value<String> description,
      Value<String> url,
      Value<double?> avgRating,
      Value<double?> avgPricePp,
      required int visitsCount,
      Value<DateTime?> lastVisitAt,
      required List<String> tags,
      Value<String> syncStatus,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PlacesCacheTableUpdateCompanionBuilder =
    PlacesCacheCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<String> name,
      Value<String> placeTypeId,
      Value<String?> areaId,
      Value<String?> areaName,
      Value<String> priceRange,
      Value<String> description,
      Value<String> url,
      Value<double?> avgRating,
      Value<double?> avgPricePp,
      Value<int> visitsCount,
      Value<DateTime?> lastVisitAt,
      Value<List<String>> tags,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PlacesCacheTableFilterComposer
    extends Composer<_$AppDatabase, $PlacesCacheTable> {
  $$PlacesCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeTypeId => $composableBuilder(
    column: $table.placeTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaName => $composableBuilder(
    column: $table.areaName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priceRange => $composableBuilder(
    column: $table.priceRange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgRating => $composableBuilder(
    column: $table.avgRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgPricePp => $composableBuilder(
    column: $table.avgPricePp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get visitsCount => $composableBuilder(
    column: $table.visitsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastVisitAt => $composableBuilder(
    column: $table.lastVisitAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
        column: $table.tags,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlacesCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $PlacesCacheTable> {
  $$PlacesCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeTypeId => $composableBuilder(
    column: $table.placeTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaName => $composableBuilder(
    column: $table.areaName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priceRange => $composableBuilder(
    column: $table.priceRange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgRating => $composableBuilder(
    column: $table.avgRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgPricePp => $composableBuilder(
    column: $table.avgPricePp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get visitsCount => $composableBuilder(
    column: $table.visitsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastVisitAt => $composableBuilder(
    column: $table.lastVisitAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlacesCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlacesCacheTable> {
  $$PlacesCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get placeTypeId => $composableBuilder(
    column: $table.placeTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get areaId =>
      $composableBuilder(column: $table.areaId, builder: (column) => column);

  GeneratedColumn<String> get areaName =>
      $composableBuilder(column: $table.areaName, builder: (column) => column);

  GeneratedColumn<String> get priceRange => $composableBuilder(
    column: $table.priceRange,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<double> get avgRating =>
      $composableBuilder(column: $table.avgRating, builder: (column) => column);

  GeneratedColumn<double> get avgPricePp => $composableBuilder(
    column: $table.avgPricePp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get visitsCount => $composableBuilder(
    column: $table.visitsCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastVisitAt => $composableBuilder(
    column: $table.lastVisitAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlacesCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlacesCacheTable,
          CachedPlace,
          $$PlacesCacheTableFilterComposer,
          $$PlacesCacheTableOrderingComposer,
          $$PlacesCacheTableAnnotationComposer,
          $$PlacesCacheTableCreateCompanionBuilder,
          $$PlacesCacheTableUpdateCompanionBuilder,
          (
            CachedPlace,
            BaseReferences<_$AppDatabase, $PlacesCacheTable, CachedPlace>,
          ),
          CachedPlace,
          PrefetchHooks Function()
        > {
  $$PlacesCacheTableTableManager(_$AppDatabase db, $PlacesCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlacesCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlacesCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlacesCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> placeTypeId = const Value.absent(),
                Value<String?> areaId = const Value.absent(),
                Value<String?> areaName = const Value.absent(),
                Value<String> priceRange = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<double?> avgRating = const Value.absent(),
                Value<double?> avgPricePp = const Value.absent(),
                Value<int> visitsCount = const Value.absent(),
                Value<DateTime?> lastVisitAt = const Value.absent(),
                Value<List<String>> tags = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlacesCacheCompanion(
                id: id,
                householdId: householdId,
                name: name,
                placeTypeId: placeTypeId,
                areaId: areaId,
                areaName: areaName,
                priceRange: priceRange,
                description: description,
                url: url,
                avgRating: avgRating,
                avgPricePp: avgPricePp,
                visitsCount: visitsCount,
                lastVisitAt: lastVisitAt,
                tags: tags,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                required String name,
                required String placeTypeId,
                Value<String?> areaId = const Value.absent(),
                Value<String?> areaName = const Value.absent(),
                required String priceRange,
                Value<String> description = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<double?> avgRating = const Value.absent(),
                Value<double?> avgPricePp = const Value.absent(),
                required int visitsCount,
                Value<DateTime?> lastVisitAt = const Value.absent(),
                required List<String> tags,
                Value<String> syncStatus = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PlacesCacheCompanion.insert(
                id: id,
                householdId: householdId,
                name: name,
                placeTypeId: placeTypeId,
                areaId: areaId,
                areaName: areaName,
                priceRange: priceRange,
                description: description,
                url: url,
                avgRating: avgRating,
                avgPricePp: avgPricePp,
                visitsCount: visitsCount,
                lastVisitAt: lastVisitAt,
                tags: tags,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlacesCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlacesCacheTable,
      CachedPlace,
      $$PlacesCacheTableFilterComposer,
      $$PlacesCacheTableOrderingComposer,
      $$PlacesCacheTableAnnotationComposer,
      $$PlacesCacheTableCreateCompanionBuilder,
      $$PlacesCacheTableUpdateCompanionBuilder,
      (
        CachedPlace,
        BaseReferences<_$AppDatabase, $PlacesCacheTable, CachedPlace>,
      ),
      CachedPlace,
      PrefetchHooks Function()
    >;
typedef $$AreasCacheTableCreateCompanionBuilder =
    AreasCacheCompanion Function({
      required String id,
      required String name,
      Value<int> rowid,
    });
typedef $$AreasCacheTableUpdateCompanionBuilder =
    AreasCacheCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> rowid,
    });

class $$AreasCacheTableFilterComposer
    extends Composer<_$AppDatabase, $AreasCacheTable> {
  $$AreasCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AreasCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $AreasCacheTable> {
  $$AreasCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AreasCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $AreasCacheTable> {
  $$AreasCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$AreasCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AreasCacheTable,
          CachedArea,
          $$AreasCacheTableFilterComposer,
          $$AreasCacheTableOrderingComposer,
          $$AreasCacheTableAnnotationComposer,
          $$AreasCacheTableCreateCompanionBuilder,
          $$AreasCacheTableUpdateCompanionBuilder,
          (
            CachedArea,
            BaseReferences<_$AppDatabase, $AreasCacheTable, CachedArea>,
          ),
          CachedArea,
          PrefetchHooks Function()
        > {
  $$AreasCacheTableTableManager(_$AppDatabase db, $AreasCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AreasCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AreasCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AreasCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AreasCacheCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) =>
                  AreasCacheCompanion.insert(id: id, name: name, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AreasCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AreasCacheTable,
      CachedArea,
      $$AreasCacheTableFilterComposer,
      $$AreasCacheTableOrderingComposer,
      $$AreasCacheTableAnnotationComposer,
      $$AreasCacheTableCreateCompanionBuilder,
      $$AreasCacheTableUpdateCompanionBuilder,
      (CachedArea, BaseReferences<_$AppDatabase, $AreasCacheTable, CachedArea>),
      CachedArea,
      PrefetchHooks Function()
    >;
typedef $$TagsCacheTableCreateCompanionBuilder =
    TagsCacheCompanion Function({
      required String id,
      required String name,
      Value<int> rowid,
    });
typedef $$TagsCacheTableUpdateCompanionBuilder =
    TagsCacheCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> rowid,
    });

class $$TagsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $TagsCacheTable> {
  $$TagsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TagsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $TagsCacheTable> {
  $$TagsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsCacheTable> {
  $$TagsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$TagsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsCacheTable,
          CachedTag,
          $$TagsCacheTableFilterComposer,
          $$TagsCacheTableOrderingComposer,
          $$TagsCacheTableAnnotationComposer,
          $$TagsCacheTableCreateCompanionBuilder,
          $$TagsCacheTableUpdateCompanionBuilder,
          (
            CachedTag,
            BaseReferences<_$AppDatabase, $TagsCacheTable, CachedTag>,
          ),
          CachedTag,
          PrefetchHooks Function()
        > {
  $$TagsCacheTableTableManager(_$AppDatabase db, $TagsCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCacheCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => TagsCacheCompanion.insert(id: id, name: name, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TagsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsCacheTable,
      CachedTag,
      $$TagsCacheTableFilterComposer,
      $$TagsCacheTableOrderingComposer,
      $$TagsCacheTableAnnotationComposer,
      $$TagsCacheTableCreateCompanionBuilder,
      $$TagsCacheTableUpdateCompanionBuilder,
      (CachedTag, BaseReferences<_$AppDatabase, $TagsCacheTable, CachedTag>),
      CachedTag,
      PrefetchHooks Function()
    >;
typedef $$VisitsCacheTableCreateCompanionBuilder =
    VisitsCacheCompanion Function({
      required String id,
      required String placeId,
      required String authorId,
      required DateTime date,
      Value<double?> rating,
      Value<double?> pricePp,
      Value<String> comment,
      Value<String> syncStatus,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$VisitsCacheTableUpdateCompanionBuilder =
    VisitsCacheCompanion Function({
      Value<String> id,
      Value<String> placeId,
      Value<String> authorId,
      Value<DateTime> date,
      Value<double?> rating,
      Value<double?> pricePp,
      Value<String> comment,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$VisitsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $VisitsCacheTable> {
  $$VisitsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeId => $composableBuilder(
    column: $table.placeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pricePp => $composableBuilder(
    column: $table.pricePp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $VisitsCacheTable> {
  $$VisitsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeId => $composableBuilder(
    column: $table.placeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pricePp => $composableBuilder(
    column: $table.pricePp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $VisitsCacheTable> {
  $$VisitsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get placeId =>
      $composableBuilder(column: $table.placeId, builder: (column) => column);

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<double> get pricePp =>
      $composableBuilder(column: $table.pricePp, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VisitsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VisitsCacheTable,
          CachedVisit,
          $$VisitsCacheTableFilterComposer,
          $$VisitsCacheTableOrderingComposer,
          $$VisitsCacheTableAnnotationComposer,
          $$VisitsCacheTableCreateCompanionBuilder,
          $$VisitsCacheTableUpdateCompanionBuilder,
          (
            CachedVisit,
            BaseReferences<_$AppDatabase, $VisitsCacheTable, CachedVisit>,
          ),
          CachedVisit,
          PrefetchHooks Function()
        > {
  $$VisitsCacheTableTableManager(_$AppDatabase db, $VisitsCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> placeId = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<double?> pricePp = const Value.absent(),
                Value<String> comment = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitsCacheCompanion(
                id: id,
                placeId: placeId,
                authorId: authorId,
                date: date,
                rating: rating,
                pricePp: pricePp,
                comment: comment,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String placeId,
                required String authorId,
                required DateTime date,
                Value<double?> rating = const Value.absent(),
                Value<double?> pricePp = const Value.absent(),
                Value<String> comment = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => VisitsCacheCompanion.insert(
                id: id,
                placeId: placeId,
                authorId: authorId,
                date: date,
                rating: rating,
                pricePp: pricePp,
                comment: comment,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VisitsCacheTable,
      CachedVisit,
      $$VisitsCacheTableFilterComposer,
      $$VisitsCacheTableOrderingComposer,
      $$VisitsCacheTableAnnotationComposer,
      $$VisitsCacheTableCreateCompanionBuilder,
      $$VisitsCacheTableUpdateCompanionBuilder,
      (
        CachedVisit,
        BaseReferences<_$AppDatabase, $VisitsCacheTable, CachedVisit>,
      ),
      CachedVisit,
      PrefetchHooks Function()
    >;
typedef $$FoodVisitsCacheTableCreateCompanionBuilder =
    FoodVisitsCacheCompanion Function({
      required String id,
      required String visitId,
      required String foodId,
      Value<String?> placeName,
      required DateTime date,
      Value<double?> rating,
      Value<double?> pricePp,
      Value<String> comment,
      Value<String> syncStatus,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$FoodVisitsCacheTableUpdateCompanionBuilder =
    FoodVisitsCacheCompanion Function({
      Value<String> id,
      Value<String> visitId,
      Value<String> foodId,
      Value<String?> placeName,
      Value<DateTime> date,
      Value<double?> rating,
      Value<double?> pricePp,
      Value<String> comment,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$FoodVisitsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $FoodVisitsCacheTable> {
  $$FoodVisitsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visitId => $composableBuilder(
    column: $table.visitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeName => $composableBuilder(
    column: $table.placeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pricePp => $composableBuilder(
    column: $table.pricePp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodVisitsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodVisitsCacheTable> {
  $$FoodVisitsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visitId => $composableBuilder(
    column: $table.visitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeName => $composableBuilder(
    column: $table.placeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pricePp => $composableBuilder(
    column: $table.pricePp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodVisitsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodVisitsCacheTable> {
  $$FoodVisitsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get visitId =>
      $composableBuilder(column: $table.visitId, builder: (column) => column);

  GeneratedColumn<String> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<String> get placeName =>
      $composableBuilder(column: $table.placeName, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<double> get pricePp =>
      $composableBuilder(column: $table.pricePp, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FoodVisitsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodVisitsCacheTable,
          CachedFoodVisit,
          $$FoodVisitsCacheTableFilterComposer,
          $$FoodVisitsCacheTableOrderingComposer,
          $$FoodVisitsCacheTableAnnotationComposer,
          $$FoodVisitsCacheTableCreateCompanionBuilder,
          $$FoodVisitsCacheTableUpdateCompanionBuilder,
          (
            CachedFoodVisit,
            BaseReferences<
              _$AppDatabase,
              $FoodVisitsCacheTable,
              CachedFoodVisit
            >,
          ),
          CachedFoodVisit,
          PrefetchHooks Function()
        > {
  $$FoodVisitsCacheTableTableManager(
    _$AppDatabase db,
    $FoodVisitsCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodVisitsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodVisitsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodVisitsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> visitId = const Value.absent(),
                Value<String> foodId = const Value.absent(),
                Value<String?> placeName = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<double?> pricePp = const Value.absent(),
                Value<String> comment = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodVisitsCacheCompanion(
                id: id,
                visitId: visitId,
                foodId: foodId,
                placeName: placeName,
                date: date,
                rating: rating,
                pricePp: pricePp,
                comment: comment,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String visitId,
                required String foodId,
                Value<String?> placeName = const Value.absent(),
                required DateTime date,
                Value<double?> rating = const Value.absent(),
                Value<double?> pricePp = const Value.absent(),
                Value<String> comment = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FoodVisitsCacheCompanion.insert(
                id: id,
                visitId: visitId,
                foodId: foodId,
                placeName: placeName,
                date: date,
                rating: rating,
                pricePp: pricePp,
                comment: comment,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodVisitsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodVisitsCacheTable,
      CachedFoodVisit,
      $$FoodVisitsCacheTableFilterComposer,
      $$FoodVisitsCacheTableOrderingComposer,
      $$FoodVisitsCacheTableAnnotationComposer,
      $$FoodVisitsCacheTableCreateCompanionBuilder,
      $$FoodVisitsCacheTableUpdateCompanionBuilder,
      (
        CachedFoodVisit,
        BaseReferences<_$AppDatabase, $FoodVisitsCacheTable, CachedFoodVisit>,
      ),
      CachedFoodVisit,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String entityType,
      required String operation,
      required String localEntityId,
      required String payloadJson,
      required DateTime createdAt,
      Value<int> retries,
      Value<String?> lastError,
      Value<String> status,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<String> operation,
      Value<String> localEntityId,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<int> retries,
      Value<String?> lastError,
      Value<String> status,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localEntityId => $composableBuilder(
    column: $table.localEntityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retries => $composableBuilder(
    column: $table.retries,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localEntityId => $composableBuilder(
    column: $table.localEntityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retries => $composableBuilder(
    column: $table.retries,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get localEntityId => $composableBuilder(
    column: $table.localEntityId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retries =>
      $composableBuilder(column: $table.retries, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueEntry,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueEntry,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueEntry>,
          ),
          SyncQueueEntry,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> localEntityId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retries = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                entityType: entityType,
                operation: operation,
                localEntityId: localEntityId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                retries: retries,
                lastError: lastError,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                required String operation,
                required String localEntityId,
                required String payloadJson,
                required DateTime createdAt,
                Value<int> retries = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                entityType: entityType,
                operation: operation,
                localEntityId: localEntityId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                retries: retries,
                lastError: lastError,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueEntry,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueEntry,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueEntry>,
      ),
      SyncQueueEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FoodsCacheTableTableManager get foodsCache =>
      $$FoodsCacheTableTableManager(_db, _db.foodsCache);
  $$PlaceTypesCacheTableTableManager get placeTypesCache =>
      $$PlaceTypesCacheTableTableManager(_db, _db.placeTypesCache);
  $$PlacesCacheTableTableManager get placesCache =>
      $$PlacesCacheTableTableManager(_db, _db.placesCache);
  $$AreasCacheTableTableManager get areasCache =>
      $$AreasCacheTableTableManager(_db, _db.areasCache);
  $$TagsCacheTableTableManager get tagsCache =>
      $$TagsCacheTableTableManager(_db, _db.tagsCache);
  $$VisitsCacheTableTableManager get visitsCache =>
      $$VisitsCacheTableTableManager(_db, _db.visitsCache);
  $$FoodVisitsCacheTableTableManager get foodVisitsCache =>
      $$FoodVisitsCacheTableTableManager(_db, _db.foodVisitsCache);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
