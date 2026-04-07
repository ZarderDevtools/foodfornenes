// lib/widgets/app_scaffold.dart

import 'package:flutter/material.dart';

import '../models/bottom_action.dart';
import 'bottom_bar.dart';

/// Widget base para pantallas de la app.
///
/// Centraliza:
/// - Fondo común (Color(0xFFF6FBFF))
/// - Barra inferior con hasta 3 slots (izquierda / centro / derecha)
///
/// [floatingBar] controla el modo de la barra inferior:
/// - `true` (default): barra flotante dentro de un Stack (patrón HomeScreen)
/// - `false`: barra como `bottomNavigationBar` del Scaffold (patrón AddRecordScreen)
///
/// Uso modo flotante (sin AppBar):
/// ```dart
/// AppScaffold(
///   left: BottomAction.home(),
///   center: BottomAction.primary(icon: Icons.add, onTap: (_) => ...),
///   right: BottomAction.back(),
///   child: MiContenido(),
/// )
/// ```
///
/// Uso modo no flotante (con AppBar):
/// ```dart
/// AppScaffold(
///   title: 'Mi pantalla',
///   floatingBar: false,
///   left: BottomAction.home(),
///   center: BottomAction.primary(icon: Icons.save, onTap: (_) => ...),
///   right: BottomAction.back(),
///   child: MiContenido(),
/// )
/// ```
///
/// Si todas las acciones son null, no se renderiza la barra inferior.
class AppScaffold extends StatelessWidget {
  /// Contenido principal de la pantalla.
  final Widget child;

  /// Título del AppBar. Si es null, no se muestra AppBar.
  final String? title;

  /// Slot izquierdo de la barra. Si es null, ese espacio queda vacío.
  final BottomAction? left;

  /// Slot central de la barra (botón primario). Si es null, ese espacio queda vacío.
  final BottomAction? center;

  /// Slot derecho de la barra. Si es null, ese espacio queda vacío.
  final BottomAction? right;

  /// Si `true` (default), la barra flota sobre el contenido dentro de un Stack.
  /// Si `false`, la barra se coloca como `bottomNavigationBar` del Scaffold.
  final bool floatingBar;

  const AppScaffold({
    super.key,
    required this.child,
    this.title,
    this.left,
    this.center,
    this.right,
    this.floatingBar = true,
  });

  bool get _hasBar => left != null || center != null || right != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFF),
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              centerTitle: true,
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xFFF6FBFF),
            )
          : null,
      body: SafeArea(
        child: floatingBar && _hasBar
            ? Stack(
                children: [
                  child,
                  BottomBar3Slots(
                    floating: true,
                    left: left,
                    center: center,
                    right: right,
                  ),
                ],
              )
            : child,
      ),
      bottomNavigationBar: !floatingBar && _hasBar
          ? BottomBar3Slots(
              floating: false,
              left: left,
              center: center,
              right: right,
            )
          : null,
    );
  }
}
