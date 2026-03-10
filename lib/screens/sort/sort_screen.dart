// lib/screens/sort/sort_screen.dart

import "package:flutter/material.dart";

import "../../models/bottom_action.dart";
import "../../widgets/bottom_bar.dart";
import "sort_definition.dart";

class SortScreen extends StatefulWidget {
  final String title;
  final List<SortDefinition> options;

  /// Ordering actual del listado, tal y como se envía a la API:
  /// - null / "" => sin orden
  /// - "name" => asc
  /// - "-name" => desc
  final String? initialOrdering;

  const SortScreen({
    super.key,
    required this.title,
    required this.options,
    this.initialOrdering,
  });

  @override
  State<SortScreen> createState() => _SortScreenState();
}

class _SortScreenState extends State<SortScreen> {
  /// Estado "draft": el usuario toca opciones, pero solo se aplica al pulsar "Aplicar"
  String? _draftOrdering;

  @override
  void initState() {
    super.initState();
    _draftOrdering = (widget.initialOrdering ?? "").trim().isEmpty
        ? null
        : widget.initialOrdering!.trim();
  }

  void _toggleOption(String field) {
    setState(() {
      final opt = widget.options.firstWhere((o) => o.field == field);

      _draftOrdering = SortHelpers.toggleField(
        currentOrdering: _draftOrdering,
        field: field,
        firstTapAsc: opt.humanStringSort,
      );
    });
  }

  void _clear() {
    setState(() {
      _draftOrdering = null;
    });
  }

  void _apply() {
    Navigator.of(context).pop(SortResult.apply(_draftOrdering));
  }

  void _cancel() {
    Navigator.of(context).pop(const SortResult.cancel());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final home = BottomAction.home();

    final back = BottomAction.custom(
      id: "back",
      icon: Icons.arrow_back_rounded,
      onTap: (_) => _cancel(),
    );

    final apply = BottomAction.primary(
      id: "apply",
      icon: Icons.check_rounded,
      onTap: (_) => _apply(),
    );

    final showClear = (_draftOrdering ?? "").trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFF),
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(top: 8, bottom: 96),
        itemCount: widget.options.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final opt = widget.options[index];
          final state = SortHelpers.stateForField(
            ordering: _draftOrdering,
            field: opt.field,
          );

          final isActive = state != SortState.none;

          IconData? icon;
          if (state != SortState.none) {
            final isHumanString = opt.humanStringSort;

            // Para "name" invertimos el significado visual para que sea humano:
            // ASC (A→Z) => flecha abajo
            // DESC (Z→A) => flecha arriba
            if (isHumanString) {
              if (state == SortState.asc) icon = Icons.arrow_downward_rounded;
              if (state == SortState.desc) icon = Icons.arrow_upward_rounded;
            } else {
              // Convención normal (técnica):
              // DESC => flecha abajo, ASC => flecha arriba
              if (state == SortState.desc) icon = Icons.arrow_downward_rounded;
              if (state == SortState.asc) icon = Icons.arrow_upward_rounded;
            }
          }

          return Material(
            color: isActive ? cs.surfaceContainerHighest : Colors.transparent,
            child: ListTile(
              title: Text(
                opt.label,
                style: isActive
                    ? theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      )
                    : theme.textTheme.bodyLarge,
              ),
              trailing: icon == null
                  ? null
                  : Icon(
                      icon,
                      color: cs.primary,
                    ),
              onTap: () => _toggleOption(opt.field),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showClear)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: OutlinedButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text("Limpiar  "),
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
            BottomBar3Slots(
              floating: false,
              left: home,
              center: apply,
              right: back,
            ),
          ],
        ),
      ),
    );
  }
}
