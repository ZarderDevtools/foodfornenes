// lib/screens/visits/add_visit/add_visit_flow.dart

import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../local/app_database.dart';
import '../../../models/place.dart';
import '../../../models/visit.dart';
import '../../../models/place_list_query.dart';
import '../../../models/place_type.dart';
import '../../../repositories/categorization_repository.dart';
import '../../../repositories/places_repository.dart';
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

class AddVisitFlow extends StatefulWidget {
  final AppDatabase db;
  final String? defaultPlaceId;
  final String? defaultPlaceName;
  final String? defaultPlaceTypeId;

  const AddVisitFlow({
    super.key,
    required this.db,
    this.defaultPlaceId,
    this.defaultPlaceName,
    this.defaultPlaceTypeId,
  });

  @override
  State<AddVisitFlow> createState() => _AddVisitFlowState();
}

class _AddVisitFlowState extends State<AddVisitFlow> {
  bool _loading = true;
  String? _error;

  ApiClient? _api;
  List<PlaceType> _placeTypes = const [];
  String? _defaultPlaceTypeId;
  bool _offlineEmpty = false;

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

      // Try cache first
      final cached = await catRepo.getCachedPlaceTypes();
      if (cached != null && cached.isNotEmpty) {
        final rest = _findRestauranteType(cached);
        if (!mounted) return;
        setState(() {
          _api = api;
          _placeTypes = cached;
          _defaultPlaceTypeId = widget.defaultPlaceTypeId ??
              rest?.id ??
              (cached.isNotEmpty ? cached.first.id : null);
          _loading = false;
        });
        _backgroundRefreshPlaceTypes(catRepo);
        return;
      }

      // No cache: try API
      final types = await catRepo.listPlaceTypes(isActive: true, ordering: 'name', page: 1);
      final rest = _findRestauranteType(types);
      if (!mounted) return;
      setState(() {
        _api = api;
        _placeTypes = types;
        _defaultPlaceTypeId = widget.defaultPlaceTypeId ??
            rest?.id ??
            (types.isNotEmpty ? types.first.id : null);
        _loading = false;
      });
    } catch (_) {
      // API down and no cache: show friendly empty state
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

  Future<void> _saveLocalPending({
    required String placeId,
    required String date,
    required double? rating,
    required double? pricePp,
    required String comment,
    required Map<String, dynamic> payload,
  }) async {
    final localId = 'local_${DateTime.now().microsecondsSinceEpoch}';
    await widget.db.transaction(() async {
      await widget.db.visitsDao.upsertVisit(VisitsCacheCompanion(
        id: Value(localId),
        placeId: Value(placeId),
        authorId: const Value(''),
        date: Value(DateTime.parse(date)),
        rating: Value(rating),
        pricePp: Value(pricePp),
        comment: Value(comment),
        syncStatus: const Value('pending_create'),
        createdAt: Value(DateTime.now()),
      ));
      await widget.db.syncQueueDao.insertPending(
        entityType: 'visit',
        operation: 'create',
        localEntityId: localId,
        payloadJson: jsonEncode(payload),
      );
    });
  }

  String? _placeTypeNameById(String? id) {
    if (id == null) return null;
    for (final pt in _placeTypes) {
      if (pt.id == id) return pt.name;
    }
    return null;
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

    final placeTypeOptions = _placeTypes
        .map((pt) => ChoiceItem<String>(value: pt.id, label: pt.name))
        .toList();

    final config = AddRecordConfig(
      title: 'Añadir visita',
      initialValues: {
        if (_defaultPlaceTypeId != null) 'place_type_id': _defaultPlaceTypeId,
        if (widget.defaultPlaceId != null) 'place_id': widget.defaultPlaceId,
        if (widget.defaultPlaceName != null) 'place_id__label': widget.defaultPlaceName,
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

          // ✅ al cambiar tipo, limpiar sitio + label cacheado
          onChanged: (_, values) {
            values.setValue('place_id', null);
            values.setValue('place_id__label', null);
          },
        ),

        // 2) Sitio (Place) filtrado por el PlaceType elegido
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

            // ✅ Queremos volver con el tipo ya seleccionado según el Place creado
            values.setValue('place_type_id', created.placeTypeId);

            // Si el tipo ha cambiado, el sitio se re-seleccionará (widget lo hace),
            // pero limpiamos por seguridad para evitar restos.
            values.setValue('place_id', null);
            values.setValue('place_id__label', null);

            // ✅ devolvemos el Place -> RelationFieldWidget lo auto-selecciona
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

        // 4) Precio por persona (decimal, opcional)
        NumberFieldSpec(
          key: 'price_per_person',
          label: 'Precio por persona',
          placeholder: 'Ej: 18.50',
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
        final ratingRaw = values['rating'];
        final priceRaw = values['price_per_person'];
        final comment = values.get<String>('comment');

        double? _toDouble(Object? v) {
          if (v == null) return null;
          if (v is num) return v.toDouble();
          if (v is String) {
            final s = v.trim();
            if (s.isEmpty) return null;
            return double.tryParse(s.replaceAll(',', '.'));
          }
          return null;
        }

        final rating = _toDouble(ratingRaw);
        final pricePp = _toDouble(priceRaw);
        final commentTrimmed = comment?.trim() ?? '';

        final now = DateTime.now();
        final date = '${now.year.toString().padLeft(4, '0')}-'
            '${now.month.toString().padLeft(2, '0')}-'
            '${now.day.toString().padLeft(2, '0')}';

        final payload = <String, dynamic>{
          'place': placeId,
          'date': date,
          'rating': rating,
          'price_per_person': pricePp,
          if (commentTrimmed.isNotEmpty) 'comment': commentTrimmed,
        };

        try {
          final res = await api.post('/api/v1/visits/', data: payload);
          final responseData = res.data;
          if (responseData is Map<String, dynamic>) {
            try {
              final visit = Visit.fromJson(responseData);
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
            } catch (_) {
              // Cache write failed after a successful POST.
              // The visit exists on the server; GlobalSyncService will cache it.
            }
          }
          if (context.mounted) Navigator.of(context).pop(true);
        } on ApiException catch (e) {
          final code = e.statusCode;
          if (code != null && code >= 400 && code < 500) {
            rethrow; // Error de validación: AddRecordScreen muestra el error
          }
          // Error temporal (red, timeout, 5xx): guardar offline y cerrar
          if (placeId != null) {
            await _saveLocalPending(
              placeId: placeId,
              date: date,
              rating: rating,
              pricePp: pricePp,
              comment: commentTrimmed,
              payload: payload,
            );
          }
          if (context.mounted) Navigator.of(context).pop(true);
        }
      },
    );

    return AddRecordScreen(config: config);
  }
}
