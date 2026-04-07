// lib/screens/filters/filter_screen.dart

import 'package:flutter/material.dart';

import '../../models/bottom_action.dart';
import '../../widgets/app_scaffold.dart';
import 'filter_definition.dart';
import 'widgets/filter_multi_select.dart';
import 'widgets/filter_number_field.dart';
import 'widgets/filter_searchable_multi_select.dart';
import 'widgets/filter_text_field.dart';

class FilterScreen<T> extends StatefulWidget {
  final String title;
  final T initialValue;
  final List<FilterDefinition<T>> filters;

  final BottomAction? homeAction;
  final BottomAction? backAction;
  final bool Function(T value)? canApply;

  const FilterScreen({
    super.key,
    required this.title,
    required this.initialValue,
    required this.filters,
    this.homeAction,
    this.backAction,
    this.canApply,
  });

  @override
  State<FilterScreen<T>> createState() => _FilterScreenState<T>();
}

class _FilterScreenState<T> extends State<FilterScreen<T>> {
  late T _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _setValue(T v) => setState(() => _value = v);

  void _apply() => Navigator.of(context).pop(_value);

  Object? _emptyValueFor(FilterType type) {
    switch (type) {
      case FilterType.text:
      case FilterType.number:
        return null;
      case FilterType.multiSelect:
      case FilterType.multiSelectSearch:
        return const <String>[];
    }
  }

  bool _hasAnyFilterValue() {
    for (final def in widget.filters) {
      final v = def.getValue(_value);
      if (v == null) continue;
      if (v is String && v.trim().isEmpty) continue;
      if (v is List && v.isEmpty) continue;
      return true;
    }
    return false;
  }

  void _clearAll() {
    var next = _value;
    for (final def in widget.filters) {
      next = def.setValue(next, _emptyValueFor(def.type));
    }
    setState(() => _value = next);
  }

  Widget _buildFilter(FilterDefinition<T> def) {
    switch (def.type) {
      case FilterType.text:
        return FilterTextField<T>(
          definition: def,
          value: _value,
          onChanged: _setValue,
        );

      case FilterType.multiSelect:
        return FilterMultiSelect<T>(
          definition: def,
          value: _value,
          onChanged: _setValue,
        );

      case FilterType.multiSelectSearch:
        return FilterSearchableMultiSelect<T>(
          definition: def,
          value: _value,
          onChanged: _setValue,
        );

      case FilterType.number:
        return FilterNumberField<T>(
          definition: def,
          value: _value,
          onChanged: _setValue,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final applyEnabled = widget.canApply?.call(_value) ?? true;

    final home = widget.homeAction ?? BottomAction.home();
    final back = widget.backAction ?? BottomAction.back();

    final apply = BottomAction.primary(
      id: 'apply',
      icon: Icons.check_rounded,
      enabled: applyEnabled,
      onTap: (_) => _apply(),
    );

    final showClearAll = _hasAnyFilterValue();

    return AppScaffold(
      title: widget.title,
      floatingBar: false,
      left: home,
      center: apply,
      right: back,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final def in widget.filters) ...[
                    _buildFilter(def),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),

          // Botón "Limpiar todos" fijo encima de la bottom bar
          if (showClearAll)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: OutlinedButton.icon(
                onPressed: _clearAll,
                icon: const Icon(Icons.close_rounded),
                label: const Text('Limpiar  '),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFBFE6E3), width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
