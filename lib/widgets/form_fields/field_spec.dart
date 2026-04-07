// lib/widgets/form_fields/field_spec.dart

import 'package:flutter/material.dart';

import '../../screens/add_record/form_values.dart';

/// Tipos de campo que soporta el formulario genérico.
enum FieldKind {
  text,
  number,
  choice,

  /// Selector/buscador de relación simple (devuelve un id String).
  relation,

  /// Selector/buscador de relación múltiple (devuelve List<String> de ids).
  multiRelation,
}

/// Firma estándar de validación por campo.
/// - Devuelve `null` si está OK
/// - Devuelve un mensaje (String) si hay error
typedef FieldValidator = String? Function(Object? value, AddFormValues values);

/// Hook opcional para reaccionar a cambios de valor de un campo.
/// Ej: cuando cambia place_type_id -> limpiar place_id
typedef FieldOnChanged = void Function(Object? newValue, AddFormValues values);

/// Contrato base de un campo declarativo.
///
/// Cada tipo concreto (TextFieldSpec, NumberFieldSpec, ChoiceFieldSpec...)
/// extenderá esta clase y añadirá sus props específicas.
abstract class FieldSpec {
  /// Key interna del campo (ej: "name", "price", "place_id").
  final String key;

  /// Etiqueta visible en UI.
  final String label;

  /// Tipo de campo.
  final FieldKind kind;

  /// Si es obligatorio.
  final bool required;

  /// Mensaje si required falla.
  final String? requiredMessage;

  /// Texto de ayuda (opcional).
  final String? hint;

  /// Valor por defecto (si no hay initialValues).
  final Object? defaultValue;

  /// Validador custom (opcional).
  final FieldValidator? validator;

  /// Hook opcional cuando cambia el valor del campo.
  final FieldOnChanged? onChanged;

  const FieldSpec({
    required this.key,
    required this.label,
    required this.kind,
    this.required = false,
    this.requiredMessage,
    this.hint,
    this.defaultValue,
    this.validator,
    this.onChanged,
  });
}

/// Utilidades de validación comunes (para reutilizar en specs).
class FieldValidators {
  /// Valida número entero.
  static FieldValidator intNumber({
    String message = 'Este campo debe ser numérico.',
  }) {
    return (value, _) {
      if (value == null) return null;
      if (value is int) return null;
      if (value is String) {
        final s = value.trim();
        if (s.isEmpty) return null;
        return int.tryParse(s) == null ? message : null;
      }
      return message;
    };
  }

  /// Valida número decimal (acepta "." o "," como separador).
  static FieldValidator decimalNumber({
    String message = 'Este campo debe ser numérico.',
  }) {
    return (value, _) {
      if (value == null) return null;
      if (value is num) return null;
      if (value is String) {
        final s = value.trim();
        if (s.isEmpty) return null;
        final normalized = s.replaceAll(',', '.');
        return double.tryParse(normalized) == null ? message : null;
      }
      return message;
    };
  }

  /// Valida longitud mínima en texto.
  static FieldValidator minLen(
    int min, {
    String? message,
  }) {
    return (value, _) {
      final s = (value is String) ? value.trim() : '';
      if (s.isEmpty) return null; // si quieres requerido, usa required=true
      if (s.length < min) {
        return message ?? 'Debe tener al menos $min caracteres.';
      }
      return null;
    };
  }

  /// Valida un número (int/double/String numérica) dentro de un rango.
  /// - Si value es null o '' -> OK (para obligatorio usa required=true)
  static FieldValidator numberRange({
    required num min,
    required num max,
    String? message,
  }) {
    return (value, _) {
      if (value == null) return null;
      if (value is String && value.trim().isEmpty) return null;

      num? parsed;
      if (value is num) {
        parsed = value;
      } else if (value is String) {
        final normalized = value.trim().replaceAll(',', '.');
        parsed = double.tryParse(normalized);
      }

      if (parsed == null) {
        return message ?? 'Valor inválido.';
      }
      if (parsed < min || parsed > max) {
        return message ?? 'Debe estar entre $min y $max.';
      }
      return null;
    };
  }

  /// Valida que un número (si viene) sea >= 0.
  static FieldValidator nonNegative({
    String message = 'No puede ser negativo.',
  }) {
    return (value, _) {
      if (value == null) return null;
      if (value is String && value.trim().isEmpty) return null;

      num? parsed;
      if (value is num) {
        parsed = value;
      } else if (value is String) {
        final normalized = value.trim().replaceAll(',', '.');
        parsed = double.tryParse(normalized);
      }

      if (parsed == null) return null; // si quieres “numérico” usa decimalNumber/intNumber
      if (parsed < 0) return message;
      return null;
    };
  }
}
