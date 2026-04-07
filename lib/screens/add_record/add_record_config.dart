// lib/screens/add_record/add_record_config.dart

import 'package:flutter/material.dart';

import '../../models/bottom_action.dart';
import '../../widgets/form_fields/field_spec.dart';
import 'form_values.dart';

/// Configuración (contrato) para la pantalla genérica de "Añadir registro".
///
/// La idea es que cada "AddXFlow" (AddFood, AddVisit, etc.) construya un AddRecordConfig
/// con:
/// - título
/// - lista declarativa de campos (FieldSpec)
/// - onSubmit (qué hacer al guardar)
///
/// La pantalla genérica se encarga de:
/// - pintar UI con el estilo de Filtros
/// - validar campos
/// - mostrar errores por campo y global
/// - ejecutar onSubmit y cerrar la pantalla si todo va bien
class AddRecordConfig {
  /// Título de la pantalla (AppBar).
  final String title;

  /// Lista declarativa de campos a renderizar.
  final List<FieldSpec> fields;

  /// Acción principal: construir payload y guardar.
  /// Si termina sin excepción, se considera guardado OK.
  final Future<void> Function(AddFormValues values) onSubmit;

  /// Acciones de la bottom bar.
  /// IMPORTANTE: orden de tu app:
  /// - left  -> Home
  /// - center -> Guardar
  /// - right -> Back
  final BottomAction? homeAction;
  final BottomAction? backAction;

  /// Si quieres bloquear "Guardar" hasta que se cumpla algo.
  /// (Ej: si no hay cambios, o si falta un campo clave)
  final bool Function(AddFormValues values)? canSubmit;

  /// Texto opcional para el botón central.
  final String submitLabel;

  /// Icono del botón central.
  final IconData submitIcon;

  /// Valores iniciales (útil para editar o duplicar).
  /// Si no se pasa nada, el formulario parte vacío con defaults de cada FieldSpec.
  final Map<String, Object?>? initialValues;

  /// Widget opcional renderizado encima de los campos del formulario.
  /// Útil para mostrar información de solo lectura (ej: estadísticas en edición).
  final Widget? header;

  const AddRecordConfig({
    required this.title,
    required this.fields,
    required this.onSubmit,
    this.homeAction,
    this.backAction,
    this.canSubmit,
    this.submitLabel = 'Guardar',
    this.submitIcon = Icons.check_rounded,
    this.initialValues,
    this.header,
  });
}
