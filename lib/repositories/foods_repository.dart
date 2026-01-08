import '../config/network/paged_result.dart';
import '../models/food.dart';
import '../models/food_list_query.dart';
import '../services/api_client.dart';

class FoodsRepository {
  final ApiClient api;

  FoodsRepository(this.api);

  Future<PagedResult<Food>> fetchFoods(FoodListQuery query) async {
    final res = await api.get(
      '/api/v1/foods/',
      queryParameters: query.toQueryParams(),
    );

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Respuesta inesperada en GET /foods: $data');
    }

    return PagedResult<Food>.fromJson(
      data,
      (itemJson) => Food.fromJson(itemJson),
    );
  }
}
