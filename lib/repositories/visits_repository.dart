// lib/repositories/visits_repository.dart

import 'package:drift/drift.dart' show Value;

import '../config/network/paged_result.dart';
import '../local/app_database.dart';
import '../local/daos/food_visits_dao.dart';
import '../local/daos/visits_dao.dart';
import '../models/food_visit.dart';
import '../models/visit.dart';
import '../services/api_client.dart';

class VisitsRepository {
  final ApiClient api;
  final VisitsDao? _visitsDao;
  final FoodVisitsDao? _foodVisitsDao;

  VisitsRepository(
    this.api, {
    VisitsDao? visitsDao,
    FoodVisitsDao? foodVisitsDao,
  })  : _visitsDao = visitsDao,
        _foodVisitsDao = foodVisitsDao;

  // ── Place visits ──────────────────────────────────────────────────────────

  Future<List<Visit>?> getCachedPlaceVisits(String placeId) async {
    final dao = _visitsDao;
    if (dao == null) return null;
    final rows = await dao.getVisitsByPlace(placeId);
    if (rows.isEmpty) return null;
    return rows.map(_fromRow).toList();
  }

  Future<List<Visit>> getCachedPendingVisits(String placeId) async {
    final dao = _visitsDao;
    if (dao == null) return [];
    final rows = await dao.getPendingByPlace(placeId);
    return rows.map(_fromRow).toList();
  }

  Future<Visit?> fetchLatestPlaceVisit(String placeId) async {
    final res = await api.get(
      '/api/v1/visits/',
      queryParameters: {
        'place': placeId,
        'ordering': '-created_at',
        'page': 1,
      },
    );
    final data = res.data;
    if (data is! Map<String, dynamic>) return null;
    final result = PagedResult<Visit>.fromJson(data, (j) => Visit.fromJson(j));
    await _saveVisitsToCache(result.results);
    return result.results.isNotEmpty ? result.results.first : null;
  }

  Future<PagedResult<Visit>> fetchPlaceVisits(
    String placeId, {
    String ordering = '-created_at',
    int page = 1,
  }) async {
    final res = await api.get(
      '/api/v1/visits/',
      queryParameters: {
        'place': placeId,
        'ordering': ordering,
        'page': page,
      },
    );

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Respuesta inesperada en GET /visits/: $data');
    }

    final result = PagedResult<Visit>.fromJson(
      data,
      (itemJson) => Visit.fromJson(itemJson),
    );

    if (page == 1) {
      await _saveVisitsToCache(result.results);
    }

    return result;
  }

  Future<PagedResult<Visit>> fetchGlobalVisitsPage(int page) async {
    final res = await api.get(
      '/api/v1/visits/',
      queryParameters: {
        'ordering': '-created_at',
        'page': page,
      },
    );

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Respuesta inesperada en GET /visits/: $data');
    }

    final result = PagedResult<Visit>.fromJson(
      data,
      (itemJson) => Visit.fromJson(itemJson),
    );

    await _saveVisitsToCache(result.results);

    return result;
  }

  Future<PagedResult<FoodVisit>> fetchGlobalFoodVisitsPage(int page) async {
    final res = await api.get(
      '/api/v1/visit-foods/',
      queryParameters: {
        'ordering': '-created_at',
        'page': page,
      },
    );

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Respuesta inesperada en GET /visit-foods/: $data');
    }

    final result = PagedResult<FoodVisit>.fromJson(
      data,
      (itemJson) => FoodVisit.fromJson(itemJson),
    );

    await _saveFoodVisitsToCache(result.results);

    return result;
  }

  Future<void> _saveVisitsToCache(List<Visit> visits) async {
    final dao = _visitsDao;
    if (dao == null) return;
    await dao.upsertVisits(visits.map(_toCompanion).toList());
  }

  Visit _fromRow(CachedVisit row) => Visit(
        id: row.id,
        placeId: row.placeId,
        authorId: row.authorId,
        date: row.date,
        rating: row.rating,
        pricePp: row.pricePp,
        comment: row.comment,
        createdAt: row.createdAt,
      );

  VisitsCacheCompanion _toCompanion(Visit v) => VisitsCacheCompanion(
        id: Value(v.id),
        placeId: Value(v.placeId),
        authorId: Value(v.authorId),
        date: Value(v.date),
        rating: Value(v.rating),
        pricePp: Value(v.pricePp),
        comment: Value(v.comment),
        syncStatus: const Value('synced'),
        createdAt: Value(v.createdAt),
      );

  // ── Food visits ───────────────────────────────────────────────────────────

  Future<List<FoodVisit>?> getCachedFoodVisits(String foodId) async {
    final dao = _foodVisitsDao;
    if (dao == null) return null;
    final rows = await dao.getFoodVisitsByFood(foodId);
    if (rows.isEmpty) return null;
    // Pending/failed first (newest first within group), then synced (newest first).
    const localStatuses = {'pending_create', 'sync_failed'};
    final sorted = [...rows]
      ..sort((a, b) {
        final aLocal = localStatuses.contains(a.syncStatus);
        final bLocal = localStatuses.contains(b.syncStatus);
        if (aLocal != bLocal) return aLocal ? -1 : 1;
        return b.createdAt.compareTo(a.createdAt);
      });
    return sorted.map(_fromFoodVisitRow).toList();
  }

  Future<List<FoodVisit>> getPendingFoodVisits(String foodId) async {
    final dao = _foodVisitsDao;
    if (dao == null) return [];
    final rows = await dao.getPendingByFood(foodId);
    return rows.map(_fromFoodVisitRow).toList();
  }

  Future<PagedResult<FoodVisit>> fetchFoodVisits(
    String foodId, {
    String ordering = '-created_at',
    int page = 1,
  }) async {
    final res = await api.get(
      '/api/v1/visit-foods/',
      queryParameters: {
        'food': foodId,
        'ordering': ordering,
        'page': page,
      },
    );

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Respuesta inesperada en GET /visit-foods/: $data');
    }

    final result = PagedResult<FoodVisit>.fromJson(
      data,
      (itemJson) => FoodVisit.fromJson(itemJson),
    );

    if (page == 1) {
      await _saveFoodVisitsToCache(result.results);
    }

    return result;
  }

  Future<void> _saveFoodVisitsToCache(List<FoodVisit> visits) async {
    final dao = _foodVisitsDao;
    if (dao == null) return;
    await dao.upsertFoodVisits(visits.map(_toFoodVisitCompanion).toList());
  }

  FoodVisit _fromFoodVisitRow(CachedFoodVisit row) => FoodVisit(
        id: row.id,
        visitId: row.visitId,
        foodId: row.foodId,
        placeName: row.placeName,
        date: row.date,
        rating: row.rating,
        pricePp: row.pricePp,
        comment: row.comment,
        createdAt: row.createdAt,
      );

  FoodVisitsCacheCompanion _toFoodVisitCompanion(FoodVisit fv) =>
      FoodVisitsCacheCompanion(
        id: Value(fv.id),
        visitId: Value(fv.visitId),
        foodId: Value(fv.foodId),
        placeName: Value(fv.placeName),
        date: Value(fv.date),
        rating: Value(fv.rating),
        pricePp: Value(fv.pricePp),
        comment: Value(fv.comment),
        syncStatus: const Value('synced'),
        createdAt: Value(fv.createdAt),
      );
}
