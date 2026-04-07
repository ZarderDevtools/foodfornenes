// lib/screens/tags/add_tag/add_tag_flow.dart

import 'package:flutter/material.dart';

import '../../../models/tag.dart';
import '../../../screens/add_record/add_record_config.dart';
import '../../../screens/add_record/add_record_screen.dart';
import '../../../screens/add_record/form_values.dart';
import '../../../services/api_client.dart';
import '../../../widgets/form_fields/field_spec.dart';
import '../../../widgets/form_fields/text_field_spec.dart';

/// Flujo para crear un nuevo Tag.
/// Delega la UI en AddRecordScreen (genérico).
/// Si la creación tiene éxito, hace pop devolviendo el [Tag] creado,
/// para que el llamador pueda autoseleccionarlo si lo necesita.
class AddTagFlow extends StatelessWidget {
  const AddTagFlow({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AddRecordConfig(
      title: 'Añadir etiqueta',
      fields: [
        TextFieldSpec(
          key: 'name',
          label: 'Nombre',
          required: true,
          requiredMessage: 'El nombre es obligatorio.',
          placeholder: 'Ej: Favorito, Sin gluten, Para niños…',
          validator: FieldValidators.minLen(2, message: 'Mínimo 2 caracteres.'),
        ),
      ],
      onSubmit: (AddFormValues values) async {
        final name = values.textOrEmpty('name').trim();
        if (name.isEmpty) throw Exception('El nombre es obligatorio.');

        final api = await ApiClient.create();

        final res = await api.post(
          '/api/v1/tags/',
          data: <String, dynamic>{'name': name},
        );

        final data = res.data;
        if (data is! Map<String, dynamic>) {
          throw Exception('Respuesta inesperada creando etiqueta: $data');
        }

        final created = Tag.fromJson(data);
        if (context.mounted) Navigator.of(context).pop(created);
      },
    );

    return AddRecordScreen(config: config);
  }
}
