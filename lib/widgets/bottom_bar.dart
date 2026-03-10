// lib/widgets/bottom_bar.dart

import 'package:flutter/material.dart';
import '../models/bottom_action.dart';

/// Barra inferior con 3 slots fijos: izquierda, centro, derecha.
/// - Cada slot puede ser null -> no se renderiza nada en ese hueco.
/// - Los otros NO se recolocan.
/// - Estética heredada de tu BottomActionBar antiguo (pill + botones circulares).
///
/// Modos:
/// - floating=true  -> devuelve Positioned (para usar dentro de un Stack).
/// - floating=false -> devuelve un widget normal (para usar como bottomNavigationBar).
class BottomBar3Slots extends StatelessWidget {
  final BottomAction? left;
  final BottomAction? center;
  final BottomAction? right;

  /// NUEVO: si true, se pinta flotante (Positioned) dentro de un Stack.
  /// Si false, se pinta como barra normal (ideal para Scaffold.bottomNavigationBar).
  final bool floating;

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

  /// Posicionamiento flotante (solo si floating=true)
  final double horizontalInset; // left/right
  final double bottomInset; // separación sobre el safe area inferior

  const BottomBar3Slots({
    super.key,
    this.left,
    this.center,
    this.right,
    this.floating = true,
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

    final bar = _BarShell(
      leftAction: leftAction,
      centerAction: center,
      rightAction: rightAction,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      accentColor: accentColor,
      iconColor: iconColor,
      height: height,
      bigButtonSize: bigButtonSize,
      sideButtonSize: sideButtonSize,
    );

    if (!floating) {
      // Modo bottomNavigationBar: respetamos safe area desde aquí.
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: horizontalInset,
            right: horizontalInset,
            bottom: bottomInset + safeBottom,
            top: 0,
          ),
          child: bar,
        ),
      );
    }

    // Modo flotante: Positioned dentro de un Stack.
    return Positioned(
      left: horizontalInset,
      right: horizontalInset,
      bottom: bottomInset + safeBottom,
      child: bar,
    );
  }
}

class _BarShell extends StatelessWidget {
  final BottomAction? leftAction;
  final BottomAction? centerAction;
  final BottomAction? rightAction;

  final Color backgroundColor;
  final Color borderColor;
  final Color accentColor;
  final Color iconColor;

  final double height;
  final double bigButtonSize;
  final double sideButtonSize;

  const _BarShell({
    required this.leftAction,
    required this.centerAction,
    required this.rightAction,
    required this.backgroundColor,
    required this.borderColor,
    required this.accentColor,
    required this.iconColor,
    required this.height,
    required this.bigButtonSize,
    required this.sideButtonSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          Expanded(
            child: _Slot(
              action: leftAction,
              alignment: Alignment.centerLeft,
              size: sideButtonSize,
              background: Colors.white,
              borderColor: borderColor,
              iconColor: accentColor,
              forceVariant: BottomActionVariant.normal,
            ),
          ),
          Expanded(
            child: _Slot(
              action: centerAction,
              alignment: Alignment.center,
              size: bigButtonSize,
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
    final hasLabel = (action.label != null && action.label!.trim().isNotEmpty);

    if (!hasLabel) {
      return Icon(action.icon, color: iconColor);
    }

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
