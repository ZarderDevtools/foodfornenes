// lib/repositories/visits_repository.dart

import '../config/network/paged_result.dart';
import '../models/visit.dart';
import '../services/api_client.dart';

class VisitsRepository {
  final ApiClient api;

  VisitsRepository(this.api);

  /// Obtiene las visitas de un place concreto, ordenadas por defecto
  /// de más reciente a más antigua (-created_at).
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

    return PagedResult<Visit>.fromJson(
      data,
      (itemJson) => Visit.fromJson(itemJson),
    );
  }
}
