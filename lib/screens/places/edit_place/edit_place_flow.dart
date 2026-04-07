// lib/screens/places/edit_place/edit_place_flow.dart

import 'package:flutter/material.dart';

import '../../../models/area.dart';
import '../../../models/place.dart';
import '../../../models/tag.dart';
import '../../areas/add_area/add_area_flow.dart';
import '../../tags/add_tag/add_tag_flow.dart';
import '../../../repositories/categorization_repository.dart';
import '../../../repositories/places_repository.dart';
import '../../../screens/add_record/add_record_config.dart';
import '../../../screens/add_record/add_record_screen.dart';
import '../../../screens/add_record/form_values.dart';
import '../../../services/api_client.dart';
import '../../../widgets/detail_field.dart';
import '../../../widgets/form_fields/field_spec.dart';
import '../../../widgets/form_fields/multi_relation_field_spec.dart';
import '../../../widgets/form_fields/relation_field_spec.dart';
import '../../../widgets/form_fields/text_field_spec.dart';

class PlaceEditFlow extends StatefulWidget {
  final String placeId;

  const PlaceEditFlow({super.key, required this.placeId});

  @override
  State<PlaceEditFlow> createState() => _PlaceEditFlowState();
}

class _PlaceEditFlowState extends State<PlaceEditFlow> {
  bool _loading = true;
  String? _error;

  ApiClient? _api;
  Place? _place;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final api = await ApiClient.create();
      final repo = PlacesRepository(api);
      final place = await repo.fetchPlace(widget.placeId);

      if (!mounted) return;
      setState(() {
        _api = api;
        _place = place;
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
          title: const Text('Editar sitio'),
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
                  'Error cargando el sitio.',
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
    final place = _place!;
    final catRepo = CategorizationRepository(api);
    final repo = PlacesRepository(api);

    // ── Valores iniciales del formulario ───────────────────────────────────
    final initialValues = <String, Object?>{
      'name': place.name,
      'area_id': place.areaId,
      if (place.areaName != null) 'area_id__label': place.areaName,
      'description': place.description,
      'url': place.url,
      // MultiRelationField espera IDs en 'tags' y labels en 'tags__labels'
      'tags': place.tagIds,
      'tags__labels': place.tags,
    };

    // ── Header: estadísticas de solo lectura ───────────────────────────────
    final ratingStr = place.avgRating != null
        ? place.avgRating!.toStringAsFixed(1)
        : null;
    final priceStr = place.avgPricePp != null
        ? '${place.avgPricePp!.toStringAsFixed(2)} €'
        : null;

    final header = DetailSection(
      title: 'Estadísticas',
      children: [
        DetailField(label: 'Valoración media', value: ratingStr),
        const SizedBox(height: 12),
        DetailField(label: 'Precio medio p.p.', value: priceStr),
        const SizedBox(height: 12),
        DetailField(
          label: 'Número de visitas',
          value: '${place.visitsCount}',
        ),
      ],
    );

    // ── Configuración del formulario ───────────────────────────────────────
    final config = AddRecordConfig(
      title: 'Editar sitio',
      header: header,
      initialValues: initialValues,
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

        // 2) Ubicación (area) (opcional)
        RelationFieldSpec<Area>(
          key: 'area_id',
          label: 'Ubicación',
          placeholder: 'Pulsa para buscar una ubicación',
          searchHint: 'Buscar ubicación…',
          fetchItems: (search, values) async {
            final s = search.trim();
            return catRepo.listAreas(
              search: s.isEmpty ? null : s,
              ordering: 'name',
              page: 1,
            );
          },
          getId: (area) => area.id,
          getLabel: (area) => area.name,
          onCreate: (values) => Navigator.of(context).push<Area>(
            MaterialPageRoute(builder: (_) => const AddAreaFlow()),
          ),
        ),

        // 3) Descripción (opcional)
        const TextFieldSpec(
          key: 'description',
          label: 'Descripción',
          placeholder: 'Opcional…',
          multiline: true,
          maxLines: 5,
        ),

        // 4) URL (opcional)
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

        // 5) Tags (opcional)
        MultiRelationFieldSpec<Tag>(
          key: 'tags',
          label: 'Etiquetas',
          placeholder: 'Añadir etiqueta…',
          searchHint: 'Buscar etiqueta…',
          fetchItems: (search, _) async {
            final s = search.trim();
            return catRepo.listTags(
              search: s.isEmpty ? null : s,
              ordering: 'name',
              page: 1,
            );
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
        final areaId = values.get<String>('area_id');
        final description = values.get<String>('description')?.trim();
        final url = values.get<String>('url')?.trim();
        final tagIds = (values['tags'] as List?)?.cast<String>() ?? [];

        final payload = <String, dynamic>{
          'name': name,
          'area': (areaId != null && areaId.isNotEmpty) ? areaId : null,
          'description': description ?? '',
          'url': url ?? '',
          'tags': tagIds,
        };

        final updated = await repo.updatePlace(widget.placeId, payload);

        if (context.mounted) Navigator.of(context).pop(updated);
      },
    );

    return AddRecordScreen(config: config);
  }
}
