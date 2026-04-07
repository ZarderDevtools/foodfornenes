// lib/models/place_list_query.dart

class PlaceListQuery {
  final String? placeTypeId; // place_type (UUID)
  final String? areaId; // area (UUID)

  /// Filtro legacy (un único valor): "€", "€€", ...
  final String? priceRange; // price_range

  /// Nuevo: filtro multi-valor. Ej: ["€", "€€"] -> price_range_in=€,€€
  final List<String>? priceRangeIn; // price_range_in

  final double? minAvgRating;
  final double? maxAvgPricePp;
  final String? search;

  /// Filtro por tags: lista de UUIDs -> tags=uuid1,uuid2
  final List<String>? tagsIn;

  /// Filtro por áreas: lista de UUIDs -> area=uuid1,uuid2
  final List<String>? areasIn;

  final String? ordering; // e.g. "name" o "-avg_rating"
  final int page;

  const PlaceListQuery({
    this.placeTypeId,
    this.areaId,
    this.priceRange,
    this.priceRangeIn,
    this.minAvgRating,
    this.maxAvgPricePp,
    this.search,
    this.tagsIn,
    this.areasIn,
    this.ordering,
    this.page = 1,
  });

  // Sentinel para diferenciar "no tocar" vs "poner null"
  static const Object _unset = Object();

  PlaceListQuery copyWith({
    Object? placeTypeId = _unset,
    Object? areaId = _unset,
    Object? priceRange = _unset,
    Object? priceRangeIn = _unset,
    Object? minAvgRating = _unset,
    Object? maxAvgPricePp = _unset,
    Object? search = _unset,
    Object? tagsIn = _unset,
    Object? areasIn = _unset,
    Object? ordering = _unset,
    int? page,
  }) {
    return PlaceListQuery(
      placeTypeId: identical(placeTypeId, _unset) ? this.placeTypeId : placeTypeId as String?,
      areaId: identical(areaId, _unset) ? this.areaId : areaId as String?,
      priceRange: identical(priceRange, _unset) ? this.priceRange : priceRange as String?,
      priceRangeIn: identical(priceRangeIn, _unset) ? this.priceRangeIn : priceRangeIn as List<String>?,
      minAvgRating: identical(minAvgRating, _unset) ? this.minAvgRating : minAvgRating as double?,
      maxAvgPricePp: identical(maxAvgPricePp, _unset) ? this.maxAvgPricePp : maxAvgPricePp as double?,
      search: identical(search, _unset) ? this.search : search as String?,
      tagsIn: identical(tagsIn, _unset) ? this.tagsIn : tagsIn as List<String>?,
      areasIn: identical(areasIn, _unset) ? this.areasIn : areasIn as List<String>?,
      ordering: identical(ordering, _unset) ? this.ordering : ordering as String?,
      page: page ?? this.page,
    );
  }

  Map<String, String> toQueryParams() {
    final m = <String, String>{};

    if (placeTypeId != null && placeTypeId!.isNotEmpty) {
      m["place_type"] = placeTypeId!;
    }

    // areasIn (multi) tiene prioridad sobre areaId (legacy single)
    final cleanedAreasIn = (areasIn ?? const <String>[])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (cleanedAreasIn.isNotEmpty) {
      m["area"] = cleanedAreasIn.join(",");
    } else if (areaId != null && areaId!.isNotEmpty) {
      m["area"] = areaId!;
    }

    // Nuevo: multi-€ (tiene prioridad sobre priceRange)
    final cleanedPriceRangeIn = (priceRangeIn ?? const <String>[])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (cleanedPriceRangeIn.isNotEmpty) {
      m["price_range_in"] = cleanedPriceRangeIn.join(",");
    } else if (priceRange != null && priceRange!.isNotEmpty) {
      // Legacy: un solo valor
      m["price_range"] = priceRange!;
    }

    if (minAvgRating != null) {
      m["min_avg_rating"] = minAvgRating!.toString();
    }
    if (maxAvgPricePp != null) {
      m["max_avg_price_pp"] = maxAvgPricePp!.toString();
    }

    final cleanedTagsIn = (tagsIn ?? const <String>[])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (cleanedTagsIn.isNotEmpty) {
      m["tags"] = cleanedTagsIn.join(",");
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
