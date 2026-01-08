class FoodListQuery {
  final bool? isActive;
  final String? name;
  final String? search;
  final String? ordering;
  final int page;

  const FoodListQuery({
    this.isActive,
    this.name,
    this.search,
    this.ordering,
    this.page = 1,
  });

  FoodListQuery copyWith({
    bool? isActive,
    String? name,
    String? search,
    String? ordering,
    int? page,
  }) {
    return FoodListQuery(
      isActive: isActive ?? this.isActive,
      name: name ?? this.name,
      search: search ?? this.search,
      ordering: ordering ?? this.ordering,
      page: page ?? this.page,
    );
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{};

    if (isActive != null) {
      params['is_active'] = isActive.toString();
    }
    if (name != null && name!.trim().isNotEmpty) {
      params['name'] = name!.trim();
    }
    if (search != null && search!.trim().isNotEmpty) {
      params['search'] = search!.trim();
    }
    if (ordering != null && ordering!.trim().isNotEmpty) {
      params['ordering'] = ordering!.trim();
    }

    params['page'] = page.toString();
    return params;
  }
}
