// lib/screens/foods/edit_food/edit_food_flow.dart

import 'package:flutter/material.dart';

import '../../../models/food.dart';
import '../../../repositories/foods_repository.dart';
import '../../../services/api_client.dart';
import '../../add_record/add_record_config.dart';
import '../../add_record/add_record_screen.dart';
import '../../add_record/form_values.dart';
import '../../../widgets/form_fields/field_spec.dart';
import '../../../widgets/form_fields/text_field_spec.dart';

class EditFoodFlow extends StatefulWidget {
  final String foodId;

  const EditFoodFlow({super.key, required this.foodId});

  @override
  State<EditFoodFlow> createState() => _EditFoodFlowState();
}

class _EditFoodFlowState extends State<EditFoodFlow> {
  bool _loading = true;
  String? _error;

  ApiClient? _api;
  Food? _food;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final api = await ApiClient.create();
      final repo = FoodsRepository(api);
      final food = await repo.fetchFood(widget.foodId);

      if (!mounted) return;
      setState(() {
        _api = api;
        _food = food;
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
          title: const Text('Editar comida'),
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
                  'Error cargando la comida.',
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
    final food = _food!;
    final repo = FoodsRepository(api);

    final initialValues = <String, Object?>{
      'name': food.name,
    };

    final config = AddRecordConfig(
      title: 'Editar comida',
      initialValues: initialValues,
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
        final name = values.get<String>('name')?.trim();

        final updated = await repo.updateFood(
          widget.foodId,
          <String, dynamic>{'name': name},
        );

        if (context.mounted) Navigator.of(context).pop(updated);
      },
    );

    return AddRecordScreen(config: config);
  }
}
