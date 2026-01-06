// lib/models/bottom_action.dart
import 'package:flutter/material.dart';
import '../config/app_icons.dart';

/// Estilo visual sugerido para el botón.
/// (Puedes ampliarlo luego sin romper llamadas existentes)
enum BottomActionVariant { normal, primary, danger }

/// Modelo (NO widget) que describe una acción de la bottom bar.
class BottomAction {
  final String? id;
  final IconData icon;
  final String? label;

  /// Si está deshabilitado, el botón no ejecuta onTap.
  final bool enabled;

  /// Variante visual (normal/primary/danger)
  final BottomActionVariant variant;

  /// Acción a ejecutar. Recibe BuildContext para navegar fácil.
  final void Function(BuildContext context) onTap;

  /// Payload opcional por si te viene bien pasar datos extra sin crear 20 clases.
  final Object? payload;

  const BottomAction._({
    this.id,
    required this.icon,
    this.label,
    required this.enabled,
    required this.variant,
    required this.onTap,
    this.payload,
  });

  // -------------------------
  // Factories (opción A)
  // -------------------------

  /// Botón Back estándar.
  factory BottomAction.back({
    String? id,
    String? label,
    bool enabled = true,
    Object? payload,
  }) {
    return BottomAction._(
      id: id ?? 'back',
      icon: AppIcons.back,
      label: label,
      enabled: enabled,
      variant: BottomActionVariant.normal,
      payload: payload,
      onTap: (ctx) {
        if (!enabled) return;
        Navigator.of(ctx).maybePop();
      },
    );
  }

  /// Botón Home estándar. Lleva a la ruta '/home' por defecto.
  factory BottomAction.home({
    String? id,
    String? label,
    bool enabled = true,
    String homeRouteName = '/home',
    Object? payload,
  }) {
    return BottomAction._(
      id: id ?? 'home',
      icon: AppIcons.home,
      label: label,
      enabled: enabled,
      variant: BottomActionVariant.normal,
      payload: payload,
      onTap: (ctx) {
        if (!enabled) return;
        Navigator.of(ctx).pushNamedAndRemoveUntil(homeRouteName, (route) => false);
      },
    );
  }

  /// Acción "principal" (ej: Guardar, Crear…)
  factory BottomAction.primary({
    String? id,
    required IconData icon,
    required void Function(BuildContext context) onTap,
    String? label,
    bool enabled = true,
    Object? payload,
  }) {
    return BottomAction._(
      id: id,
      icon: icon,
      label: label,
      enabled: enabled,
      variant: BottomActionVariant.primary,
      payload: payload,
      onTap: (ctx) {
        if (!enabled) return;
        onTap(ctx);
      },
    );
  }

  /// Acción custom (normal).
  factory BottomAction.custom({
    String? id,
    required IconData icon,
    required void Function(BuildContext context) onTap,
    String? label,
    bool enabled = true,
    BottomActionVariant variant = BottomActionVariant.normal,
    Object? payload,
  }) {
    return BottomAction._(
      id: id,
      icon: icon,
      label: label,
      enabled: enabled,
      variant: variant,
      payload: payload,
      onTap: (ctx) {
        if (!enabled) return;
        onTap(ctx);
      },
    );
  }

  /// Utilidad por si en algún momento quieres “clonar” y ajustar algo.
  BottomAction copyWith({
    String? id,
    IconData? icon,
    String? label,
    bool? enabled,
    BottomActionVariant? variant,
    void Function(BuildContext context)? onTap,
    Object? payload,
  }) {
    return BottomAction._(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      label: label ?? this.label,
      enabled: enabled ?? this.enabled,
      variant: variant ?? this.variant,
      onTap: onTap ?? this.onTap,
      payload: payload ?? this.payload,
    );
  }
}
