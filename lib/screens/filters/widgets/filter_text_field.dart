import 'package:flutter/material.dart';
import '../filter_definition.dart';

/// Widget genérico para filtros tipo texto (search, name, etc.)
class FilterTextField<T> extends StatefulWidget {
  final FilterDefinition<T> definition;
  final T value;
  final void Function(T) onChanged;

  const FilterTextField({
    super.key,
    required this.definition,
    required this.value,
    required this.onChanged,
  });

  @override
  State<FilterTextField<T>> createState() => _FilterTextFieldState<T>();
}

class _FilterTextFieldState<T> extends State<FilterTextField<T>> {
  late final TextEditingController _controller;

  String _valueToText(T v) {
    final current = widget.definition.getValue(v);
    if (current == null) return '';
    if (current is String) return current;
    return current.toString();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _valueToText(widget.value));
  }

  @override
  void didUpdateWidget(covariant FilterTextField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newText = _valueToText(widget.value);

    // ✅ Si el valor viene cambiado desde fuera (ej: "Limpiar filtros"), actualizamos el campo.
    // (Si no cambia, no tocamos nada para no fastidiar el cursor mientras escribe)
    if (_controller.text != newText) {
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.definition.label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Buscar...',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (text) {
            widget.onChanged(widget.definition.setValue(widget.value, text));
          },
        ),
      ],
    );
  }
}
