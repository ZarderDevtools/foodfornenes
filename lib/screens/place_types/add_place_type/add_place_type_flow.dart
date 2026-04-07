// lib/screens/place_types/add_place_type/add_place_type_flow.dart

import 'package:flutter/material.dart';

import '../../../models/place_type.dart';
import '../../../screens/add_record/add_record_config.dart';
import '../../../screens/add_record/add_record_screen.dart';
import '../../../screens/add_record/form_values.dart';
import '../../../services/api_client.dart';
import '../../../widgets/form_fields/field_spec.dart';
import '../../../widgets/form_fields/text_field_spec.dart';

/// Flujo para crear un nuevo PlaceType.
/// Delega la UI en AddRecordScreen (genérico).
/// Si la creación tiene éxito, hace pop devolviendo el [PlaceType] creado,
/// para que el llamador pueda autoseleccionarlo si lo necesita.
class AddPlaceTypeFlow extends StatelessWidget {
  const AddPlaceTypeFlow({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AddRecordConfig(
      title: 'Añadir tipo',
      fields: [
        TextFieldSpec(
          key: 'name',
          label: 'Nombre',
          required: true,
          requiredMessage: 'El nombre es obligatorio.',
          placeholder: 'Ej: Restaurante, Panadería, Carnicería…',
          validator: FieldValidators.minLen(2, message: 'Mínimo 2 caracteres.'),
        ),
      ],
      onSubmit: (AddFormValues values) async {
        final name = values.textOrEmpty('name').trim();
        if (name.isEmpty) throw Exception('El nombre es obligatorio.');

        final api = await ApiClient.create();

        final res = await api.post(
          '/api/v1/place-types/',
          data: <String, dynamic>{'name': name},
        );

        final data = res.data;
        if (data is! Map<String, dynamic>) {
          throw Exception('Respuesta inesperada creando tipo: $data');
        }

        final created = PlaceType.fromJson(data);
        if (context.mounted) Navigator.of(context).pop(created);
      },
    );

    return AddRecordScreen(config: config);
  }
}
