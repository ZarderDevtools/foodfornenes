// lib/screens/places/add_place/add_place_flow.dart

import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../local/app_database.dart';
import '../../../models/area.dart';
import '../../../models/place.dart';
import '../../../models/place_type.dart';
import '../../../models/tag.dart';
import '../../areas/add_area/add_area_flow.dart';
import '../../place_types/add_place_type/add_place_type_flow.dart';
import '../../tags/add_tag/add_tag_flow.dart';
import '../../../repositories/categorization_repository.dart';
import '../../../screens/add_record/add_record_config.dart';
import '../../../screens/add_record/add_record_screen.dart';
import '../../../screens/add_record/form_values.dart';
import '../../../services/api_client.dart';
import '../../../widgets/form_fields/field_spec.dart';
import '../../../widgets/form_fields/multi_relation_field_spec.dart';
import '../../../widgets/form_fields/relation_field_spec.dart';
import '../../../widgets/form_fields/text_field_spec.dart';

class AddPlaceFlow extends StatefulWidget {
  final ApiClient api;
  final AppDatabase db;

  /// Si vienes de "Restaurantes" / "Carnicerías", etc.
  /// puedes pasar el placeType por defecto para que aparezca ya seleccionado.
  final String? defaultPlaceTypeId;
  final String? defaultPlaceTypeLabel;

  const AddPlaceFlow({
    super.key,
    required this.api,
    required this.db,
    this.defaultPlaceTypeId,
    this.defaultPlaceTypeLabel,
  });

  @override
  State<AddPlaceFlow> createState() => _AddPlaceFlowState();
}

class _AddPlaceFlowState extends State<AddPlaceFlow> {
  bool _loading = true;
  bool _noLocalData = false;
  String? _error;

  late final CategorizationRepository _catRepo;

  String? _resolvedDefaultTypeId;
  String? _resolvedDefaultTypeLabel;

  static const _kPlaceTypeKey = 'place_type_id';

  @override
  void initState() {
    super.initState();
    _catRepo = CategorizationRepository(
      widget.api,
      dao: widget.db.placeTypesDao,
      areasDao: widget.db.areasDao,
      tagsDao: widget.db.tagsDao,
    );
    _init();
  }

  Future<void> _init() async {
    List<PlaceType> types = const [];

    // Try API first; fall back to local cache on any network/server failure.
    try {
      types = await _catRepo.listPlaceTypes(
        isActive: true,
        ordering: 'name',
        page: 1,
      );
    } catch (_) {
      final cached = await _catRepo.getCachedPlaceTypes();
      types = cached ?? const [];
    }

    if (!mounted) return;

    if (types.isEmpty) {
      setState(() {
        _noLocalData = true;
        _loading = false;
      });
      return;
    }

    String? defId = widget.defaultPlaceTypeId;
    String? defLabel = widget.defaultPlaceTypeLabel;

    if (defId != null && (defLabel == null || defLabel.trim().isEmpty)) {
      final match = types.cast<PlaceType?>().firstWhere(
            (t) => t?.id == defId,
            orElse: () => null,
          );
      defLabel = match?.name;
    }

    setState(() {
      _resolvedDefaultTypeId = defId;
      _resolvedDefaultTypeLabel = defLabel;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6FBFF),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_noLocalData) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6FBFF),
        appBar: AppBar(
          title: const Text('Añadir sitio'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded,
                    size: 48, color: Color(0xFF9E9E9E)),
                const SizedBox(height: 16),
                const Text(
                  'Sin datos locales disponibles',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Necesitas conexión para abrir este formulario por primera vez.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF757575)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Volver'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _loading = true;
                          _noLocalData = false;
                        });
                        _init();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6FBFF),
        appBar: AppBar(
          title: const Text('Añadir sitio'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
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
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _loading = true;
                      _error = null;
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

    final initial = <String, Object?>{};
    if (_resolvedDefaultTypeId != null) {
      initial[_kPlaceTypeKey] = _resolvedDefaultTypeId;
      if (_resolvedDefaultTypeLabel != null &&
          _resolvedDefaultTypeLabel!.trim().isNotEmpty) {
        initial['${_kPlaceTypeKey}__label'] =
            _resolvedDefaultTypeLabel!.trim();
      }
    }

    final config = AddRecordConfig(
      title: 'Añadir sitio',
      initialValues: initial,
      fields: [
        // 1) Nombre (obligatorio)
        TextFieldSpec(
          key: 'name',
          label: 'Nombre',
          required: true,
          requiredMessage: 'El nombre es obligatorio.',
          placeholder: 'Ej: La Tagliatella',
          validator: FieldValidators.minLen(2, message: 'Mínimo 2 caracteres.'),
        ),

        // 2) Tipo (placeType) — obligatorio, con fallback a caché
        RelationFieldSpec<PlaceType>(
          key: _kPlaceTypeKey,
          label: 'Tipo',
          required: true,
          requiredMessage: 'Selecciona un tipo.',
          placeholder: 'Pulsa para buscar un tipo',
          searchHint: 'Buscar tipo…',
          fetchItems: (search, values) async {
            final s = search.trim();
            try {
              return await _catRepo.listPlaceTypes(
                isActive: true,
                search: s.isEmpty ? null : s,
                ordering: 'name',
                page: 1,
              );
            } catch (_) {
              final cached = await _catRepo.getCachedPlaceTypes() ?? [];
              if (s.isEmpty) return cached;
              return cached
                  .where((t) =>
                      t.name.toLowerCase().contains(s.toLowerCase()))
                  .toList();
            }
          },
          getId: (pt) => pt.id,
          getLabel: (pt) => pt.name,
          onCreate: (values) => Navigator.of(context).push<PlaceType>(
            MaterialPageRoute(builder: (_) => const AddPlaceTypeFlow()),
          ),
        ),

        // 3) Ubicación (area) — opcional, con fallback a caché
        RelationFieldSpec<Area>(
          key: 'area_id',
          label: 'Ubicación',
          placeholder: 'Pulsa para buscar una ubicación',
          searchHint: 'Buscar ubicación…',
          fetchItems: (search, values) async {
            final s = search.trim();
            try {
              return await _catRepo.listAreas(
                search: s.isEmpty ? null : s,
                ordering: 'name',
                page: 1,
              );
            } catch (_) {
              final cached = await _catRepo.getCachedAreas() ?? [];
              if (s.isEmpty) return cached;
              return cached
                  .where((a) =>
                      a.name.toLowerCase().contains(s.toLowerCase()))
                  .toList();
            }
          },
          getId: (area) => area.id,
          getLabel: (area) => area.name,
          onCreate: (values) => Navigator.of(context).push<Area>(
            MaterialPageRoute(builder: (_) => const AddAreaFlow()),
          ),
        ),

        // 4) Descripción (opcional)
        const TextFieldSpec(
          key: 'description',
          label: 'Descripción',
          placeholder: 'Opcional…',
          multiline: true,
          maxLines: 5,
        ),

        // 5) URL (opcional) con validación
        TextFieldSpec(
          key: 'url',
          label: 'URL',
          placeholder: 'https://… (opcional)',
          validator: (value, values) {
            if (value == null) return null;
            if (value is! String) return 'URL inválida.';
            final s = value.trim();
            if (s.isEmpty) return null;
            final uri = Uri.tryParse(s);
            final ok = uri != null &&
                uri.hasScheme &&
                (uri.scheme == 'http' || uri.scheme == 'https') &&
                uri.host.isNotEmpty;
            return ok ? null : 'Debe ser una URL válida (http/https).';
          },
        ),

        // 6) Tags — opcional, con fallback a caché
        MultiRelationFieldSpec<Tag>(
          key: 'tags',
          label: 'Etiquetas',
          placeholder: 'Añadir etiqueta…',
          searchHint: 'Buscar etiqueta…',
          fetchItems: (search, _) async {
            final s = search.trim();
            try {
              return await _catRepo.listTags(
                search: s.isEmpty ? null : s,
                ordering: 'name',
                page: 1,
              );
            } catch (_) {
              final cached = await _catRepo.getCachedTags() ?? [];
              if (s.isEmpty) return cached;
              return cached
                  .where((t) =>
                      t.name.toLowerCase().contains(s.toLowerCase()))
                  .toList();
            }
          },
          getId: (tag) => tag.id,
          getLabel: (tag) => tag.name,
          onCreate: (values) => Navigator.of(context).push<Tag>(
            MaterialPageRoute(builder: (_) => const AddTagFlow()),
          ),
        ),
      ],

      onSubmit: (AddFormValues values) async {
        final name = values.get<String>('name')?.trim();
        final placeTypeId = values.get<String>(_kPlaceTypeKey);
        final areaId = values.get<String>('area_id');
        final description = values.get<String>('description')?.trim();
        final url = values.get<String>('url')?.trim();
        final tagIds =
            (values['tags'] as List?)?.cast<String>() ?? <String>[];

        final payload = <String, dynamic>{
          'name': name,
          'place_type': placeTypeId,
          if (areaId != null && areaId.isNotEmpty) 'area': areaId,
          'price_range': '€',
          if (description != null && description.isNotEmpty)
            'description': description,
          if (url != null && url.isNotEmpty) 'url': url,
          'tags': tagIds,
        };

        // ── Online path ────────────────────────────────────────────────────
        try {
          final res =
              await widget.api.post('/api/v1/places/', data: payload);
          final data = res.data;
          if (data is Map<String, dynamic>) {
            final created = Place.fromJson(data);
            await widget.db.placesDao.upsertPlace(_toCompanion(created));
            if (!context.mounted) return;
            Navigator.of(context).pop(created);
            return;
          }
          // Unexpected response format — fall through to offline path.
        } on ApiException catch (e) {
          final code = e.statusCode;
          if (code != null && code >= 400 && code < 500) {
            // Definitive client error: show in form, do NOT save offline.
            throw Exception(e.message);
          }
          // 5xx / null statusCode / timeout: fall through to offline path.
        } catch (_) {
          // Network error / unexpected: fall through to offline path.
        }

        // ── Offline fallback ───────────────────────────────────────────────
        final localId =
            'local_place_${DateTime.now().microsecondsSinceEpoch}';
        final now = DateTime.now();

        // Resolve display names from local cache so the detail screen
        // can show them without an API call.
        String? areaName;
        if (areaId != null && areaId.isNotEmpty) {
          final areas = await _catRepo.getCachedAreas() ?? <Area>[];
          areaName = areas
              .cast<Area?>()
              .firstWhere((a) => a?.id == areaId, orElse: () => null)
              ?.name;
        }

        final tagNames = <String>[];
        if (tagIds.isNotEmpty) {
          final tags = await _catRepo.getCachedTags() ?? <Tag>[];
          final tagMap = {for (final t in tags) t.id: t.name};
          tagNames.addAll(
              tagIds.map((id) => tagMap[id]).whereType<String>());
        }

        final localPlace = Place(
          id: localId,
          householdId: '',
          name: name ?? '',
          placeTypeId: placeTypeId ?? '',
          areaId: (areaId != null && areaId.isNotEmpty) ? areaId : null,
          areaName: areaName,
          priceRange: '€',
          description: description ?? '',
          url: url ?? '',
          avgRating: null,
          avgPricePp: null,
          visitsCount: 0,
          lastVisitAt: null,
          tags: tagNames,
          tagIds: tagIds,
          createdAt: now,
          updatedAt: now,
        );

        await widget.db.transaction(() async {
          await widget.db.placesDao.upsertPlace(
            _toCompanion(localPlace, syncStatus: 'pending_create'),
          );
          await widget.db.syncQueueDao.insertPending(
            entityType: 'place',
            operation: 'create',
            localEntityId: localId,
            payloadJson: jsonEncode(payload),
          );
        });

        // Pop immediately so AddRecordScreen.maybePop is a no-op.
        if (context.mounted) Navigator.of(context).pop(localPlace);
      },
    );

    return AddRecordScreen(config: config);
  }

  PlacesCacheCompanion _toCompanion(
    Place p, {
    String syncStatus = 'synced',
  }) =>
      PlacesCacheCompanion(
        id: Value(p.id),
        householdId: Value(p.householdId),
        name: Value(p.name),
        placeTypeId: Value(p.placeTypeId),
        areaId: Value(p.areaId),
        areaName: Value(p.areaName),
        priceRange: Value(p.priceRange),
        description: Value(p.description),
        url: Value(p.url),
        avgRating: Value(p.avgRating),
        avgPricePp: Value(p.avgPricePp),
        visitsCount: Value(p.visitsCount),
        lastVisitAt: Value(p.lastVisitAt),
        tags: Value(p.tags),
        syncStatus: Value(syncStatus),
        createdAt: Value(p.createdAt),
        updatedAt: Value(p.updatedAt),
      );
}
