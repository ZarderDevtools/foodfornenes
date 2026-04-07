// lib/screens/filters/widgets/filter_searchable_multi_select.dart

import 'package:flutter/material.dart';
import '../filter_definition.dart';

/// Filtro multi-select escalable: muestra un campo compacto con el resumen
/// de la selección actual y abre un bottom sheet con búsqueda al pulsarlo.
/// Adecuado cuando las opciones pueden ser muchas (áreas, etc.).
class FilterSearchableMultiSelect<T> extends StatelessWidget {
  final FilterDefinition<T> definition;
  final T value;
  final void Function(T) onChanged;

  const FilterSearchableMultiSelect({
    super.key,
    required this.definition,
    required this.value,
    required this.onChanged,
  });

  Future<void> _openSheet(BuildContext context) async {
    final options = definition.options ?? const <FilterOption>[];
    final raw = definition.getValue(value);
    final initialSelected = <String>{
      if (raw is List<String>) ...raw.map((e) => e.trim()).where((e) => e.isNotEmpty),
    };

    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SelectionSheet(
        title: definition.label,
        options: options,
        initialSelected: initialSelected,
      ),
    );

    if (result == null) return;
    onChanged(definition.setValue(value, result));
  }

  @override
  Widget build(BuildContext context) {
    final raw = definition.getValue(value);
    final selected = raw is List<String> ? raw : const <String>[];
    final count = selected.length;
    final hasSelection = count > 0;

    const accent = Color(0xFF2BB7A9);
    const border = Color(0xFFBFE6E3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          definition.label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => _openSheet(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasSelection ? accent : border,
                width: hasSelection ? 1.5 : 1.2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasSelection
                        ? '$count ${count == 1 ? "seleccionada" : "seleccionadas"}'
                        : 'Todas',
                    style: TextStyle(
                      color: hasSelection ? accent : Colors.black54,
                      fontWeight:
                          hasSelection ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: hasSelection ? accent : border,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Bottom sheet de selección ────────────────────────────────────────────────

class _SelectionSheet extends StatefulWidget {
  final String title;
  final List<FilterOption> options;
  final Set<String> initialSelected;

  const _SelectionSheet({
    required this.title,
    required this.options,
    required this.initialSelected,
  });

  @override
  State<_SelectionSheet> createState() => _SelectionSheetState();
}

class _SelectionSheetState extends State<_SelectionSheet> {
  late Set<String> _selected;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initialSelected);
  }

  List<FilterOption> get _filtered {
    if (_search.isEmpty) return widget.options;
    final q = _search.toLowerCase();
    return widget.options
        .where((o) => o.label.toLowerCase().contains(q))
        .toList();
  }

  void _toggle(String optValue) {
    setState(() {
      if (_selected.contains(optValue)) {
        _selected.remove(optValue);
      } else {
        _selected.add(optValue);
      }
    });
  }

  void _apply() {
    // Mantiene el orden de opciones para consistencia
    final ordered = widget.options
        .map((o) => o.value)
        .where(_selected.contains)
        .toList();
    Navigator.of(context).pop(ordered);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF6FBFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // ── Cabecera ──────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  children: [
                    // Handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBFE6E3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 14),
                    // Buscador
                    TextField(
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFBFE6E3), width: 1.2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFBFE6E3), width: 1.2),
                        ),
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // ── Lista ─────────────────────────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'Sin resultados',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final opt = filtered[i];
                          final isSelected = _selected.contains(opt.value);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(opt.label),
                            activeColor: const Color(0xFF2BB7A9),
                            checkColor: Colors.white,
                            onChanged: (_) => _toggle(opt.value),
                            controlAffinity: ListTileControlAffinity.trailing,
                          );
                        },
                      ),
              ),

              // ── Botón Aplicar ─────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2BB7A9),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _apply,
                    child: Text(
                      _selected.isEmpty
                          ? 'Mostrar todas'
                          : 'Aplicar (${_selected.length})',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
