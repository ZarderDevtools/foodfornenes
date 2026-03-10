// lib/widgets/form_fields/text_field_widget.dart

import 'package:flutter/material.dart';

import '../../screens/add_record/form_values.dart';
import 'text_field_spec.dart';

class TextFieldWidget extends StatefulWidget {
  final TextFieldSpec spec;
  final AddFormValues values;
  final String? errorText;

  const TextFieldWidget({
    super.key,
    required this.spec,
    required this.values,
    required this.errorText,
  });

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  String _asString(Object? v) => (v is String) ? v : (v?.toString() ?? '');

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    final initial = _asString(widget.values.get<String>(widget.spec.key));
    _controller = TextEditingController(text: initial);
  }

  @override
  void didUpdateWidget(covariant TextFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si el valor del formulario cambia desde fuera (defaults/initialValues),
    // lo reflejamos SOLO si el usuario no está escribiendo (no focus).
    if (!_focusNode.hasFocus) {
      final currentFormValue = _asString(widget.values.get<String>(widget.spec.key));
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

  @override
  Widget build(BuildContext context) {
    final s = widget.spec;

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: s.keyboardType,
      textCapitalization: s.textCapitalization,
      maxLength: s.maxLength,
      minLines: s.multiline ? 2 : 1,
      maxLines: s.multiline ? (s.maxLines ?? 6) : 1,
      onChanged: (txt) => widget.values.setValue(s.key, txt),
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
