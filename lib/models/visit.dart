// lib/models/visit.dart

class Visit {
  final String id;
  final String placeId;
  final String authorId;

  /// Fecha de la visita (solo día, sin hora).
  final DateTime date;

  /// Rating puede venir como String "6.0" desde el backend.
  final double? rating;

  /// Precio por persona, puede ser null o String "12.90".
  final double? pricePp;

  /// Comentario. Puede ser string vacío, nunca null en el modelo.
  final String comment;

  final DateTime createdAt;

  const Visit({
    required this.id,
    required this.placeId,
    required this.authorId,
    required this.date,
    required this.rating,
    required this.pricePp,
    required this.comment,
    required this.createdAt,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
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

    return Visit(
      id: (json['id'] ?? '').toString(),
      placeId: (json['place'] ?? '').toString(),
      authorId: (json['author'] ?? '').toString(),
      date: DateTime.parse(json['date'] as String),
      rating: _parseDouble(json['rating']),
      pricePp: _parseDouble(json['price_per_person']),
      comment: (json['comment'] ?? '').toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Representación del rating para UI. Devuelve "--" si no hay rating.
  String get displayRating =>
      rating != null ? rating!.toStringAsFixed(1) : '--';

  /// Representación del precio para UI. Devuelve null si no hay precio.
  String? get displayPricePp =>
      pricePp != null ? '${pricePp!.toStringAsFixed(2)} €' : null;
}
