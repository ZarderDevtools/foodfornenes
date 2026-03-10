// lib/widgets/form_fields/number_field_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../screens/add_record/form_values.dart';
import 'number_field_spec.dart';

class NumberFieldWidget extends StatefulWidget {
  final NumberFieldSpec spec;
  final AddFormValues values;
  final String? errorText;

  const NumberFieldWidget({
    super.key,
    required this.spec,
    required this.values,
    required this.errorText,
  });

  @override
  State<NumberFieldWidget> createState() => _NumberFieldWidgetState();
}

class _NumberFieldWidgetState extends State<NumberFieldWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  String _asString(Object? v) => v == null ? '' : v.toString();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    final initial = _asString(widget.values[widget.spec.key]);
    _controller = TextEditingController(text: initial);
  }

  @override
  void didUpdateWidget(covariant NumberFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_focusNode.hasFocus) {
      final currentFormValue = _asString(widget.values[widget.spec.key]);
      if (_controller.text != currentFormValue) {
        _controller.text = currentFormValue;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Normaliza el texto a num (int/double) si es posible.
  /// - Si allowDecimal=true acepta "," o "."
  /// - Si falla el parseo, devuelve null
  num? _parse(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;

    if (widget.spec.allowDecimal) {
      final normalized = s.replaceAll(',', '.');
      return double.tryParse(normalized);
    }
    return int.tryParse(s);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.spec;

    // Filtrado suave de caracteres. OJO:
    // - Esto ayuda, pero NO sustituye a la validación final (porque se puede pegar texto raro).
    final inputFormatters = <TextInputFormatter>[
      FilteringTextInputFormatter.allow(
        RegExp(s.allowDecimal ? r'[0-9\.,-]' : r'[0-9-]'),
      ),
    ];

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: s.keyboardType,
      inputFormatters: inputFormatters,
      onChanged: (txt) {
        // Guardamos el texto (string) para no “romper” al usuario mientras escribe.
        // El submit/validator se encargará de validar de verdad.
        widget.values.setValue(s.key, txt);
      },
      onEditingComplete: () {
        // Al terminar de editar, si parsea, podemos normalizar el valor.
        final parsed = _parse(_controller.text);
        if (parsed != null) {
          widget.values.setValue(s.key, parsed.toString());
        }
        FocusScope.of(context).unfocus();
      },
      decoration: InputDecoration(
        hintText: s.placeholder,
        errorText: widget.errorText,
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
