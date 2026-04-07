// lib/models/place.dart

import 'tag.dart';

class Place {
  final String id;
  final String householdId;
  final String name;
  final String placeTypeId;
  final String? areaId;
  final String? areaName;

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

  /// Tags del place. Cada elemento es el nombre del tag (para display).
  final List<String> tags;

  /// UUIDs de los tags (para pre-popular formularios de edición).
  /// Solo disponible cuando el endpoint devuelve objetos {id, name}.
  final List<String> tagIds;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Place({
    required this.id,
    required this.householdId,
    required this.name,
    required this.placeTypeId,
    required this.areaId,
    required this.areaName,
    required this.priceRange,
    required this.description,
    required this.url,
    required this.avgRating,
    required this.avgPricePp,
    required this.visitsCount,
    required this.lastVisitAt,
    required this.tags,
    required this.tagIds,
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

    List<String> _parseTags(dynamic v) {
      if (v == null) return const [];
      if (v is! List) return const [];
      return v
          .map((e) {
            if (e is Map<String, dynamic>) return Tag.fromJson(e).name;
            return e.toString();
          })
          .where((s) => s.isNotEmpty)
          .toList();
    }

    List<String> _parseTagIds(dynamic v) {
      if (v == null) return const [];
      if (v is! List) return const [];
      return v
          .map((e) {
            // Solo extraemos ID si el elemento es un objeto {id, name}
            if (e is Map<String, dynamic>) return (e['id'] ?? '').toString();
            return ''; // String plano → no podemos extraer ID
          })
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return Place(
      id: (json["id"] ?? "").toString(),
      householdId: (json["household"] ?? "").toString(),
      name: (json["name"] ?? "").toString(),
      placeTypeId: (json["place_type"] ?? "").toString(),
      areaId: json["area"] is Map<String, dynamic>
          ? (json["area"]["id"] as String?)
          : (json["area"] == null ? null : json["area"].toString()),
      areaName: json["area"] is Map<String, dynamic>
          ? (json["area"]["name"] as String?)
          : null,
      priceRange: (json["price_range"] ?? "€").toString(),
      description: (json["description"] ?? "").toString(),
      url: (json["url"] ?? "").toString(),
      avgRating: _toDouble(json["avg_rating"]),
      avgPricePp: _toDouble(json["avg_price_pp"]),
      visitsCount: (json["visits_count"] as num?)?.toInt() ?? 0,
      lastVisitAt: _toDateTime(json["last_visit_at"]),
      tags: _parseTags(json["tags"]),
      tagIds: _parseTagIds(json["tags"]),
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
