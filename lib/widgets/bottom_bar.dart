// lib/widgets/bottom_bar.dart
import 'package:flutter/material.dart';
import '../models/bottom_action.dart';

/// Barra inferior flotante con 3 slots fijos: izquierda, centro, derecha.
/// - Cada slot puede ser null -> no se renderiza nada en ese hueco.
/// - Los otros NO se recolocan.
/// - Estética heredada de tu BottomActionBar antiguo (pill flotante + botones circulares).
///
/// USO: colócala dentro de un Stack (devuelve Positioned).
class BottomBar3Slots extends StatelessWidget {
  final BottomAction? left;
  final BottomAction? center;
  final BottomAction? right;

  /// Permite invertir el orden de los laterales (por si algún día lo necesitas).
  final bool invertSideButtons;

  /// Colores / estética (defaults = tu BottomActionBar antiguo)
  final Color backgroundColor;
  final Color borderColor;
  final Color accentColor;
  final Color iconColor;

  /// Tamaños (defaults = tu BottomActionBar antiguo)
  final double height;
  final double bigButtonSize;
  final double sideButtonSize;

  /// Posicionamiento flotante (defaults = tu BottomActionBar antiguo)
  final double horizontalInset; // left/right
  final double bottomInset; // separación sobre el safe area inferior

  const BottomBar3Slots({
    super.key,
    this.left,
    this.center,
    this.right,
    this.invertSideButtons = false,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFBFE6E3),
    this.accentColor = const Color(0xFF2BB7A9),
    this.iconColor = Colors.white,
    this.height = 92,
    this.bigButtonSize = 70,
    this.sideButtonSize = 54,
    this.horizontalInset = 16,
    this.bottomInset = 12,
  });

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    final leftAction = invertSideButtons ? right : left;
    final rightAction = invertSideButtons ? left : right;

    return Positioned(
      left: horizontalInset,
      right: horizontalInset,
      bottom: bottomInset + safeBottom,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.95),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor, width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          // 3 slots fijos y siempre presentes (aunque estén vacíos)
          children: [
            Expanded(
              child: _Slot(
                action: leftAction,
                alignment: Alignment.centerLeft,
                size: sideButtonSize,
                background: Colors.white,
                borderColor: borderColor,
                iconColor: accentColor,
                // Los laterales no son "primary" visualmente en tu diseño
                forceVariant: BottomActionVariant.normal,
              ),
            ),
            Expanded(
              child: _Slot(
                action: center,
                alignment: Alignment.center,
                size: bigButtonSize,
                // Centro = botón grande con accentColor (como el "+")
                background: accentColor,
                borderColor: Colors.transparent,
                iconColor: iconColor,
                forceVariant: BottomActionVariant.primary,
              ),
            ),
            Expanded(
              child: _Slot(
                action: rightAction,
                alignment: Alignment.centerRight,
                size: sideButtonSize,
                background: Colors.white,
                borderColor: borderColor,
                iconColor: accentColor,
                forceVariant: BottomActionVariant.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  final BottomAction? action;
  final Alignment alignment;

  final double size;
  final Color background;
  final Color borderColor;
  final Color iconColor;

  /// Para clavar el look antiguo:
  /// - laterales siempre estilo "normal"
  /// - centro siempre estilo "primary"
  final BottomActionVariant forceVariant;

  const _Slot({
    required this.action,
    required this.alignment,
    required this.size,
    required this.background,
    required this.borderColor,
    required this.iconColor,
    required this.forceVariant,
  });

  @override
  Widget build(BuildContext context) {
    if (action == null) {
      // Hueco vacío, sin recolocar el resto
      return const SizedBox.shrink();
    }

    return Align(
      alignment: alignment,
      child: _CircleActionButton(
        action: action!,
        size: size,
        background: background,
        borderColor: borderColor,
        iconColor: iconColor,
        variant: forceVariant,
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final BottomAction action;
  final double size;
  final Color background;
  final Color borderColor;
  final Color iconColor;
  final BottomActionVariant variant;

  const _CircleActionButton({
    required this.action,
    required this.size,
    required this.background,
    required this.borderColor,
    required this.iconColor,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = action.enabled;

    return InkWell(
      onTap: isEnabled ? () => action.onTap(context) : null,
      borderRadius: BorderRadius.circular(999),
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.45,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Center(
            child: _buildChild(),
          ),
        ),
      ),
    );
  }

  Widget _buildChild() {
    // Para clavar el diseño antiguo:
    // - laterales: icono (home/back) con color accentColor
    // - centro: normalmente era "+", pero ahora usaremos icono si no hay label
    //   y si hay label, mostramos label (opcional).
    final hasLabel = (action.label != null && action.label!.trim().isNotEmpty);

    if (!hasLabel) {
      return Icon(action.icon, color: iconColor);
    }

    // Si alguna vez quieres label en el botón circular, lo permitimos
    // (no era lo típico en tu diseño, pero te da flexibilidad).
    return Text(
      action.label!,
      style: TextStyle(
        fontSize: variant == BottomActionVariant.primary ? 16 : 14,
        fontWeight: FontWeight.w600,
        color: iconColor,
        height: 1.0,
      ),
      textAlign: TextAlign.center,
    );
  }
}
