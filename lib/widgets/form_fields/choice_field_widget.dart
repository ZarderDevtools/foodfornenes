// lib/widgets/form_fields/choice_field_widget.dart

import 'package:flutter/material.dart';

import '../../screens/add_record/form_values.dart';
import 'choice_field_spec.dart';

class ChoiceFieldWidget<T> extends StatelessWidget {
  final ChoiceFieldSpec<T> spec;
  final AddFormValues values;
  final String? errorText;

  const ChoiceFieldWidget({
    super.key,
    required this.spec,
    required this.values,
    required this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final current = values[spec.key];

    // Intentamos castear el valor actual al tipo T, si coincide.
    T? selected;
    if (current is T) {
      selected = current as T;
    } else {
      selected = null;
    }

    final items = spec.options
        .map(
          (o) => DropdownMenuItem<T>(
            value: o.value,
            child: Text(o.label),
          ),
        )
        .toList();

    return DropdownButtonFormField<T>(
      value: selected,
      items: items,
      isExpanded: true,
      onChanged: (v) {
        // Si no permite vacío y eligen null, ignoramos
        if (v == null && !spec.allowEmpty) return;

        values.setValue(spec.key, v);

        // ✅ Hook genérico: permite reaccionar a cambios (ej: limpiar place_id).
        spec.onChanged?.call(v, values);
      },
      decoration: InputDecoration(
        hintText: spec.placeholder,
        errorText: errorText,
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
