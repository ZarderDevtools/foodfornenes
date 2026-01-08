import '../config/network/paged_result.dart';
import '../models/food.dart';
import '../models/food_list_query.dart';
import '../repositories/foods_repository.dart';

class FoodsService {
  final FoodsRepository repo;

  FoodsService(this.repo);

  FoodListQuery? _lastQuery;
  String? _nextUrl;
  int _currentPage = 1;

  bool get hasNext => _nextUrl != null && _nextUrl!.isNotEmpty;

  Future<PagedResult<Food>> loadFirstPage(FoodListQuery query) async {
    _currentPage = 1;
    _lastQuery = query.copyWith(page: 1);

    final page1 = await repo.fetchFoods(_lastQuery!);
    _nextUrl = page1.next;
    return page1;
  }

  Future<PagedResult<Food>> refresh() async {
    final q = _lastQuery;
    if (q == null) {
      return loadFirstPage(const FoodListQuery(page: 1));
    }
    return loadFirstPage(q.copyWith(page: 1));
  }

  Future<PagedResult<Food>> loadNextPage() async {
    final q = _lastQuery;
    if (q == null) {
      throw StateError('No hay query inicial. Llama antes a loadFirstPage().');
    }
    if (!hasNext) {
      return const PagedResult<Food>(
        count: 0,
        next: null,
        previous: null,
        results: <Food>[],
      );
    }

    _currentPage += 1;
    final nextQuery = q.copyWith(page: _currentPage);

    final pageN = await repo.fetchFoods(nextQuery);
    _lastQuery = nextQuery;
    _nextUrl = pageN.next;
    return pageN;
  }
}
