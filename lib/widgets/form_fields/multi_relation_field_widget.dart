// lib/widgets/form_fields/multi_relation_field_widget.dart

import 'package:flutter/material.dart';

import '../../screens/add_record/form_values.dart';
import 'multi_relation_field_spec.dart';

/// Widget de selección múltiple relacional.
///
/// Muestra los items ya seleccionados como chips con botón de quitar (×).
/// Un botón [placeholder] abre el modal de búsqueda/selección.
/// Si spec.onCreate está configurado, aparece una opción "Añadir nuevo X"
/// dentro del modal, igual que en RelationFieldWidget.
class MultiRelationFieldWidget extends StatelessWidget {
  final MultiRelationFieldSpec spec;
  final AddFormValues values;
  final String? errorText;

  const MultiRelationFieldWidget({
    super.key,
    required this.spec,
    required this.values,
    required this.errorText,
  });

  String get _labelsKey => '${spec.key}__labels';

  List<String> get _selectedIds =>
      (values.get<List>('${spec.key}') as List?)?.cast<String>() ?? [];

  List<String> get _selectedLabels =>
      (values.get<List>(_labelsKey) as List?)?.cast<String>() ?? [];

  void _removeAt(int index) {
    final ids = List<String>.from(_selectedIds);
    final labels = List<String>.from(_selectedLabels);
    ids.removeAt(index);
    labels.removeAt(index);
    values.setValue(spec.key, ids);
    values.setValue(_labelsKey, labels);
  }

  void _addItem(dynamic item) {
    final id = spec.idOf(item);
    final label = spec.labelOf(item);

    final ids = List<String>.from(_selectedIds);
    if (ids.contains(id)) return; // ya seleccionado
    ids.add(id);

    final labels = List<String>.from(_selectedLabels);
    labels.add(label);

    values.setValue(spec.key, ids);
    values.setValue(_labelsKey, labels);

    if (spec.onChanged != null) spec.onChanged!(ids, values);
  }

  Future<void> _openSelector(BuildContext context) async {
    final selected = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MultiRelationModal(
        spec: spec,
        currentIds: _selectedIds,
        values: values,
      ),
    );
    if (selected != null) {
      _addItem(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ids = _selectedIds;
    final labels = _selectedLabels;
    final hasError = errorText != null && errorText!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Chips de items seleccionados ────────────────────────────────────
        if (ids.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (int i = 0; i < ids.length; i++)
                Chip(
                  label: Text(
                    i < labels.length ? labels[i] : ids[i],
                    style: const TextStyle(fontSize: 13),
                  ),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => _removeAt(i),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // ── Botón para abrir el selector ────────────────────────────────────
        OutlinedButton.icon(
          icon: const Icon(Icons.add, size: 18),
          label: Text(spec.placeholder),
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            side: BorderSide(
              color: hasError
                  ? Theme.of(context).colorScheme.error
                  : const Color(0xFFBFE6E3),
              width: 1.2,
            ),
          ),
          onPressed: () => _openSelector(context),
        ),

        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Modal de búsqueda y selección ──────────────────────────────────────────

class _MultiRelationModal extends StatefulWidget {
  final MultiRelationFieldSpec spec;
  final List<String> currentIds;
  final AddFormValues values;

  const _MultiRelationModal({
    required this.spec,
    required this.currentIds,
    required this.values,
  });

  @override
  State<_MultiRelationModal> createState() => _MultiRelationModalState();
}

class _MultiRelationModalState extends State<_MultiRelationModal> {
  final TextEditingController _searchCtrl = TextEditingController();

  bool _loading = false;
  String? _error;
  List<dynamic> _items = const [];

  @override
  void initState() {
    super.initState();
    _load('');
  }

  Future<void> _load(String search) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await widget.spec.fetchItems(search, widget.values);
      if (!mounted) return;
      setState(() => _items = res);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _items = const [];
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _isSelected(dynamic item) =>
      widget.currentIds.contains(widget.spec.idOf(item));

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.72;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 12,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Buscador ──────────────────────────────────────────────────
              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: widget.spec.searchHint,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                onChanged: _load,
              ),
              const SizedBox(height: 12),

              // ── Opción "Añadir nuevo X" ───────────────────────────────────
              if (widget.spec.onCreate != null) ...[
                ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.add_circle_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    (widget.spec.createLabel != null &&
                            widget.spec.createLabel!.trim().isNotEmpty)
                        ? widget.spec.createLabel!
                        : 'Añadir ${widget.spec.label}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    final created =
                        await widget.spec.onCreate!(widget.values);
                    if (created != null && context.mounted) {
                      Navigator.of(context).pop(created);
                    }
                  },
                ),
                const Divider(height: 1),
                const SizedBox(height: 4),
              ],

              // ── Listado ───────────────────────────────────────────────────
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                )
              else if (_error != null)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 32),
                          const SizedBox(height: 10),
                          const Text('Error cargando resultados'),
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _load(_searchCtrl.text),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: _items.isEmpty
                      ? const Center(child: Text('Sin resultados'))
                      : ListView.separated(
                          itemCount: _items.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final item = _items[i];
                            final label = widget.spec.labelOf(item);
                            final selected = _isSelected(item);

                            return ListTile(
                              title: Text(label),
                              trailing: selected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    )
                                  : null,
                              // Items ya seleccionados aparecen deshabilitados
                              // para no confundir: no se pueden duplicar.
                              enabled: !selected,
                              onTap: selected
                                  ? null
                                  : () => Navigator.of(context).pop(item),
                            );
                          },
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
