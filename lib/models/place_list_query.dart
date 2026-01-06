// lib/features/places/domain/place_list_query.dart

class PlaceListQuery {
  final String? placeTypeId; // place_type (UUID)
  final String? areaId;      // area (UUID)
  final String? priceRange;  // "€", "€€", ...
  final double? minAvgRating;
  final double? maxAvgPricePp;
  final String? search;
  final String? ordering;    // e.g. "name" o "-avg_rating"
  final int page;

  const PlaceListQuery({
    this.placeTypeId,
    this.areaId,
    this.priceRange,
    this.minAvgRating,
    this.maxAvgPricePp,
    this.search,
    this.ordering,
    this.page = 1,
  });

  PlaceListQuery copyWith({
    String? placeTypeId,
    String? areaId,
    String? priceRange,
    double? minAvgRating,
    double? maxAvgPricePp,
    String? search,
    String? ordering,
    int? page,
  }) {
    return PlaceListQuery(
      placeTypeId: placeTypeId ?? this.placeTypeId,
      areaId: areaId ?? this.areaId,
      priceRange: priceRange ?? this.priceRange,
      minAvgRating: minAvgRating ?? this.minAvgRating,
      maxAvgPricePp: maxAvgPricePp ?? this.maxAvgPricePp,
      search: search ?? this.search,
      ordering: ordering ?? this.ordering,
      page: page ?? this.page,
    );
  }

  Map<String, String> toQueryParams() {
    final m = <String, String>{};

    if (placeTypeId != null && placeTypeId!.isNotEmpty) {
      m["place_type"] = placeTypeId!;
    }
    if (areaId != null && areaId!.isNotEmpty) {
      m["area"] = areaId!;
    }
    if (priceRange != null && priceRange!.isNotEmpty) {
      m["price_range"] = priceRange!;
    }
    if (minAvgRating != null) {
      m["min_avg_rating"] = minAvgRating!.toString();
    }
    if (maxAvgPricePp != null) {
      m["max_avg_price_pp"] = maxAvgPricePp!.toString();
    }
    if (search != null && search!.trim().isNotEmpty) {
      m["search"] = search!.trim();
    }
    if (ordering != null && ordering!.trim().isNotEmpty) {
      m["ordering"] = ordering!.trim();
    }

    m["page"] = page.toString();
    return m;
  }
}
