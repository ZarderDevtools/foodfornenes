// lib/models/food_list_query.dart

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

  // Sentinel para diferenciar "no tocar" vs "poner null"
  static const Object _unset = Object();

  FoodListQuery copyWith({
    Object? isActive = _unset,
    Object? name = _unset,
    Object? search = _unset,
    Object? ordering = _unset,
    int? page,
  }) {
    return FoodListQuery(
      isActive: identical(isActive, _unset) ? this.isActive : isActive as bool?,
      name: identical(name, _unset) ? this.name : name as String?,
      search: identical(search, _unset) ? this.search : search as String?,
      ordering: identical(ordering, _unset) ? this.ordering : ordering as String?,
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
