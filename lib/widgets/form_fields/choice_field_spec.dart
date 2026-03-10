// lib/widgets/form_fields/choice_field_spec.dart

import 'package:flutter/material.dart';

import 'field_spec.dart';

/// Opción genérica para ChoiceField.
class ChoiceItem<T> {
  final T value;
  final String label;

  const ChoiceItem({
    required this.value,
    required this.label,
  });
}

/// Campo tipo "choice" (selección de una opción).
class ChoiceFieldSpec<T> extends FieldSpec {
  /// Placeholder cuando no hay nada seleccionado.
  final String? placeholder;

  /// Opciones disponibles.
  final List<ChoiceItem<T>> options;

  /// Si permite "sin seleccionar" (null) incluso si no es required.
  final bool allowEmpty;

  /// Cómo mostrar el valor ya guardado en el formulario.
  final String Function(T value)? valueToLabel;

  const ChoiceFieldSpec({
    required super.key,
    required super.label,
    required this.options,
    super.required = false,
    super.requiredMessage,
    super.hint,
    super.defaultValue,
    super.validator,

    // ✅ IMPORTANTE: permitir hook genérico definido en FieldSpec
    super.onChanged,

    this.placeholder,
    this.allowEmpty = true,
    this.valueToLabel,
  }) : super(kind: FieldKind.choice);

  /// Busca la label de una opción por value.
  String? labelForValue(Object? value) {
    if (value == null) return null;

    for (final item in options) {
      if (item.value == value) return item.label;
    }

    if (valueToLabel != null && value is T) {
      return valueToLabel!(value as T);
    }

    return null;
  }
}
