// lib/features/places/domain/place.dart

class Place {
  final String id;
  final String householdId;
  final String name;
  final String placeTypeId;
  final String? areaId;

  /// "€", "€€", "€€€", ...
  final String priceRange;

  final String description;
  final String url;

  /// Puede venir null
  final double? avgRating;

  /// Puede venir null
  final double? avgPricePp;

  final int visitsCount;
  final DateTime? lastVisitAt;

  /// En tu JSON viene como lista (ahora mismo vacía). Asumimos lista de IDs o strings.
  /// Si más adelante el backend devuelve objetos de tag, lo adaptamos.
  final List<String> tags;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Place({
    required this.id,
    required this.householdId,
    required this.name,
    required this.placeTypeId,
    required this.areaId,
    required this.priceRange,
    required this.description,
    required this.url,
    required this.avgRating,
    required this.avgPricePp,
    required this.visitsCount,
    required this.lastVisitAt,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    DateTime? _toDateTime(dynamic v) {
      if (v == null) return null;
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
      return null;
    }

    List<String> _toStringList(dynamic v) {
      if (v == null) return const [];
      if (v is List) {
        // Por ahora: convierte elementos a string (IDs o nombres).
        return v.map((e) => e.toString()).toList();
      }
      return const [];
    }

    return Place(
      id: (json["id"] ?? "").toString(),
      householdId: (json["household"] ?? "").toString(),
      name: (json["name"] ?? "").toString(),
      placeTypeId: (json["place_type"] ?? "").toString(),
      areaId: json["area"] == null ? null : json["area"].toString(),
      priceRange: (json["price_range"] ?? "€").toString(),
      description: (json["description"] ?? "").toString(),
      url: (json["url"] ?? "").toString(),
      avgRating: _toDouble(json["avg_rating"]),
      avgPricePp: _toDouble(json["avg_price_pp"]),
      visitsCount: (json["visits_count"] as num?)?.toInt() ?? 0,
      lastVisitAt: _toDateTime(json["last_visit_at"]),
      tags: _toStringList(json["tags"]),
      createdAt: DateTime.parse(json["created_at"] as String),
      updatedAt: DateTime.parse(json["updated_at"] as String),
    );
  }

  // Helpers para la ListScreen (lo que tú querías)
  String get displayRating => avgRating == null ? "--" : avgRating!.toStringAsFixed(1);

  /// Para tu UI: si no quieres mostrar price_range cuando no exista,
  /// aquí siempre existe (default en backend), pero lo dejamos por si cambias eso.
  String get displayPriceRange => priceRange;

  bool get hasTags => tags.isNotEmpty;
}
