// lib/screens/foods/add_food_visit/add_food_visit_flow.dart

import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../local/app_database.dart';
import '../../../models/food_visit.dart';
import '../../../models/place.dart';
import '../../../models/place_list_query.dart';
import '../../../models/place_type.dart';
import '../../../models/visit.dart';
import '../../../repositories/categorization_repository.dart';
import '../../../repositories/places_repository.dart';
import '../../../repositories/visits_repository.dart';
import '../../../screens/add_record/add_record_config.dart';
import '../../../screens/add_record/add_record_screen.dart';
import '../../../screens/add_record/form_values.dart';
import '../../../services/api_client.dart';
import '../../../widgets/form_fields/choice_field_spec.dart';
import '../../../widgets/form_fields/field_spec.dart';
import '../../../widgets/form_fields/number_field_spec.dart';
import '../../../widgets/form_fields/relation_field_spec.dart';
import '../../../widgets/form_fields/text_field_spec.dart';
import '../../places/add_place/add_place_flow.dart';

class AddFoodVisitFlow extends StatefulWidget {
  final String foodId;
  final String foodName;
  final AppDatabase db;

  const AddFoodVisitFlow({
    super.key,
    required this.foodId,
    required this.foodName,
    required this.db,
  });

  @override
  State<AddFoodVisitFlow> createState() => _AddFoodVisitFlowState();
}

class _AddFoodVisitFlowState extends State<AddFoodVisitFlow> {
  bool _loading = true;
  String? _error;
  bool _offlineEmpty = false;

  ApiClient? _api;
  List<PlaceType> _placeTypes = const [];
  String? _defaultPlaceTypeId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    ApiClient? api;
    try {
      api = await ApiClient.create();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
      return;
    }

    try {
      final catRepo = CategorizationRepository(api, dao: widget.db.placeTypesDao);

      final cached = await catRepo.getCachedPlaceTypes();
      if (cached != null && cached.isNotEmpty) {
        final rest = _findRestauranteType(cached);
        if (!mounted) return;
        setState(() {
          _api = api;
          _placeTypes = cached;
          _defaultPlaceTypeId = rest?.id ?? (cached.isNotEmpty ? cached.first.id : null);
          _loading = false;
        });
        _backgroundRefreshPlaceTypes(catRepo);
        return;
      }

      final types = await catRepo.listPlaceTypes(isActive: true, ordering: 'name', page: 1);
      final rest = _findRestauranteType(types);
      if (!mounted) return;
      setState(() {
        _api = api;
        _placeTypes = types;
        _defaultPlaceTypeId = rest?.id ?? (types.isNotEmpty ? types.first.id : null);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _api = api;
        _placeTypes = [];
        _offlineEmpty = true;
        _loading = false;
      });
    }
  }

  PlaceType? _findRestauranteType(List<PlaceType> types) =>
      types.cast<PlaceType?>().firstWhere(
        (t) => (t?.name ?? '').trim().toLowerCase() == 'restaurante',
        orElse: () => null,
      );

  void _backgroundRefreshPlaceTypes(CategorizationRepository catRepo) async {
    try {
      await catRepo.listPlaceTypes(isActive: true, ordering: 'name', page: 1);
    } catch (_) {}
  }

  String? _placeTypeNameById(String? id) {
    if (id == null) return null;
    for (final pt in _placeTypes) {
      if (pt.id == id) return pt.name;
    }
    return null;
  }

  // visitPayload == null means we're reusing an existing backend Visit (backendVisitId is set).
  // In that case no local pending Visit is created and localVisitId is omitted from the payload.
  Future<void> _saveLocalPending({
    required String placeId,
    required String? placeName,
    required String date,
    required double? rating,
    required double? pricePaid,
    required String comment,
    required Map<String, dynamic>? visitPayload,
    required Map<String, dynamic> foodVisitPayload,
    required String? backendVisitId,
  }) async {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final localFoodVisitId = 'local_food_visit_$ts';
    final now = DateTime.now();

    // When reusing an existing Visit (backendVisitId set, no visitPayload to create),
    // we skip creating a local Visit placeholder entirely.
    final bool reuseExisting = backendVisitId != null && visitPayload == null;
    final String? localVisitId = reuseExisting ? null : 'local_visit_$ts';
    final String fvVisitId = localVisitId ?? backendVisitId!;

    await widget.db.transaction(() async {
      if (localVisitId != null) {
        await widget.db.visitsDao.upsertVisit(VisitsCacheCompanion(
          id: Value(localVisitId),
          placeId: Value(placeId),
          authorId: const Value(''),
          date: Value(DateTime.parse(date)),
          rating: Value(rating),
          pricePp: const Value(null),
          comment: const Value(''),
          syncStatus: const Value('pending_create'),
          createdAt: Value(now),
        ));
      }

      await widget.db.foodVisitsDao.upsertFoodVisit(FoodVisitsCacheCompanion(
        id: Value(localFoodVisitId),
        visitId: Value(fvVisitId),
        foodId: Value(widget.foodId),
        placeName: Value(placeName),
        date: Value(DateTime.parse(date)),
        rating: Value(rating),
        pricePp: Value(pricePaid),
        comment: Value(comment),
        syncStatus: const Value('pending_create'),
        createdAt: Value(now),
      ));

      await widget.db.syncQueueDao.insertPending(
        entityType: 'food_visit',
        operation: 'create',
        localEntityId: localFoodVisitId,
        payloadJson: jsonEncode({
          'localVisitId': localVisitId,
          'localFoodVisitId': localFoodVisitId,
          'backendVisitId': backendVisitId,
          'visitPayload': visitPayload,
          'foodVisitPayload': foodVisitPayload,
        }),
      );
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

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6FBFF),
        appBar: AppBar(
          title: const Text('Añadir visita'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFF6FBFF),
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

    if (_offlineEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6FBFF),
        appBar: AppBar(
          title: const Text('Añadir visita'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFF6FBFF),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 36, color: Colors.grey),
                const SizedBox(height: 10),
                const Text(
                  'Sin datos locales disponibles.\nConéctate al menos una vez para poder usar esta pantalla sin red.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Volver'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _loading = true;
                          _offlineEmpty = false;
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

    final api = _api!;
    final placesRepo = PlacesRepository(api, dao: widget.db.placesDao);
    final visitsRepo = VisitsRepository(api, visitsDao: widget.db.visitsDao);

    final placeTypeOptions = _placeTypes
        .map((pt) => ChoiceItem<String>(value: pt.id, label: pt.name))
        .toList();

    final config = AddRecordConfig(
      title: 'Añadir visita — ${widget.foodName}',
      initialValues: {
        if (_defaultPlaceTypeId != null) 'place_type_id': _defaultPlaceTypeId,
      },
      fields: [
        // 1) Tipo (PlaceType)
        ChoiceFieldSpec<String>(
          key: 'place_type_id',
          label: 'Tipo',
          required: true,
          requiredMessage: 'Selecciona un tipo.',
          placeholder: 'Selecciona un tipo',
          options: placeTypeOptions,
          onChanged: (_, values) {
            values.setValue('place_id', null);
            values.setValue('place_id__label', null);
          },
        ),

        // 2) Sitio (Place) filtrado por tipo
        RelationFieldSpec<Place>(
          key: 'place_id',
          label: 'Sitio',
          required: true,
          requiredMessage: 'Selecciona un sitio.',
          placeholder: 'Pulsa para buscar un sitio',
          searchHint: 'Buscar sitio…',
          disabledMessage: 'Selecciona un tipo primero',
          isEnabled: (values) {
            final typeId = values.get<String>('place_type_id');
            return typeId != null && typeId.trim().isNotEmpty;
          },
          fetchItems: (search, values) async {
            final typeId = values.get<String>('place_type_id');
            if (typeId == null || typeId.trim().isEmpty) return const <Place>[];

            final q = PlaceListQuery(
              placeTypeId: typeId,
              search: search.trim().isEmpty ? null : search.trim(),
              ordering: 'name',
              page: 1,
            );

            try {
              final paged = await placesRepo.fetchPlaces(q);
              return paged.results;
            } catch (_) {
              return placesRepo.searchCachedPlaces(typeId, search);
            }
          },
          getId: (p) => p.id,
          getLabel: (p) => p.name,
          onCreate: (values) async {
            final currentTypeId = values.get<String>('place_type_id');
            final currentTypeLabel = _placeTypeNameById(currentTypeId);

            final created = await Navigator.of(context).push<Place>(
              MaterialPageRoute(
                builder: (_) => AddPlaceFlow(
                  api: _api!,
                  db: widget.db,
                  defaultPlaceTypeId: currentTypeId,
                  defaultPlaceTypeLabel: currentTypeLabel,
                ),
              ),
            );

            if (created == null) return null;

            values.setValue('place_type_id', created.placeTypeId);
            values.setValue('place_id', null);
            values.setValue('place_id__label', null);

            return created;
          },
        ),

        // 3) Rating (1..10) obligatorio
        NumberFieldSpec(
          key: 'rating',
          label: 'Rating (1 a 10)',
          required: true,
          requiredMessage: 'El rating es obligatorio.',
          placeholder: 'Ej: 8.5',
          allowDecimal: true,
          validator: (value, values) {
            final msgNum =
                FieldValidators.decimalNumber(message: 'Debe ser un número.')(value, values);
            if (msgNum != null) return msgNum;
            return FieldValidators.numberRange(
              min: 1,
              max: 10,
              message: 'Debe estar entre 1 y 10.',
            )(value, values);
          },
        ),

        // 4) Precio pagado (opcional)
        NumberFieldSpec(
          key: 'price_paid',
          label: 'Precio pagado',
          placeholder: 'Ej: 12.50',
          allowDecimal: true,
          validator: (value, values) {
            if (value == null) return null;
            if (value is String && value.trim().isEmpty) return null;
            final msgNum =
                FieldValidators.decimalNumber(message: 'Debe ser un número.')(value, values);
            if (msgNum != null) return msgNum;
            return FieldValidators.nonNegative(message: 'No puede ser negativo.')(value, values);
          },
        ),

        // 5) Comentario (opcional)
        const TextFieldSpec(
          key: 'comment',
          label: 'Comentario',
          placeholder: 'Opcional…',
          multiline: true,
          maxLines: 6,
        ),
      ],
      onSubmit: (AddFormValues values) async {
        final placeId = values.get<String>('place_id');
        final placeName = values.get<String>('place_id__label');
        final ratingRaw = values['rating'];
        final priceRaw = values['price_paid'];
        final comment = values.get<String>('comment');

        double? toDouble(Object? v) {
          if (v == null) return null;
          if (v is num) return v.toDouble();
          if (v is String) {
            final s = v.trim();
            if (s.isEmpty) return null;
            return double.tryParse(s.replaceAll(',', '.'));
          }
          return null;
        }

        final rating = toDouble(ratingRaw);
        final pricePaid = toDouble(priceRaw);
        final commentTrimmed = comment?.trim() ?? '';

        final now = DateTime.now();
        final date = '${now.year.toString().padLeft(4, '0')}-'
            '${now.month.toString().padLeft(2, '0')}-'
            '${now.day.toString().padLeft(2, '0')}';

        final visitPayload = <String, dynamic>{
          'place': placeId,
          'date': date,
          'rating': rating,
        };

        final foodVisitPayload = <String, dynamic>{
          'food': widget.foodId,
          'rating': rating,
          if (pricePaid != null) 'price_paid': pricePaid,
          if (commentTrimmed.isNotEmpty) 'comment': commentTrimmed,
        };

        // ── Step 0: Resolve the Visit to link ────────────────────────────────
        // If the Place already has a Visit, reuse it instead of creating a new one.
        String? existingVisitId;
        if (placeId != null) {
          try {
            final latest = await visitsRepo.fetchLatestPlaceVisit(placeId);
            existingVisitId = latest?.id;
          } catch (_) {
            // Network/5xx/backend dormido: fall back to local cache.
            final cached =
                await widget.db.visitsDao.getLatestSyncedVisitByPlace(placeId);
            existingVisitId = cached?.id;
          }
        }

        if (existingVisitId != null) {
          // ── Path A: existing Visit → only POST FoodVisit ──────────────────
          Map<String, dynamic>? fvResponseData;
          try {
            final fvPost = Map<String, dynamic>.from(foodVisitPayload)
              ..['visit'] = existingVisitId;
            final fvRes = await api.post('/api/v1/visit-foods/', data: fvPost);
            if (fvRes.data is Map<String, dynamic>) {
              fvResponseData = fvRes.data as Map<String, dynamic>;
            }
          } on ApiException catch (e) {
            final code = e.statusCode;
            if (code != null && code >= 400 && code < 500) {
              throw ApiException(
                statusCode: e.statusCode,
                message: '[visit-foods] ${e.message} — ${e.data}',
                data: e.data,
              );
            }
            // Temporary error: save offline, Visit already exists on backend.
            if (placeId != null) {
              await _saveLocalPending(
                placeId: placeId,
                placeName: placeName,
                date: date,
                rating: rating,
                pricePaid: pricePaid,
                comment: commentTrimmed,
                visitPayload: null,
                foodVisitPayload: Map<String, dynamic>.from(foodVisitPayload)
                  ..['visit'] = existingVisitId,
                backendVisitId: existingVisitId,
              );
            }
            if (context.mounted) Navigator.of(context).pop(true);
            return;
          }

          // FoodVisit POST succeeded: cache result.
          try {
            if (fvResponseData != null) {
              final foodVisit = FoodVisit.fromJson(fvResponseData);
              await widget.db.foodVisitsDao
                  .upsertFoodVisit(FoodVisitsCacheCompanion(
                id: Value(foodVisit.id),
                visitId: Value(foodVisit.visitId),
                foodId: Value(foodVisit.foodId),
                placeName: Value(foodVisit.placeName),
                date: Value(foodVisit.date),
                rating: Value(foodVisit.rating),
                pricePp: Value(foodVisit.pricePp),
                comment: Value(foodVisit.comment),
                syncStatus: const Value('synced'),
                createdAt: Value(foodVisit.createdAt),
              ));
            }
          } catch (_) {}

          if (context.mounted) Navigator.of(context).pop(true);
          return;
        }

        // ── Path B: no Visit exists → POST Visit, then POST FoodVisit ────────

        // Step 1: POST Visit
        late String backendVisitId;
        late Map<String, dynamic> visitResponseData;
        try {
          final visitRes =
              await api.post('/api/v1/visits/', data: visitPayload);
          final visitData = visitRes.data;
          if (visitData is! Map<String, dynamic>) {
            throw Exception('Respuesta inesperada al crear la visita.');
          }
          backendVisitId = (visitData['id'] ?? '').toString();
          if (backendVisitId.isEmpty) {
            throw Exception('El servidor no devolvió el ID de la visita.');
          }
          visitResponseData = visitData;
        } on ApiException catch (e) {
          final code = e.statusCode;
          if (code != null && code >= 400 && code < 500) {
            throw ApiException(
              statusCode: e.statusCode,
              message: '[visits] ${e.message} — ${e.data}',
              data: e.data,
            );
          }
          if (placeId != null) {
            await _saveLocalPending(
              placeId: placeId,
              placeName: placeName,
              date: date,
              rating: rating,
              pricePaid: pricePaid,
              comment: commentTrimmed,
              visitPayload: visitPayload,
              foodVisitPayload: foodVisitPayload,
              backendVisitId: null,
            );
          }
          if (context.mounted) Navigator.of(context).pop(true);
          return;
        }

        // Step 2: POST FoodVisit
        Map<String, dynamic>? fvResponseData;
        try {
          final fvPost = Map<String, dynamic>.from(foodVisitPayload)
            ..['visit'] = backendVisitId;
          final fvRes = await api.post('/api/v1/visit-foods/', data: fvPost);
          if (fvRes.data is Map<String, dynamic>) {
            fvResponseData = fvRes.data as Map<String, dynamic>;
          }
        } on ApiException catch (e) {
          final code = e.statusCode;
          if (code != null && code >= 400 && code < 500) {
            throw ApiException(
              statusCode: e.statusCode,
              message: '[visit-foods] ${e.message} — ${e.data}',
              data: e.data,
            );
          }
          // Visit already created on backend: save checkpoint.
          if (placeId != null) {
            await _saveLocalPending(
              placeId: placeId,
              placeName: placeName,
              date: date,
              rating: rating,
              pricePaid: pricePaid,
              comment: commentTrimmed,
              visitPayload: visitPayload,
              foodVisitPayload: foodVisitPayload,
              backendVisitId: backendVisitId,
            );
          }
          if (context.mounted) Navigator.of(context).pop(true);
          return;
        }

        // Both POSTs succeeded: cache results.
        try {
          final visit = Visit.fromJson(visitResponseData);
          await widget.db.visitsDao.upsertVisit(VisitsCacheCompanion(
            id: Value(visit.id),
            placeId: Value(visit.placeId),
            authorId: Value(visit.authorId),
            date: Value(visit.date),
            rating: Value(visit.rating),
            pricePp: Value(visit.pricePp),
            comment: Value(visit.comment),
            syncStatus: const Value('synced'),
            createdAt: Value(visit.createdAt),
          ));
          if (fvResponseData != null) {
            final foodVisit = FoodVisit.fromJson(fvResponseData);
            await widget.db.foodVisitsDao
                .upsertFoodVisit(FoodVisitsCacheCompanion(
              id: Value(foodVisit.id),
              visitId: Value(foodVisit.visitId),
              foodId: Value(foodVisit.foodId),
              placeName: Value(foodVisit.placeName),
              date: Value(foodVisit.date),
              rating: Value(foodVisit.rating),
              pricePp: Value(foodVisit.pricePp),
              comment: Value(foodVisit.comment),
              syncStatus: const Value('synced'),
              createdAt: Value(foodVisit.createdAt),
            ));
          }
        } catch (_) {}

        if (context.mounted) Navigator.of(context).pop(true);
      },
    );

    return AddRecordScreen(config: config);
  }
}
