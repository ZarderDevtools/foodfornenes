import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../filter_definition.dart';

/// Campo numérico genérico para filtros.
/// - value esperado: double? (por ejemplo minAvgRating, maxAvgPricePp)
/// - Permite decimal opcional (.)
class FilterNumberField<T> extends StatefulWidget {
  final FilterDefinition<T> definition;
  final T value;
  final void Function(T) onChanged;

  /// Hint opcional
  final String? hintText;

  /// Si quieres restringir a enteros (por defecto false)
  final bool integerOnly;

  const FilterNumberField({
    super.key,
    required this.definition,
    required this.value,
    required this.onChanged,
    this.hintText,
    this.integerOnly = false,
  });

  @override
  State<FilterNumberField<T>> createState() => _FilterNumberFieldState<T>();
}

class _FilterNumberFieldState<T> extends State<FilterNumberField<T>> {
  late final TextEditingController _controller;

  String _valueToText(T v) {
    final current = widget.definition.getValue(v);

    if (current == null) return '';

    if (current is num) {
      // ✅ si es 1.0 -> mostrar "1" (esto también evita el "0.0")
      final d = current.toDouble();
      if (d == d.roundToDouble()) return d.toInt().toString();
      return d.toString();
    }

    if (current is String) return current;

    return '';
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _valueToText(widget.value));
  }

  @override
  void didUpdateWidget(covariant FilterNumberField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newText = _valueToText(widget.value);

    // ✅ Si el valor viene cambiado desde fuera (ej: "Limpiar filtros"), actualizamos el campo
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
    final formatters = <TextInputFormatter>[
      if (widget.integerOnly)
        FilteringTextInputFormatter.digitsOnly
      else
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
    ];

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
          keyboardType:
              TextInputType.numberWithOptions(decimal: !widget.integerOnly),
          inputFormatters: formatters,
          decoration: InputDecoration(
            hintText: widget.hintText ?? '0',
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (raw) {
            final txt = raw.trim();

            if (txt.isEmpty) {
              widget.onChanged(widget.definition.setValue(widget.value, null));
              return;
            }

            if (!widget.integerOnly && txt.endsWith('.')) {
              return; // el usuario aún está escribiendo el decimal
            }

            final parsed =
                widget.integerOnly ? int.tryParse(txt) : double.tryParse(txt);
            if (parsed == null) return;

            final numValue = widget.integerOnly
                ? (parsed as int).toDouble()
                : parsed as double;

            widget.onChanged(widget.definition.setValue(widget.value, numValue));
          },
        ),
      ],
    );
  }
}
