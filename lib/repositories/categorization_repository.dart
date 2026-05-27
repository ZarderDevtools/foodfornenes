import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';
import '../local/daos/areas_dao.dart';
import '../local/daos/place_types_dao.dart';
import '../local/daos/tags_dao.dart';
import '../models/area.dart';
import '../models/place_type.dart';
import '../models/tag.dart';
import '../services/api_client.dart';

class CategorizationRepository {
  final ApiClient api;
  final PlaceTypesDao? _dao;
  final AreasDao? _areasDao;
  final TagsDao? _tagsDao;

  CategorizationRepository(
    this.api, {
    PlaceTypesDao? dao,
    AreasDao? areasDao,
    TagsDao? tagsDao,
  })  : _dao = dao,
        _areasDao = areasDao,
        _tagsDao = tagsDao;

  // ── PlaceType ─────────────────────────────────────────────────────────────

  Future<List<PlaceType>?> getCachedPlaceTypes() async {
    final dao = _dao;
    if (dao == null) return null;
    final rows = await dao.getAllPlaceTypes();
    if (rows.isEmpty) return null;
    return rows.map(_fromPlaceTypeRow).toList();
  }

  Future<List<PlaceType>> listPlaceTypes({
    bool? isActive,
    String? search,
    String? ordering,
    int? page,
  }) async {
    final response = await api.get(
      '/api/v1/place-types/',
      queryParameters: {
        if (isActive != null) 'is_active': isActive,
        if (search != null && search.isNotEmpty) 'search': search,
        if (ordering != null && ordering.isNotEmpty) 'ordering': ordering,
        if (page != null) 'page': page,
      },
    );

    final data = response.data;

    if (data is Map<String, dynamic> && data['results'] is List) {
      final results = (data['results'] as List).cast<Map<String, dynamic>>();
      final types = results.map(PlaceType.fromJson).toList();
      await _savePlaceTypesToCache(types);
      return types;
    }

    throw Exception('Respuesta inesperada en /api/v1/place-types/: $data');
  }

  Future<void> _savePlaceTypesToCache(List<PlaceType> types) async {
    final dao = _dao;
    if (dao == null) return;
    await dao.upsertPlaceTypes(types.map(_toPlaceTypeCompanion).toList());
  }

  PlaceType _fromPlaceTypeRow(CachedPlaceType row) =>
      PlaceType(id: row.id, name: row.name);

  PlaceTypesCacheCompanion _toPlaceTypeCompanion(PlaceType pt) =>
      PlaceTypesCacheCompanion(
        id: Value(pt.id),
        name: Value(pt.name),
      );

  // ── Area ──────────────────────────────────────────────────────────────────

  Future<List<Area>?> getCachedAreas() async {
    final dao = _areasDao;
    if (dao == null) return null;
    final rows = await dao.getAllAreas();
    if (rows.isEmpty) return null;
    return rows.map((r) => Area(id: r.id, name: r.name)).toList();
  }

  Future<List<Area>> listAreas({
    String? search,
    String? ordering,
    int? page,
  }) async {
    final response = await api.get(
      '/api/v1/areas/',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (ordering != null && ordering.isNotEmpty) 'ordering': ordering,
        if (page != null) 'page': page,
      },
    );

    final data = response.data;

    if (data is Map<String, dynamic> && data['results'] is List) {
      final results = (data['results'] as List).cast<Map<String, dynamic>>();
      final areas = results.map(Area.fromJson).toList();
      await _saveAreasToCache(areas);
      return areas;
    }

    throw Exception('Respuesta inesperada en /api/v1/areas/: $data');
  }

  Future<void> _saveAreasToCache(List<Area> areas) async {
    final dao = _areasDao;
    if (dao == null) return;
    await dao.upsertAreas(
      areas
          .map((a) => AreasCacheCompanion(
                id: Value(a.id),
                name: Value(a.name),
              ))
          .toList(),
    );
  }

  // ── Tag ───────────────────────────────────────────────────────────────────

  Future<List<Tag>?> getCachedTags() async {
    final dao = _tagsDao;
    if (dao == null) return null;
    final rows = await dao.getAllTags();
    if (rows.isEmpty) return null;
    return rows.map((r) => Tag(id: r.id, name: r.name)).toList();
  }

  Future<List<Tag>> listTags({
    String? name,
    String? search,
    String? ordering,
    int? page,
  }) async {
    final response = await api.get(
      '/api/v1/tags/',
      queryParameters: {
        if (name != null && name.isNotEmpty) 'name': name,
        if (search != null && search.isNotEmpty) 'search': search,
        if (ordering != null && ordering.isNotEmpty) 'ordering': ordering,
        if (page != null) 'page': page,
      },
    );

    final data = response.data;

    if (data is Map<String, dynamic> && data['results'] is List) {
      final results = (data['results'] as List).cast<Map<String, dynamic>>();
      final tags = results.map(Tag.fromJson).toList();
      await _saveTagsToCache(tags);
      return tags;
    }

    throw Exception('Respuesta inesperada en /api/v1/tags/: $data');
  }

  Future<void> _saveTagsToCache(List<Tag> tags) async {
    final dao = _tagsDao;
    if (dao == null) return;
    await dao.upsertTags(
      tags
          .map((t) => TagsCacheCompanion(
                id: Value(t.id),
                name: Value(t.name),
              ))
          .toList(),
    );
  }
}
