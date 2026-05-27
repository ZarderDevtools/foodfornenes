// lib/repositories/places_repository.dart

import 'package:drift/drift.dart' show Value;

import '../config/network/paged_result.dart';
import '../local/app_database.dart';
import '../local/daos/places_dao.dart';
import '../models/place.dart';
import '../models/place_list_query.dart';
import '../services/api_client.dart';

class PlacesRepository {
  final ApiClient api;
  final PlacesDao? _dao;

  PlacesRepository(this.api, {PlacesDao? dao}) : _dao = dao;

  /// Returns cached places from local DB, or null if cache is empty.
  Future<List<Place>?> getCachedPlaces() async {
    final dao = _dao;
    if (dao == null) return null;
    final rows = await dao.getAllPlaces();
    if (rows.isEmpty) return null;
    return rows.map(_fromRow).toList();
  }

  /// Filters cached places by [placeTypeId] and optional [search] text.
  Future<List<Place>> searchCachedPlaces(String placeTypeId, String search) async {
    final dao = _dao;
    if (dao == null) return [];
    final rows = await dao.getAllPlaces();
    final query = search.trim().toLowerCase();
    return rows
        .where((r) => r.placeTypeId == placeTypeId)
        .where((r) => query.isEmpty || r.name.toLowerCase().contains(query))
        .map(_fromRow)
        .toList();
  }

  Future<Place> updatePlace(String id, Map<String, dynamic> payload) async {
    final res = await api.patch('/api/v1/places/$id/', data: payload);
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Respuesta inesperada en PATCH /places/$id: $data');
    }
    return Place.fromJson(data);
  }

  Future<Place> fetchPlace(String id) async {
    final res = await api.get('/api/v1/places/$id/');
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Respuesta inesperada en GET /places/$id: $data');
    }
    return Place.fromJson(data);
  }

  Future<PagedResult<Place>> fetchPlaces(PlaceListQuery query) async {
    final res = await api.get(
      '/api/v1/places/',
      queryParameters: query.toQueryParams(),
    );

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Respuesta inesperada en GET /places: $data');
    }

    final result = PagedResult<Place>.fromJson(
      data,
      (itemJson) => Place.fromJson(itemJson),
    );

    await _savePlacesToCache(result.results);

    return result;
  }

  Future<void> _savePlacesToCache(List<Place> places) async {
    final dao = _dao;
    if (dao == null) return;
    final rows = places.map(_toCompanion).toList();
    await dao.upsertPlaces(rows);
  }

  Place _fromRow(CachedPlace row) => Place(
        id: row.id,
        householdId: row.householdId,
        name: row.name,
        placeTypeId: row.placeTypeId,
        areaId: row.areaId,
        areaName: row.areaName,
        priceRange: row.priceRange,
        description: row.description,
        url: row.url,
        avgRating: row.avgRating,
        avgPricePp: row.avgPricePp,
        visitsCount: row.visitsCount,
        lastVisitAt: row.lastVisitAt,
        tags: row.tags,
        tagIds: const [],
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  PlacesCacheCompanion _toCompanion(Place place) => PlacesCacheCompanion(
        id: Value(place.id),
        householdId: Value(place.householdId),
        name: Value(place.name),
        placeTypeId: Value(place.placeTypeId),
        areaId: Value(place.areaId),
        areaName: Value(place.areaName),
        priceRange: Value(place.priceRange),
        description: Value(place.description),
        url: Value(place.url),
        avgRating: Value(place.avgRating),
        avgPricePp: Value(place.avgPricePp),
        visitsCount: Value(place.visitsCount),
        lastVisitAt: Value(place.lastVisitAt),
        tags: Value(place.tags),
        syncStatus: const Value('synced'),
        createdAt: Value(place.createdAt),
        updatedAt: Value(place.updatedAt),
      );
}
