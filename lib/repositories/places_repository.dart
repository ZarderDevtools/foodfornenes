// lib/repositories/places_repository.dart

import '../services/api_client.dart';
import '../config/network/paged_result.dart';
import '../models/place.dart';
import '../models/place_list_query.dart';

class PlacesRepository {
  final ApiClient api;

  PlacesRepository(this.api);

  Future<PagedResult<Place>> fetchPlaces(PlaceListQuery query) async {
    final res = await api.get(
      '/api/v1/places/',
      queryParameters: query.toQueryParams(),
    );

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Respuesta inesperada en GET /places: $data');
    }

    return PagedResult<Place>.fromJson(
      data,
      (itemJson) => Place.fromJson(itemJson),
    );
  }
}
