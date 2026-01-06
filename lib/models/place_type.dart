class PlaceType {
  final String id;
  final String name;

  PlaceType({
    required this.id,
    required this.name,
  });

  factory PlaceType.fromJson(Map<String, dynamic> json) {
    return PlaceType(
      id: json['id'] as String,
      name: (json['name'] ?? '') as String,
    );
  }
}
