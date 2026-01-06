// lib/screens/places/places_list_screen.dart

import 'package:flutter/material.dart';

import '../../models/place.dart';
import '../../models/place_list_query.dart';
import '../../repositories/places_repository.dart';
import '../../services/api_client.dart';
import '../../services/places_service.dart';
import '../list/list_screen.dart';

class PlacesListScreen extends StatefulWidget {
  /// UUID del PlaceType base (ej: restaurante).
  final String placeTypeId;

  /// Título de la pantalla (ej: "Restaurantes")
  final String title;

  /// ordering (DRF) e.g. "-avg_rating"
  final String? ordering;

  const PlacesListScreen({
    super.key,
    required this.placeTypeId,
    required this.title,
    this.ordering,
  });

  @override
  State<PlacesListScreen> createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {
  PlacesService? _service;
  late PlaceListQuery _query;

  bool _ready = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _query = PlaceListQuery(
      placeTypeId: widget.placeTypeId,
      ordering: widget.ordering,
      page: 1,
    );
    _init();
  }

  Future<void> _init() async {
    try {
      final api = await ApiClient.create();
      final repo = PlacesRepository(api);
      final service = PlacesService(repo);

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

    return ListScreen<Place>(
      title: widget.title,

      // ✅ Modo paginado (scroll infinito):
      fetchFirstPage: () => service.loadFirstPage(_query),
      fetchNextPage: () => service.loadNextPage(),
      hasNextPage: () => service.hasNext,

      // ✅ Getters:
      getName: (p) => p.name,
      getTags: (p) => p.tags,
      getRatingAvg: (p) => p.avgRating,
      getPriceLevel: (p) => p.priceRange,

      // ✅ Acciones (de momento básicas):
      onTapItem: (p) {},
      onCreate: () {},
      onHome: () => Navigator.popUntil(context, (route) => route.isFirst),
      onBack: () => Navigator.pop(context),

      onFilters: null,
      onSort: null,

      emptyMessageOverride: 'No existen ${widget.title.toLowerCase()} actualmente',
    );
  }
}
