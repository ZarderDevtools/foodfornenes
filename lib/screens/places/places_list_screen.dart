// lib/screens/places/places_list_screen.dart

import 'package:flutter/material.dart';

import '../../models/place.dart';
import '../../models/place_list_query.dart';
import '../../repositories/categorization_repository.dart';
import '../../repositories/places_repository.dart';
import '../../services/api_client.dart';
import '../../services/places_service.dart';
import '../filters/filter_definition.dart';
import '../filters/filter_screen.dart';
import '../list/list_screen.dart';
import '../places/add_place/add_place_flow.dart';
import '../places/place_detail_screen.dart';
import "../sort/sort_definition.dart";
import "../sort/sort_screen.dart";

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
  CategorizationRepository? _catRepo;
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
      final catRepo = CategorizationRepository(api);

      if (!mounted) return;
      setState(() {
        _service = service;
        _catRepo = catRepo;
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
    final hasSearch = _query.search != null && _query.search!.trim().isNotEmpty;
    final hasMinRating = _query.minAvgRating != null;
    final hasMaxPrice = _query.maxAvgPricePp != null;
    final hasTags = _query.tagsIn != null && _query.tagsIn!.isNotEmpty;
    final hasAreas = _query.areasIn != null && _query.areasIn!.isNotEmpty;

    // placeTypeId y ordering NO cuentan como "filtro activo" visual
    // porque son parte del contexto del listado.
    return hasSearch || hasMinRating || hasMaxPrice || hasTags || hasAreas;
  }

  Future<void> _openFilters() async {
    // Cargamos tags y áreas antes de abrir los filtros
    List<FilterOption> tagOptions = const [];
    List<FilterOption> areaOptions = const [];
    final catRepo = _catRepo;
    if (catRepo != null) {
      try {
        final results = await Future.wait([
          catRepo.listTags(ordering: 'name', page: 1),
          catRepo.listAreas(ordering: 'name', page: 1),
        ]);
        tagOptions = (results[0] as List)
            .map((t) => FilterOption(value: t.id, label: t.name))
            .toList();
        areaOptions = (results[1] as List)
            .map((a) => FilterOption(value: a.id, label: a.name))
            .toList();
      } catch (_) {
        // Si falla la carga, los filtros dinámicos simplemente no se muestran
      }
    }

    final filters = <FilterDefinition<PlaceListQuery>>[
      // 1) Search
      FilterDefinition<PlaceListQuery>(
        id: 'search',
        label: 'Nombre',
        type: FilterType.text,
        getValue: (q) => q.search,
        setValue: (q, v) {
          final text = (v as String?)?.trim();
          return q.copyWith(search: (text != null && text.isNotEmpty) ? text : null);
        },
      ),

      // 2) Min avg rating
      FilterDefinition<PlaceListQuery>(
        id: 'min_avg_rating',
        label: 'Rating mínimo',
        type: FilterType.number,
        getValue: (q) => q.minAvgRating,
        setValue: (q, v) {
          final numVal = v is num ? v.toDouble() : null;
          return q.copyWith(minAvgRating: numVal);
        },
      ),

      // 4) Max avg price pp
      FilterDefinition<PlaceListQuery>(
        id: 'max_avg_price_pp',
        label: 'Precio máximo',
        type: FilterType.number,
        getValue: (q) => q.maxAvgPricePp,
        setValue: (q, v) {
          final numVal = v is num ? v.toDouble() : null;
          return q.copyWith(maxAvgPricePp: numVal);
        },
      ),

      // 5) Tags (multi-select dinámico, solo si hay tags disponibles)
      if (tagOptions.isNotEmpty)
        FilterDefinition<PlaceListQuery>(
          id: 'tags_in',
          label: 'Etiquetas',
          type: FilterType.multiSelect,
          options: tagOptions,
          getValue: (q) => q.tagsIn ?? const <String>[],
          setValue: (q, v) {
            final list = (v is List<String>) ? v : const <String>[];
            final cleaned = list.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
            return q.copyWith(tagsIn: cleaned.isEmpty ? null : cleaned);
          },
        ),

      // 6) Áreas (multi-select con búsqueda, solo si hay áreas disponibles)
      if (areaOptions.isNotEmpty)
        FilterDefinition<PlaceListQuery>(
          id: 'areas_in',
          label: 'Áreas',
          type: FilterType.multiSelectSearch,
          options: areaOptions,
          getValue: (q) => q.areasIn ?? const <String>[],
          setValue: (q, v) {
            final list = (v is List<String>) ? v : const <String>[];
            final cleaned = list.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
            return q.copyWith(areasIn: cleaned.isEmpty ? null : cleaned);
          },
        ),
    ];

    if (!mounted) return;

    final result = await Navigator.of(context).push<PlaceListQuery>(
      MaterialPageRoute(
        builder: (_) => FilterScreen<PlaceListQuery>(
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
          title: "Ordenar sitios",
          initialOrdering: _query.ordering,
          options: const [
            SortDefinition(label: "Nombre", field: "name", humanStringSort: true),
            SortDefinition(label: "Última visita", field: "last_visit_at"),
            SortDefinition(label: "Nota media", field: "avg_rating"),
            SortDefinition(label: "Precio medio por persona", field: "avg_price_pp"),
          ],
        ),
      ),
    );

    if (result == null) return;
    if (!result.applied) return;

    setState(() {
      _query = _query.copyWith(ordering: result.ordering);
    });
    final service = _service;
    if (service == null) return;
    await service.loadFirstPage(_query);
  }

  Future<void> _openAddPlace() async {
    final created = await Navigator.of(context).push<Place>(
      MaterialPageRoute(
        builder: (_) => AddPlaceFlow(
          // ✅ dejamos preseleccionado el tipo del listado actual
          defaultPlaceTypeId: widget.placeTypeId,
          defaultPlaceTypeLabel: widget.title,
        ),
      ),
    );

    if (created == null) return;

    // ✅ recargar listado para que aparezca el nuevo sitio
    final service = _service;
    if (service == null) return;

    setState(() {
      _query = _query.copyWith(page: 1);
    });

    await service.loadFirstPage(_query);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sitio creado: ${created.name}')),
    );
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

      fetchFirstPage: () => service.loadFirstPage(_query),
      fetchNextPage: () => service.loadNextPage(),
      hasNextPage: () => service.hasNext,

      getName: (p) => p.name,
      getTags: (p) => p.tags,
      getRatingAvg: (p) => p.avgRating,
      getPriceLevel: (p) => p.avgPricePp != null ? 'pp: ${p.avgPricePp!.round()}€' : null,

      onTapItem: (p) {
        Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PlaceDetailScreen(placeId: p.id),
          ),
        ).then((wasEdited) {
          if (wasEdited == true && mounted) {
            setState(() => _query = _query.copyWith(page: 1));
          }
        });
      },
      // ✅ Botón central: añadir sitio
      onCreate: _openAddPlace,

      onHome: () => Navigator.popUntil(context, (route) => route.isFirst),
      onBack: () => Navigator.pop(context),

      onFilters: _openFilters,
      onSort: _openSort,

      // pinta botón filtros "activo"
      hasActiveFilters: _hasActiveFilters,
      // pinta botón ordenar "activo"
      hasActiveSort: (_query.ordering ?? "").trim().isNotEmpty,

      emptyMessageOverride: 'No existen ${widget.title.toLowerCase()} actualmente',
    );
  }
}
