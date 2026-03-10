// lib/screens/places/add_place/add_place_flow.dart

import 'package:flutter/material.dart';

import '../../../models/place.dart';
import '../../../models/place_type.dart';
import '../../../repositories/categorization_repository.dart';
import '../../../screens/add_record/add_record_config.dart';
import '../../../screens/add_record/add_record_screen.dart';
import '../../../screens/add_record/form_values.dart';
import '../../../services/api_client.dart';
import '../../../widgets/form_fields/field_spec.dart';
import '../../../widgets/form_fields/choice_field_spec.dart';
import '../../../widgets/form_fields/relation_field_spec.dart';
import '../../../widgets/form_fields/text_field_spec.dart';

class AddPlaceFlow extends StatefulWidget {
  /// Si vienes de "Restaurantes" / "Carnicerías", etc.
  /// puedes pasar el placeType por defecto para que aparezca ya seleccionado.
  final String? defaultPlaceTypeId;
  final String? defaultPlaceTypeLabel;

  const AddPlaceFlow({
    super.key,
    this.defaultPlaceTypeId,
    this.defaultPlaceTypeLabel,
  });

  @override
  State<AddPlaceFlow> createState() => _AddPlaceFlowState();
}

class _AddPlaceFlowState extends State<AddPlaceFlow> {
  bool _loading = true;
  String? _error;

  ApiClient? _api;
  List<PlaceType> _placeTypes = const [];

  String? _resolvedDefaultTypeId;
  String? _resolvedDefaultTypeLabel;

  static const _kPlaceTypeKey = 'place_type_id';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final api = await ApiClient.create();
      final repo = CategorizationRepository(api);

      final types = await repo.listPlaceTypes(
        isActive: true,
        ordering: 'name',
        page: 1,
      );

      String? defId = widget.defaultPlaceTypeId;
      String? defLabel = widget.defaultPlaceTypeLabel;

      // Si nos pasan id pero no label, lo resolvemos con la lista
      if (defId != null && (defLabel == null || defLabel.trim().isEmpty)) {
        final match = types.cast<PlaceType?>().firstWhere(
              (t) => t?.id == defId,
              orElse: () => null,
            );
        defLabel = match?.name;
      }

      if (!mounted) return;
      setState(() {
        _api = api;
        _placeTypes = types;
        _resolvedDefaultTypeId = defId;
        _resolvedDefaultTypeLabel = defLabel;
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

    final api = _api!;
    final catRepo = CategorizationRepository(api);

    final priceOptions = const [
      ChoiceItem<String>(value: '€', label: '€'),
      ChoiceItem<String>(value: '€€', label: '€€'),
      ChoiceItem<String>(value: '€€€', label: '€€€'),
      ChoiceItem<String>(value: '€€€€', label: '€€€€'),
      ChoiceItem<String>(value: '€€€€€', label: '€€€€€'),
    ];

    final initial = <String, Object?>{};
    if (_resolvedDefaultTypeId != null) {
      initial[_kPlaceTypeKey] = _resolvedDefaultTypeId;
      if (_resolvedDefaultTypeLabel != null && _resolvedDefaultTypeLabel!.trim().isNotEmpty) {
        initial['${_kPlaceTypeKey}__label'] = _resolvedDefaultTypeLabel!.trim();
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

        // 2) Tipo (placeType) (obligatorio) - relation con buscador
        RelationFieldSpec<PlaceType>(
          key: _kPlaceTypeKey,
          label: 'Tipo',
          required: true,
          requiredMessage: 'Selecciona un tipo.',
          placeholder: 'Pulsa para buscar un tipo',
          searchHint: 'Buscar tipo…',
          fetchItems: (search, values) async {
            final s = search.trim();
            final res = await catRepo.listPlaceTypes(
              isActive: true,
              search: s.isEmpty ? null : s,
              ordering: 'name',
              page: 1,
            );
            return res;
          },
          getId: (pt) => pt.id,
          getLabel: (pt) => pt.name,
        ),

        // 3) Rango de precio (obligatorio)
        ChoiceFieldSpec<String>(
          key: 'price_range',
          label: 'Rango de precio',
          required: true,
          requiredMessage: 'Selecciona un rango de precio.',
          placeholder: 'Selecciona un rango',
          options: priceOptions,
          // si quieres default, descomenta:
          // defaultValue: '€€',
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
            final ok = uri != null && uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
            return ok ? null : 'Debe ser una URL válida (http/https).';
          },
        ),
      ],

      onSubmit: (AddFormValues values) async {
        final name = values.get<String>('name')?.trim();
        final placeTypeId = values.get<String>(_kPlaceTypeKey);
        final priceRange = values.get<String>('price_range');
        final description = values.get<String>('description')?.trim();
        final url = values.get<String>('url')?.trim();

        final payload = <String, dynamic>{
          'name': name,
          'place_type': placeTypeId,
          'price_range': priceRange,
          if (description != null && description.isNotEmpty) 'description': description,
          if (url != null && url.isNotEmpty) 'url': url,
        };

        final res = await api.post(
          '/api/v1/places/',
          data: payload,
        );

        final data = res.data;
        if (data is! Map<String, dynamic>) {
          throw Exception('Respuesta inesperada creando place: $data');
        }

        final created = Place.fromJson(data);

        // ✅ devolvemos el Place creado para autoseleccionarlo al volver
        if (context.mounted) Navigator.of(context).pop(created);
      },
    );

    return AddRecordScreen(config: config);
  }
}
