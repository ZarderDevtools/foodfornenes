// lib/screens/foods/foods_list_screen.dart

import 'package:flutter/material.dart';

import '../../models/food.dart';
import '../../models/food_list_query.dart';
import '../../repositories/foods_repository.dart';
import '../../services/api_client.dart';
import '../../services/foods_service.dart';
import '../filters/filter_definition.dart';
import '../filters/filter_screen.dart';
import '../list/list_screen.dart';
import "../sort/sort_definition.dart";
import "../sort/sort_screen.dart";
import 'add_food/add_food_flow.dart';

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

  bool get _hasActiveFilters {
    final s = _query.search;
    return s != null && s.trim().isNotEmpty;
  }

  Future<void> _openFilters() async {
    final filters = <FilterDefinition<FoodListQuery>>[
      FilterDefinition<FoodListQuery>(
        id: 'search',
        label: 'Nombre',
        type: FilterType.text,
        getValue: (q) => q.search,
        setValue: (q, v) {
          final text = (v as String?)?.trim();
          return q.copyWith(search: (text != null && text.isNotEmpty) ? text : null);
        },
      ),
    ];

    final result = await Navigator.of(context).push<FoodListQuery>(
      MaterialPageRoute(
        builder: (_) => FilterScreen<FoodListQuery>(
          title: 'Filtros',
          initialValue: _query,
          filters: filters,
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      _query = result.copyWith(page: 1);
    });
  }

  Future<void> _openSort() async {
    final result = await Navigator.push<SortResult>(
      context,
      MaterialPageRoute(
        builder: (_) => SortScreen(
          title: "Ordenar comidas",
          initialOrdering: _query.ordering,
          options: const [
            SortDefinition(label: "Nombre", field: "name", humanStringSort: true),
            SortDefinition(label: "Fecha de creación", field: "created_at"),
            SortDefinition(label: "Última modificación", field: "updated_at"),
          ],
        ),
      ),
    );

    // Si el usuario vuelve con el back del sistema o algo raro:
    if (result == null) return;

    // Cancelar -> no hacemos nada
    if (!result.applied) return;

    // Aplicar (ordering puede ser null si limpió)
    setState(() {
      _query = _query.copyWith(ordering: result.ordering);
    });
    final service = _service;
    if (service == null) return;
    await service.loadFirstPage(_query);
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
      onCreate: () async {
        final created = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => const AddFoodFlow()),
        );

        if (created == true) {
          // Volvemos a primera página para ver el nuevo registro
          setState(() {
            _query = _query.copyWith(page: 1);
          });
          await service.loadFirstPage(_query);
        }
      },
      onHome: () => Navigator.popUntil(context, (route) => route.isFirst),
      onBack: () => Navigator.pop(context),

      onFilters: _openFilters,
      onSort: _openSort,

      // ✅ pinta botón filtros "activo"
      hasActiveFilters: _hasActiveFilters,

      // ✅ pinta botón ordenar "activo"
      hasActiveSort: (_query.ordering ?? "").trim().isNotEmpty,
    );
  }
}
