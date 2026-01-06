import '../services/api_client.dart';
import '../models/place_type.dart';

class CategorizationRepository {
  final ApiClient api;
  CategorizationRepository(this.api);
    
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
      return results.map(PlaceType.fromJson).toList();
    }

    throw Exception('Respuesta inesperada en /api/v1/place-types/: $data');
  }

}
