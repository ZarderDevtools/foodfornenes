// lib/services/places_service.dart

import '../config/network/paged_result.dart';
import '../models/place.dart';
import '../models/place_list_query.dart';
import '../repositories/places_repository.dart';

class PlacesService {
  final PlacesRepository repo;

  PlacesService(this.repo);

  PlaceListQuery? _lastQuery;
  String? _nextUrl; // DRF devuelve next como URL absoluta o null
  int _currentPage = 1;

  bool get hasNext => _nextUrl != null && _nextUrl!.isNotEmpty;

  /// Carga la página 1 con el query dado y guarda el estado para paginar.
  Future<PagedResult<Place>> loadFirstPage(PlaceListQuery query) async {
    _currentPage = 1;
    _lastQuery = query.copyWith(page: 1);

    final page1 = await repo.fetchPlaces(_lastQuery!);
    _nextUrl = page1.next;
    return page1;
  }

  /// Recarga usando el último query (page 1).
  Future<PagedResult<Place>> refresh() async {
    final q = _lastQuery;
    if (q == null) {
      // Si refrescan sin carga previa, carga default.
      return loadFirstPage(const PlaceListQuery(page: 1));
    }
    return loadFirstPage(q.copyWith(page: 1));
  }

  /// Carga la siguiente página si hay más (next != null).
  /// Si no hay más, devuelve results vacíos.
  Future<PagedResult<Place>> loadNextPage() async {
    final q = _lastQuery;
    if (q == null) {
      throw StateError('No hay query inicial. Llama antes a loadFirstPage().');
    }
    if (!hasNext) {
      return const PagedResult<Place>(
        count: 0,
        next: null,
        previous: null,
        results: <Place>[],
      );
    }

    _currentPage += 1;
    final nextQuery = q.copyWith(page: _currentPage);

    final pageN = await repo.fetchPlaces(nextQuery);
    _lastQuery = nextQuery;
    _nextUrl = pageN.next;
    return pageN;
  }
}
