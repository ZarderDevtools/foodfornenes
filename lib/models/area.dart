class Area {
  final String id;
  final String name;

  Area({
    required this.id,
    required this.name,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'] as String,
      name: (json['name'] ?? '') as String,
    );
  }
}
