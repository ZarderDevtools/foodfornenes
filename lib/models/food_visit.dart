// lib/models/food_visit.dart

/// Representa un registro de visita asociado a una comida concreta.
/// Corresponde al endpoint GET /api/v1/visit-foods/?food=<uuid>.
class FoodVisit {
  /// ID del registro visit-food.
  final String id;

  /// ID de la visita relacionada.
  final String visitId;

  /// ID de la comida relacionada.
  final String foodId;

  /// Nombre del sitio donde ocurrió la visita, si el backend lo devuelve.
  final String? placeName;

  /// Fecha de la visita.
  final DateTime date;

  /// Valoración de la visita. Puede venir como String "6.0" desde el backend.
  final double? rating;

  /// Precio por persona. Puede ser null.
  final double? pricePp;

  /// Comentario de la visita. Nunca null en el modelo, puede ser vacío.
  final String comment;

  final DateTime createdAt;

  const FoodVisit({
    required this.id,
    required this.visitId,
    required this.foodId,
    this.placeName,
    required this.date,
    required this.rating,
    required this.pricePp,
    required this.comment,
    required this.createdAt,
  });

  factory FoodVisit.fromJson(Map<String, dynamic> json) {
    // El backend puede devolver `visit` como objeto anidado o como UUID string.
    final visitRaw = json['visit'];
    final Map<String, dynamic>? visitMap =
        visitRaw is Map<String, dynamic> ? visitRaw : null;

    // Extrae un campo buscando primero en el objeto visit anidado, luego en la raíz.
    dynamic _field(String key) => visitMap?[key] ?? json[key];

    double? _parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) {
        final s = v.trim();
        if (s.isEmpty) return null;
        return double.tryParse(s);
      }
      return null;
    }

    final visitId = visitMap != null
        ? (visitMap['id'] ?? '').toString()
        : (visitRaw ?? '').toString();

    return FoodVisit(
      id: (json['id'] ?? '').toString(),
      visitId: visitId,
      foodId: (json['food'] ?? '').toString(),
      placeName: _field('place_name')?.toString(),
      date: DateTime.parse((_field('date') as String)),
      rating: _parseDouble(_field('rating')),
      pricePp: _parseDouble(_field('price_per_person')),
      comment: (_field('comment') ?? '').toString(),
      createdAt: DateTime.parse((_field('created_at') as String)),
    );
  }

  String get displayRating =>
      rating != null ? rating!.toStringAsFixed(1) : '--';

  String? get displayPricePp =>
      pricePp != null ? '${pricePp!.toStringAsFixed(2)} €' : null;
}
