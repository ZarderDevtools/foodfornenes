// lib/screens/filters/widgets/filter_multi_select.dart

import 'package:flutter/material.dart';
import '../filter_definition.dart';

/// Multi-selección genérica (chips/pills) para filtros.
/// - value esperado: List<String>? (por ejemplo ["€", "€€"])
/// - options: definition.options (lista de FilterOption)
class FilterMultiSelect<T> extends StatelessWidget {
  final FilterDefinition<T> definition;
  final T value;
  final void Function(T) onChanged;

  const FilterMultiSelect({
    super.key,
    required this.definition,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = definition.options ?? const <FilterOption>[];

    final raw = definition.getValue(value);

    final selected = <String>{
      if (raw is List<String>) ...raw.map((e) => e.trim()).where((e) => e.isNotEmpty),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          definition.label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final opt in options)
              _ChoiceChip(
                label: opt.label,
                selected: selected.contains(opt.value),
                onTap: () {
                  final next = Set<String>.from(selected);
                  if (next.contains(opt.value)) {
                    next.remove(opt.value);
                  } else {
                    next.add(opt.value);
                  }

                  // Mantener orden estable según options
                  final ordered = options
                      .map((o) => o.value)
                      .where((v) => next.contains(v))
                      .toList();

                  onChanged(definition.setValue(value, ordered));
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFFBFE6E3);
    const accent = Color(0xFF2BB7A9);

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? accent : border,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? accent : Colors.black87,
          ),
        ),
      ),
    );
  }
}
