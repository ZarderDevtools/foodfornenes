// lib/widgets/form_fields/text_field_spec.dart

import 'package:flutter/material.dart';

import 'field_spec.dart';

/// Campo genérico de texto.
///
/// Nota: el widget correspondiente (TextFieldWidget) usará estas props
/// para crear un TextFormField / TextField con el estilo de Filtros.
class TextFieldSpec extends FieldSpec {
  /// Placeholder (si quieres distinto de hint, que suele ser texto abajo).
  final String? placeholder;

  /// Si permite varias líneas.
  final bool multiline;

  /// Máximo de líneas (solo si multiline=true).
  final int? maxLines;

  /// Longitud máxima.
  final int? maxLength;

  /// Tipo de teclado (texto, email, etc.).
  final TextInputType keyboardType;

  /// Capitalización del texto.
  final TextCapitalization textCapitalization;

  const TextFieldSpec({
    required super.key,
    required super.label,
    super.required = false,
    super.requiredMessage,
    super.hint,
    super.defaultValue,
    super.validator,
    this.placeholder,
    this.multiline = false,
    this.maxLines,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.sentences,
  }) : super(kind: FieldKind.text);
}
