// lib/screens/add_record/add_record_screen.dart

import 'package:flutter/material.dart';

import '../../models/bottom_action.dart';
import '../../widgets/bottom_bar.dart';
import '../../widgets/form_fields/field_renderer.dart';
import '../../widgets/form_fields/field_spec.dart';
import 'add_record_config.dart';
import 'form_values.dart';

class AddRecordScreen extends StatefulWidget {
  final AddRecordConfig config;

  const AddRecordScreen({
    super.key,
    required this.config,
  });

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  late final AddFormValues _values;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _values = AddFormValues(initialValues: widget.config.initialValues);

    // Si algún FieldSpec define defaultValue, lo aplicamos si no hay valor inicial.
    for (final FieldSpec spec in widget.config.fields) {
      if (!_values.hasValue(spec.key) && spec.defaultValue != null) {
        _values.setValue(spec.key, spec.defaultValue, notify: false);
      }
    }
  }

  @override
  void dispose() {
    _values.dispose();
    super.dispose();
  }

  bool _validateAll() {
    _values.clearErrors(notify: false);

    bool ok = true;

    for (final FieldSpec spec in widget.config.fields) {
      final Object? value = _values[spec.key];

      // 1) required
      if (spec.required) {
        final isEmptyString = value is String && value.trim().isEmpty;
        final isEmptyList = value is List && value.isEmpty;
        final isNull = value == null;

        if (isNull || isEmptyString || isEmptyList) {
          _values.setFieldError(
            spec.key,
            spec.requiredMessage ?? 'Este campo es obligatorio.',
            notify: false,
          );
          ok = false;
          continue;
        }
      }

      // 2) custom validator (si existe)
      final validator = spec.validator;
      if (validator != null) {
        final String? msg = validator(value, _values);
        if (msg != null && msg.trim().isNotEmpty) {
          _values.setFieldError(spec.key, msg, notify: false);
          ok = false;
        }
      }
    }

    _values.notifyListeners();
    return ok;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final canSubmit = widget.config.canSubmit?.call(_values) ?? true;
    if (!canSubmit) return;

    final ok = _validateAll();
    if (!ok) return;

    setState(() => _isSubmitting = true);
    _values.setGlobalError(null);

    try {
      await widget.config.onSubmit(_values);
      if (!mounted) return;
      Navigator.of(context).maybePop(true);
    } catch (e) {
      // Por ahora, error global simple.
      // Más adelante podrás mapear errores backend -> fieldErrors.
      _values.setGlobalError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final home = widget.config.homeAction ?? BottomAction.home();
    final back = widget.config.backAction ?? BottomAction.back();

    return AnimatedBuilder(
      animation: _values,
      builder: (context, _) {
        final canSubmit = (widget.config.canSubmit?.call(_values) ?? true);
        final saveEnabled = canSubmit && !_isSubmitting;

        final save = BottomAction.primary(
          id: 'save',
          icon: widget.config.submitIcon,
          enabled: saveEnabled,
          onTap: (_) => _submit(),
        );

        return Scaffold(
          backgroundColor: const Color(0xFFF6FBFF),
          appBar: AppBar(
            title: Text(widget.config.title),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_values.globalError != null) ...[
                    _GlobalErrorBox(message: _values.globalError!),
                    const SizedBox(height: 16),
                  ],
                  for (final FieldSpec spec in widget.config.fields) ...[
                    FieldRenderer(
                      spec: spec,
                      values: _values,
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ✅ Bottom bar calcada a Filtros (mismo widget y mismo estilo).
          // Orden: [Home] [Guardar] [Back]
          bottomNavigationBar: SafeArea(
            top: false,
            child: BottomBar3Slots(
              floating: false,
              left: home,
              center: save,
              right: back,
            ),
          ),
        );
      },
    );
  }
}

class _GlobalErrorBox extends StatelessWidget {
  final String message;

  const _GlobalErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFE6E3), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
