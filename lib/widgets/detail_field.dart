// lib/widgets/detail_field.dart

import 'package:flutter/material.dart';

/// Muestra un campo con etiqueta arriba y valor debajo.
/// Si [value] es null o vacío, muestra "—".
class DetailField extends StatelessWidget {
  final String label;
  final String? value;

  const DetailField({super.key, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayValue = (value == null || value!.trim().isEmpty) ? '—' : value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(displayValue, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

/// Agrupa varios widgets bajo un título de sección.
class DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const DetailSection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}
