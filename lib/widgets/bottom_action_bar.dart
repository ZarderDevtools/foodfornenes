import 'package:flutter/material.dart';

/// Barra inferior reutilizable (Sección 3)
/// - Modo home: solo botón central "+"
/// - Modo navegación: [home] [+] [back]
///
/// Nota: el botón "<" debe hacer pop() (lo controlamos con Navigator.pop).
class BottomActionBar extends StatelessWidget {
  /// Si true: muestra [home] [+] [back].
  /// Si false: solo muestra [+].
  final bool showNavigation;

  /// Acción del botón central "+"
  final VoidCallback onPlus;

  /// Acción del botón Home (si showNavigation=true).
  /// Si no se pasa, por defecto hace Navigator.popUntil(route.isFirst)
  final VoidCallback? onHome;

  /// Acción del botón Back (si showNavigation=true).
  /// Si no se pasa, por defecto hace Navigator.pop()
  final VoidCallback? onBack;

  /// Permite invertir el orden de los botones laterales (home <-> back)
  /// para una futura opción de ajustes.
  final bool invertSideButtons;

  /// Textos/estética
  final Color backgroundColor;
  final Color borderColor;
  final Color accentColor;
  final Color iconColor;

  /// Tamaños
  final double height;
  final double bigButtonSize;
  final double sideButtonSize;

  const BottomActionBar({
    super.key,
    required this.onPlus,
    this.showNavigation = false,
    this.onHome,
    this.onBack,
    this.invertSideButtons = false,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFBFE6E3),
    this.accentColor = const Color(0xFF2BB7A9),
    this.iconColor = Colors.white,
    this.height = 92,
    this.bigButtonSize = 70,
    this.sideButtonSize = 54,
  });

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    // Defaults
    final defaultHome = () =>
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    final defaultBack = () => Navigator.of(context).maybePop();

    final homeBtn = _CircleButton(
      size: sideButtonSize,
      background: Colors.white,
      borderColor: borderColor,
      onTap: onHome ?? defaultHome,
      child: Icon(Icons.home_rounded, color: accentColor),
    );

    final backBtn = _CircleButton(
      size: sideButtonSize,
      background: Colors.white,
      borderColor: borderColor,
      onTap: onBack ?? defaultBack,
      child: Icon(Icons.arrow_back_rounded, color: accentColor),
    );

    final plusBtn = _CircleButton(
      size: bigButtonSize,
      background: accentColor,
      borderColor: Colors.transparent,
      onTap: onPlus,
      child: Text(
        "+",
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: iconColor,
          height: 1.0,
        ),
      ),
    );

    final left = invertSideButtons ? backBtn : homeBtn;
    final right = invertSideButtons ? homeBtn : backBtn;

    return Positioned(
      left: 16,
      right: 16,
      bottom: 12 + safeBottom,
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
        child: showNavigation
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  left,
                  plusBtn,
                  right,
                ],
              )
            : Center(child: plusBtn),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final double size;
  final Color background;
  final Color borderColor;
  final VoidCallback onTap;
  final Widget child;

  const _CircleButton({
    required this.size,
    required this.background,
    required this.borderColor,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
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
        child: Center(child: child),
      ),
    );
  }
}
