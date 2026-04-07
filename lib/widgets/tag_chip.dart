// lib/widgets/tag_chip.dart

import 'package:flutter/material.dart';

/// Chip visual para mostrar una etiqueta (tag).
/// Mismo estilo que los chips del listado.
class TagChip extends StatelessWidget {
  final String label;

  const TagChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFE6E3), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF2BB7A9),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
