import 'package:flutter/material.dart';

import '../../models/food.dart';
import '../../models/food_list_query.dart';
import '../../repositories/foods_repository.dart';
import '../../services/api_client.dart';
import '../../services/foods_service.dart';
import '../list/list_screen.dart';

class FoodsListScreen extends StatefulWidget {
  final String title;
  final String? ordering;

  const FoodsListScreen({
    super.key,
    required this.title,
    this.ordering,
  });

  @override
  State<FoodsListScreen> createState() => _FoodsListScreenState();
}

class _FoodsListScreenState extends State<FoodsListScreen> {
  FoodsService? _service;
  late FoodListQuery _query;

  bool _ready = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _query = FoodListQuery(
      isActive: true,
      ordering: widget.ordering,
      page: 1,
    );
    _init();
  }

  Future<void> _init() async {
    try {
      final api = await ApiClient.create();
      final repo = FoodsRepository(api);
      final service = FoodsService(repo);

      if (!mounted) return;
      setState(() {
        _service = service;
        _ready = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initError = e.toString();
        _ready = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_initError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 36),
                const SizedBox(height: 10),
                const Text(
                  'Error inicializando la pantalla.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _initError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _ready = false;
                      _initError = null;
                    });
                    _init();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final service = _service!;

    return ListScreen<Food>(
      title: widget.title,
      fetchFirstPage: () => service.loadFirstPage(_query),
      fetchNextPage: () => service.loadNextPage(),
      hasNextPage: () => service.hasNext,
      getName: (food) => food.name,
      getTags: (_) => const [],
      getRatingAvg: (_) => null,
      getPriceLevel: (_) => null,
      onTapItem: (_) {},
      onCreate: () {},
      onHome: () => Navigator.popUntil(context, (route) => route.isFirst),
      onBack: () => Navigator.pop(context),
      onFilters: null,
      onSort: null,
      emptyMessageOverride: 'No existen ${widget.title.toLowerCase()} actualmente',
    );
  }
}
