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
  String? _errorMessage;
  bool _errorCanRetry = false;

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
      String msg;
      bool canRetry;
      if (e is ApiException) {
        final code = e.statusCode;
        if (code == null || code >= 500 || code == 401) {
          msg = 'La edición no está disponible sin conexión al servidor.';
          canRetry = false;
        } else {
          msg = 'No se pudo cargar la comida. ${e.message}';
          canRetry = true;
        }
      } else {
        msg = 'La edición no está disponible sin conexión al servidor.';
        canRetry = false;
      }
      setState(() {
        _errorMessage = msg;
        _errorCanRetry = canRetry;
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

    if (_errorMessage != null) {
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
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _errorCanRetry
                      ? Icons.error_outline_rounded
                      : Icons.cloud_off_rounded,
                  size: 40,
                  color: Colors.grey,
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (_errorCanRetry)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _loading = true;
                        _errorMessage = null;
                      });
                      _init();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reintentar'),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Volver'),
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
        try {
          final updated = await repo.updateFood(
            widget.foodId,
            <String, dynamic>{'name': name},
          );
          if (context.mounted) Navigator.of(context).pop(updated);
        } on ApiException catch (e) {
          final code = e.statusCode;
          if (code == null || code >= 500 || code == 401) {
            throw _EditException(
              'No se pudo guardar. Comprueba la conexión e inténtalo de nuevo.',
            );
          }
          throw _EditException(e.message);
        } catch (e) {
          if (e is _EditException) rethrow;
          throw _EditException(
            'No se pudo guardar. Comprueba la conexión e inténtalo de nuevo.',
          );
        }
      },
    );

    return AddRecordScreen(config: config);
  }
}

// Excepción con mensaje ya humanizado para mostrar en el formulario.
// AddRecordScreen usa e.toString() directamente — esta clase devuelve solo el mensaje.
class _EditException implements Exception {
  final String message;
  _EditException(this.message);

  @override
  String toString() => message;
}
