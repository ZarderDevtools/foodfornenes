// lib/screens/add_record/form_values.dart

import 'package:flutter/foundation.dart';

/// Estado del formulario para la pantalla genérica de "Añadir registro".
///
/// - Guarda valores por campo (por key)
/// - Guarda errores por campo (para pintarlos debajo del input)
/// - Guarda error global (por ejemplo fallo del backend no asignable a un campo)
///
/// OJO: aquí NO hacemos UI. Solo estado + helpers.
class AddFormValues extends ChangeNotifier {
  AddFormValues({
    Map<String, Object?>? initialValues,
  }) : _values = Map<String, Object?>.from(initialValues ?? const {});

  final Map<String, Object?> _values;

  /// Errores por campo (key -> mensaje).
  final Map<String, String?> _fieldErrors = <String, String?>{};

  /// Error general (arriba del formulario, snack, etc.).
  String? _globalError;

  /// Marca campos tocados (útil si luego quieres validar “on change” solo tras tocar).
  final Set<String> _touched = <String>{};

  // -------------------------
  // Lectura / escritura values
  // -------------------------

  Map<String, Object?> get raw => Map.unmodifiable(_values);

  /// Getter tipado seguro.
  /// Devuelve null si:
  /// - no existe
  /// - es null
  /// - no coincide el tipo T
  T? get<T>(String key) {
    final Object? v = _values[key];
    if (v == null) return null;

    // Caso directo (coincide el tipo)
    if (v is T) return v as T;

    // Caso común: pedimos String y el valor es num/int/etc.
    if (T == String) {
      return v.toString() as T;
    }

    // Caso común: pedimos int/double y el valor es String numérica
    if (T == int && v is String) {
      return int.tryParse(v.trim()) as T?;
    }
    if (T == double && v is String) {
      final normalized = v.trim().replaceAll(',', '.');
      return double.tryParse(normalized) as T?;
    }

    return null;
  }

  Object? operator [](String key) => _values[key];

  void setValue(String key, Object? value, {bool notify = true}) {
    _values[key] = value;
    _touched.add(key);

    // Si el usuario cambia el valor, normalmente interesa limpiar el error del campo
    // (la validación final se hará al guardar).
    _fieldErrors.remove(key);

    if (notify) notifyListeners();
  }

  bool hasValue(String key) => _values.containsKey(key);

  void removeValue(String key, {bool notify = true}) {
    _values.remove(key);
    _fieldErrors.remove(key);
    _touched.remove(key);
    if (notify) notifyListeners();
  }

  // -------------------------
  // Errores
  // -------------------------

  Map<String, String?> get fieldErrors => Map.unmodifiable(_fieldErrors);

  String? fieldError(String key) => _fieldErrors[key];

  bool hasFieldError(String key) => (_fieldErrors[key]?.trim().isNotEmpty ?? false);

  bool get hasAnyFieldErrors => _fieldErrors.values.any((e) => e != null && e.trim().isNotEmpty);

  String? get globalError => _globalError;

  void setFieldError(String key, String? message, {bool notify = true}) {
    if (message == null || message.trim().isEmpty) {
      _fieldErrors.remove(key);
    } else {
      _fieldErrors[key] = message;
    }
    if (notify) notifyListeners();
  }

  void setGlobalError(String? message, {bool notify = true}) {
    _globalError = (message == null || message.trim().isEmpty) ? null : message;
    if (notify) notifyListeners();
  }

  void clearErrors({bool notify = true}) {
    _fieldErrors.clear();
    _globalError = null;
    if (notify) notifyListeners();
  }

  // -------------------------
  // Touched
  // -------------------------

  bool isTouched(String key) => _touched.contains(key);

  void markTouched(String key, {bool notify = true}) {
    _touched.add(key);
    if (notify) notifyListeners();
  }

  void resetTouched({bool notify = true}) {
    _touched.clear();
    if (notify) notifyListeners();
  }

  // -------------------------
  // Utilidades
  // -------------------------

  /// Útil para convertir el estado a un payload (siempre que el backend lo acepte así).
  /// Si necesitas mapping más complejo, se hace en config.onSubmit.
  Map<String, Object?> toMap() => Map<String, Object?>.from(_values);

  /// Atajo típico para campos de texto.
  String textOrEmpty(String key) => (get<String>(key) ?? '').trim();
}
