// lib/screens/places/places_list_screen.dart

import 'package:flutter/material.dart';

import '../../local/app_database.dart';
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

  final ApiClient apiClient;
  final AppDatabase db;

  const PlacesListScreen({
    super.key,
    required this.placeTypeId,
    required this.title,
    this.ordering,
    required this.apiClient,
    required this.db,
  });

  @override
  State<PlacesListScreen> createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {
  PlacesService? _service;
  PlacesRepository? _repo;
  CategorizationRepository? _catRepo;
  late PlaceListQuery _query;

  bool _ready = false;
  String? _initError;
  List<Place> _allCached = const [];
  List<Place>? _cachedItems;
  Map<String, String> _tagIdToName = const {};

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
      final repo = PlacesRepository(widget.apiClient, dao: widget.db.placesDao);
      final service = PlacesService(repo);
      final catRepo = CategorizationRepository(
        widget.apiClient,
        areasDao: widget.db.areasDao,
        tagsDao: widget.db.tagsDao,
      );

      final cached = await repo.getCachedPlaces();
      _allCached = cached ?? const [];
      final filtered = _applyLocalFilter(_allCached, _query);

      if (!mounted) return;
      setState(() {
        _service = service;
        _repo = repo;
        _catRepo = catRepo;
        // null = no cache at all → ListScreen muestra spinner inicial.
        // [] = hay caché pero el filtro devuelve vacío → ListScreen muestra estado vacío + refresh silencioso.
        _cachedItems = _allCached.isNotEmpty ? filtered : null;
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

  List<Place> _applyLocalFilter(List<Place> all, PlaceListQuery q) {
    var result = all.where((p) {
      if (q.placeTypeId != null && p.placeTypeId != q.placeTypeId) return false;
      final search = q.search?.trim().toLowerCase();
      if (search != null && search.isNotEmpty && !p.name.toLowerCase().contains(search)) {
        return false;
      }
      final minRating = q.minAvgRating;
      if (minRating != null) {
        final r = p.avgRating;
        if (r == null || r < minRating) return false;
      }
      final maxPrice = q.maxAvgPricePp;
      if (maxPrice != null) {
        final pr = p.avgPricePp;
        if (pr == null || pr > maxPrice) return false;
      }
      final areas = q.areasIn;
      if (areas != null && areas.isNotEmpty) {
        if (p.areaId == null || !areas.contains(p.areaId)) return false;
      }
      final selectedTagIds = q.tagsIn;
      if (selectedTagIds != null && selectedTagIds.isNotEmpty) {
        final resolvedNames = selectedTagIds
            .map((id) => _tagIdToName[id])
            .whereType<String>()
            .toSet();
        // OR: place must have at least one selected tag name.
        // If no IDs resolve (cache incomplete), skip filter to avoid over-filtering.
        if (resolvedNames.isNotEmpty) {
          if (!p.tags.any((name) => resolvedNames.contains(name))) return false;
        }
      }
      return true;
    }).toList();

    final ordering = q.ordering;
    if (ordering != null && ordering.trim().isNotEmpty) {
      final desc = ordering.startsWith('-');
      final field = desc ? ordering.substring(1) : ordering;
      result.sort((a, b) {
        int cmp;
        switch (field) {
          case 'name':
            cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          case 'avg_rating':
            final ra = a.avgRating;
            final rb = b.avgRating;
            if (ra == null && rb == null) { cmp = 0; }
            else if (ra == null) { return 1; }
            else if (rb == null) { return -1; }
            else { cmp = ra.compareTo(rb); }
          case 'last_visit_at':
            final la = a.lastVisitAt;
            final lb = b.lastVisitAt;
            if (la == null && lb == null) { cmp = 0; }
            else if (la == null) { return 1; }
            else if (lb == null) { return -1; }
            else { cmp = la.compareTo(lb); }
          case 'avg_price_pp':
            final pa = a.avgPricePp;
            final pb = b.avgPricePp;
            if (pa == null && pb == null) { cmp = 0; }
            else if (pa == null) { return 1; }
            else if (pb == null) { return -1; }
            else { cmp = pa.compareTo(pb); }
          default:
            cmp = 0;
        }
        return desc ? -cmp : cmp;
      });
    }

    return result;
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

  Future<void> _refreshCatalogCache() async {
    final catRepo = _catRepo;
    if (catRepo == null) return;
    try {
      await Future.wait([
        catRepo.listAreas(ordering: 'name', page: 1),
        catRepo.listTags(ordering: 'name', page: 1),
      ]);
    } catch (_) {}
  }

  /// Refresca [_allCached] desde la BD local para incluir sitios que la API
  /// haya descargado y cacheado después del arranque de la pantalla.
  Future<void> _refreshLocalCache() async {
    final repo = _repo;
    if (repo == null) return;
    try {
      final fresh = await repo.getCachedPlaces();
      if (fresh != null) _allCached = fresh;
    } catch (_) {}
  }

  Future<void> _openFilters() async {
    // Refrescar caché de sitios para que el filtro local vea los datos que la
    // API haya descargado desde que se abrió la pantalla.
    await _refreshLocalCache();

    List<FilterOption> tagOptions = const [];
    List<FilterOption> areaOptions = const [];
    final catRepo = _catRepo;
    if (catRepo != null) {
      // 1. Carga desde caché local (rápido, sin red)
      final cachedAreas = await catRepo.getCachedAreas();
      final cachedTags = await catRepo.getCachedTags();
      if (cachedAreas != null) {
        areaOptions = cachedAreas
            .map((a) => FilterOption(value: a.id, label: a.name))
            .toList();
      }
      if (cachedTags != null) {
        tagOptions = cachedTags
            .map((t) => FilterOption(value: t.id, label: t.name))
            .toList();
      }

      if (areaOptions.isEmpty && tagOptions.isEmpty) {
        // 2. Sin caché: intenta API de forma bloqueante (primera vez)
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
      } else {
        // 3. Hay caché: refresca en background para la próxima vez
        _refreshCatalogCache();
      }
    }

    if (tagOptions.isNotEmpty) {
      _tagIdToName = {for (final opt in tagOptions) opt.value: opt.label};
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
      _cachedItems = _applyLocalFilter(_allCached, _query);
    });
  }

  Future<void> _openSort() async {
    await _refreshLocalCache();
    if (!mounted) return;

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
      _cachedItems = _applyLocalFilter(_allCached, _query);
    });
  }

  Future<void> _openAddPlace() async {
    final created = await Navigator.of(context).push<Place>(
      MaterialPageRoute(
        builder: (_) => AddPlaceFlow(
          api: widget.apiClient,
          db: widget.db,
          defaultPlaceTypeId: widget.placeTypeId,
          defaultPlaceTypeLabel: widget.title,
        ),
      ),
    );

    if (!mounted || created == null) return;

    // Reload from local cache so the new place (online or pending) appears
    // immediately. ListScreen will do a background API refresh via didUpdateWidget.
    final fresh = await _repo?.getCachedPlaces();
    if (!mounted) return;

    _allCached = fresh ?? const [];
    setState(() {
      _query = _query.copyWith(page: 1);
      _cachedItems = _applyLocalFilter(_allCached, _query);
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sitio guardado: ${created.name}')),
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
      initialItems: _cachedItems,

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
            builder: (_) => PlaceDetailScreen(placeId: p.id, initialPlace: p, db: widget.db),
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
