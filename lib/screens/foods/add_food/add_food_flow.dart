// lib/screens/foods/add_food/add_food_flow.dart

import 'package:flutter/material.dart';

import '../../add_record/add_record_config.dart';
import '../../add_record/add_record_screen.dart';
import '../../add_record/form_values.dart';
import '../../../services/api_client.dart';
import '../../../widgets/form_fields/field_spec.dart';
import '../../../widgets/form_fields/text_field_spec.dart';

/// Pantalla "flow" para Añadir comida.
/// Aquí vive TODA la configuración del alta de Food (campos + submit),
/// y delega la UI en AddRecordScreen (genérico).
class AddFoodFlow extends StatelessWidget {
  const AddFoodFlow({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AddRecordConfig(
      title: 'Añadir comida',
      fields: [
        TextFieldSpec(
          key: 'name',
          label: 'Nombre',
          required: true,
          requiredMessage: 'El nombre es obligatorio.',
          placeholder: 'Ej: Tortilla de patatas',
          validator: FieldValidators.minLen(2, message: 'Mínimo 2 caracteres.'),
        ),
      ],
      onSubmit: (AddFormValues values) async {
        final name = values.textOrEmpty('name');
        if (name.isEmpty) {
          throw Exception('El nombre es obligatorio.');
        }

        final api = await ApiClient.create();

        // OJO: este path es correcto si tu baseUrl NO incluye /api/v1.
        // Si tu baseUrl YA incluye /api/v1, usa '/foods/'.
        await api.post(
          '/api/v1/foods/',
          data: <String, dynamic>{
            'name': name,
            'is_active': true,
          },
        );
      },
    );

    return AddRecordScreen(config: config);
  }
}
