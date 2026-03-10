// lib/widgets/form_fields/number_field_spec.dart

import 'package:flutter/material.dart';

import 'field_spec.dart';

/// Campo numérico genérico.
///
/// Se apoya en validadores (FieldValidators) para asegurar
/// que el contenido sea realmente numérico aunque el usuario pegue texto.
class NumberFieldSpec extends FieldSpec {
  /// Placeholder (texto dentro del input).
  final String? placeholder;

  /// Si acepta decimales (true) o solo enteros (false).
  final bool allowDecimal;

  /// Valor mínimo permitido (opcional).
  final num? min;

  /// Valor máximo permitido (opcional).
  final num? max;

  /// Tipo de teclado (numérico).
  final TextInputType keyboardType;

  const NumberFieldSpec({
    required super.key,
    required super.label,
    super.required = false,
    super.requiredMessage,
    super.hint,
    super.defaultValue,
    super.validator,
    this.placeholder,
    this.allowDecimal = false,
    this.min,
    this.max,
    this.keyboardType = TextInputType.number,
  }) : super(kind: FieldKind.number);
}
