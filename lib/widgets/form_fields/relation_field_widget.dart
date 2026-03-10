// lib/widgets/form_fields/relation_field_widget.dart

import 'package:flutter/material.dart';

import '../../screens/add_record/form_values.dart';
import 'relation_field_spec.dart';

/// Selector de relación con búsqueda.
///
/// Guarda:
/// - spec.key                -> id (String)
/// - "${spec.key}__label"    -> label (String)
///
/// ✅ Botón opcional debajo ("Añadir X"):
/// Si `spec.onCreate` existe, al pulsarlo abre el flow y:
/// - si vuelve con un item creado, lo auto-selecciona (id + label)
/// - también dispara `spec.onChanged` / `spec.onIdChanged` via notifyChanged()
class RelationFieldWidget extends StatelessWidget {
  final RelationFieldSpec spec;
  final AddFormValues values;
  final String? errorText;

  const RelationFieldWidget({
    super.key,
    required this.spec,
    required this.values,
    required this.errorText,
  });

  String get _labelKey => '${spec.key}__label';

  @override
  Widget build(BuildContext context) {
    final enabled = (spec.isEnabled != null) ? spec.isEnabled!(values) : true;

    final selectedId = values[spec.key];

    final cachedLabel = values.get<String>(_labelKey);
    final fallbackLabel =
        (selectedId != null) ? spec.getLabelForStoredValue(selectedId) : null;

    final selectedLabel = (cachedLabel != null && cachedLabel.trim().isNotEmpty)
        ? cachedLabel
        : (fallbackLabel ?? '');

    final canCreate = spec.onCreate != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: enabled
              ? () async {
                  final selected = await _openSelector(context);
                  if (selected != null) {
                    final id = spec.getId(selected);
                    final label = spec.getLabel(selected);

                    values.setValue(spec.key, id);
                    values.setValue(_labelKey, label);

                    spec.notifyChanged(id, values);
                  }
                }
              : null,
          child: InputDecorator(
            isEmpty: selectedLabel.trim().isEmpty,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: const OutlineInputBorder(),
              errorText: errorText,
              hintText: enabled
                  ? spec.placeholder
                  : (spec.disabledMessage ?? spec.placeholder),
            ),
            child: Text(
              selectedLabel,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        if (canCreate) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: Text(
              (spec.createLabel != null && spec.createLabel!.trim().isNotEmpty)
                  ? spec.createLabel!
                  : 'Añadir ${spec.label}',
            ),
            onPressed: enabled
                ? () async {
                    final created = await spec.onCreate!(values);
                    if (created == null) return;

                    final id = spec.getId(created);
                    final label = spec.getLabel(created);

                    values.setValue(spec.key, id);
                    values.setValue(_labelKey, label);

                    spec.notifyChanged(id, values);
                  }
                : null,
          ),
        ],
      ],
    );
  }

  Future<dynamic> _openSelector(BuildContext context) async {
    return showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RelationSearchModal(
        spec: spec,
        values: values,
      ),
    );
  }
}

class _RelationSearchModal extends StatefulWidget {
  final RelationFieldSpec spec;
  final AddFormValues values;

  const _RelationSearchModal({
    required this.spec,
    required this.values,
  });

  @override
  State<_RelationSearchModal> createState() => _RelationSearchModalState();
}

class _RelationSearchModalState extends State<_RelationSearchModal> {
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
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

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
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final item = _items[i];
                            final label = widget.spec.getLabel(item);

                            return ListTile(
                              title: Text(label),
                              onTap: () => Navigator.of(context).pop(item),
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
