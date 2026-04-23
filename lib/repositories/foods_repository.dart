import 'package:drift/drift.dart' show Value;

import '../config/network/paged_result.dart';
import '../local/app_database.dart';
import '../local/daos/foods_dao.dart';
import '../models/food.dart';
import '../models/food_list_query.dart';
import '../services/api_client.dart';

class FoodsRepository {
  final ApiClient api;
  final FoodsDao? _dao;

  FoodsRepository(this.api, {FoodsDao? dao}) : _dao = dao;

  /// Returns cached foods from local DB, or null if cache is empty.
  Future<List<Food>?> getCachedFoods() async {
    final dao = _dao;
    if (dao == null) return null;
    final rows = await dao.getAllFoods();
    if (rows.isEmpty) return null;
    return rows.map(_fromRow).toList();
  }

  Future<Food> fetchFood(String id) async {
    final res = await api.get('/api/v1/foods/$id/');
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Respuesta inesperada en GET /foods/$id: $data');
    }
    return Food.fromJson(data);
  }

  Future<Food> updateFood(String id, Map<String, dynamic> payload) async {
    final res = await api.patch('/api/v1/foods/$id/', data: payload);
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Respuesta inesperada en PATCH /foods/$id: $data');
    }
    return Food.fromJson(data);
  }

  Future<PagedResult<Food>> fetchFoods(FoodListQuery query) async {
    final res = await api.get(
      '/api/v1/foods/',
      queryParameters: query.toQueryParams(),
    );

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Respuesta inesperada en GET /foods: $data');
    }

    final result = PagedResult<Food>.fromJson(
      data,
      (itemJson) => Food.fromJson(itemJson),
    );

    await _saveFoodsToCache(result.results);

    return result;
  }

  Future<void> _saveFoodsToCache(List<Food> foods) async {
    final dao = _dao;
    if (dao == null) return;
    final rows = foods.map(_toCompanion).toList();
    await dao.upsertFoods(rows);
  }

  Food _fromRow(CachedFood row) => Food(
        id: row.id,
        householdId: row.householdId,
        name: row.name,
        isActive: row.isActive,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  FoodsCacheCompanion _toCompanion(Food food) => FoodsCacheCompanion(
        id: Value(food.id),
        householdId: Value(food.householdId),
        name: Value(food.name),
        isActive: Value(food.isActive),
        createdAt: Value(food.createdAt),
        updatedAt: Value(food.updatedAt),
      );
}
