class Food {
  final String id;
  final String householdId;
  final String name;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Food({
    required this.id,
    required this.householdId,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: (json['id'] ?? '').toString(),
      householdId: (json['household'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      isActive: json['is_active'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
