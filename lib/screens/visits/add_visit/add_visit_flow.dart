// lib/screens/visits/add_visit/add_visit_flow.dart

import 'package:flutter/material.dart';

import '../../../models/place.dart';
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
  const AddVisitFlow({super.key});

  @override
  State<AddVisitFlow> createState() => _AddVisitFlowState();
}

class _AddVisitFlowState extends State<AddVisitFlow> {
  bool _loading = true;
  String? _error;

  ApiClient? _api;
  List<PlaceType> _placeTypes = const [];
  String? _defaultPlaceTypeId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final api = await ApiClient.create();
      final catRepo = CategorizationRepository(api);

      final types = await catRepo.listPlaceTypes(
        isActive: true,
        ordering: 'name',
        page: 1,
      );

      final rest = types.cast<PlaceType?>().firstWhere(
            (t) => (t?.name ?? '').trim().toLowerCase() == 'restaurante',
            orElse: () => null,
          );

      if (!mounted) return;
      setState(() {
        _api = api;
        _placeTypes = types;
        _defaultPlaceTypeId = rest?.id ?? (types.isNotEmpty ? types.first.id : null);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
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

    final api = _api!;
    final placesRepo = PlacesRepository(api);

    final placeTypeOptions = _placeTypes
        .map((pt) => ChoiceItem<String>(value: pt.id, label: pt.name))
        .toList();

    final config = AddRecordConfig(
      title: 'Añadir visita',
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

            final paged = await placesRepo.fetchPlaces(q);
            return paged.results;
          },
          getId: (p) => p.id,
          getLabel: (p) => p.name,

          // ✅ Botón "Añadir Sitio" debajo del selector
          createLabel: 'Añadir Sitio',
          onCreate: (values) async {
            final currentTypeId = values.get<String>('place_type_id');
            final currentTypeLabel = _placeTypeNameById(currentTypeId);

            final created = await Navigator.of(context).push<Place>(
              MaterialPageRoute(
                builder: (_) => AddPlaceFlow(
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

        final now = DateTime.now();
        final date = '${now.year.toString().padLeft(4, '0')}-'
            '${now.month.toString().padLeft(2, '0')}-'
            '${now.day.toString().padLeft(2, '0')}';

        await api.post(
          '/api/v1/visits/',
          data: <String, dynamic>{
            'place': placeId,
            'date': date,
            'rating': rating,
            'price_per_person': pricePp,
            if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
          },
        );

        if (context.mounted) Navigator.of(context).pop(true);
      },
    );

    return AddRecordScreen(config: config);
  }
}
