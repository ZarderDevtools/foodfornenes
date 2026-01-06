// lib/core/network/paged_result.dart

class PagedResult<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  const PagedResult({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  bool get hasNext => next != null && next!.isNotEmpty;

  /// Factory genérico para parsear el JSON paginado de DRF.
  /// - [fromJsonT] convierte cada item de results a T.
  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawResults = (json["results"] as List<dynamic>? ?? <dynamic>[]);
    final typedResults = rawResults
        .whereType<Map<String, dynamic>>()
        .map(fromJsonT)
        .toList();

    return PagedResult<T>(
      count: (json["count"] as num?)?.toInt() ?? typedResults.length,
      next: json["next"] as String?,
      previous: json["previous"] as String?,
      results: typedResults,
    );
  }
}
