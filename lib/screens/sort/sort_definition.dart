// lib/screens/sort/sort_definition.dart

/// Estados posibles para una opción de orden:
/// - none: sin ordenar por este campo
/// - desc: descendente (API: "-field")
/// - asc: ascendente  (API: "field")
enum SortState {
  none,
  desc,
  asc,
}

extension SortStateX on SortState {
  /// Ciclo que quieres: DESC -> ASC -> NONE (y vuelve a DESC)
  SortState next() {
    switch (this) {
      case SortState.none:
        return SortState.desc;
      case SortState.desc:
        return SortState.asc;
      case SortState.asc:
        return SortState.none;
    }
  }

  bool get isApplied => this != SortState.none;
}

/// Definición “estática” de una opción de orden.
/// Esto es lo que cada listado pasa al SortScreen.
class SortDefinition {
  /// Texto que ve el usuario (ej: "Nombre", "Última visita")
  final String label;

  /// Campo de la API (ej: "name", "created_at", "avg_rating")
  final String field;

  /// Si true, aplicamos comportamiento “humano” para strings:
  /// - primer toque: ASC (A→Z)
  /// - flecha ↓ significa ASC (A→Z)
  /// - flecha ↑ significa DESC (Z→A)
  final bool humanStringSort;

  const SortDefinition({
    required this.label,
    required this.field,
    this.humanStringSort = false,
  });
}

/// Selección actual de orden (un único campo activo, o ninguno).
class SortSelection {
  final String? field; // null => sin ordenar
  final SortState state;

  const SortSelection({
    required this.field,
    required this.state,
  });

  const SortSelection.none()
      : field = null,
        state = SortState.none;

  bool get isApplied => field != null && state.isApplied;

  /// Convierte la selección a lo que espera la API en ?ordering=
  /// - null si no hay orden
  /// - "field" asc
  /// - "-field" desc
  String? toOrderingParam() {
    if (!isApplied) return null;
    if (state == SortState.desc) return "-$field";
    // asc
    return field;
  }

  /// Crea una selección a partir de un ordering (ej: "-name", "created_at", null)
  /// Si ordering apunta a un field que no coincide con los disponibles, igualmente lo parsea.
  static SortSelection fromOrderingParam(String? ordering) {
    final raw = (ordering ?? "").trim();
    if (raw.isEmpty) return const SortSelection.none();

    if (raw.startsWith("-") && raw.length > 1) {
      return SortSelection(field: raw.substring(1), state: SortState.desc);
    }
    return SortSelection(field: raw, state: SortState.asc);
  }
}

/// Helpers útiles para el SortScreen
class SortHelpers {
  /// Dado el ordering actual, devuelve el SortState para un field concreto.
  static SortState stateForField({
    required String? ordering,
    required String field,
  }) {
    final sel = SortSelection.fromOrderingParam(ordering);
    if (sel.field != field) return SortState.none;
    return sel.state;
  }

  /// Aplica el toggle de 3 estados sobre un campo, cumpliendo:
  /// - Solo 1 campo activo a la vez
  /// - Ciclo: DESC -> ASC -> NONE
  ///
  /// Devuelve el nuevo orderingParam (String?) resultante.s
  static String? toggleField({
    required String? currentOrdering,
    required String field,
    bool firstTapAsc = false,
  }) {
    final current = SortSelection.fromOrderingParam(currentOrdering);

    // Si estamos tocando un field distinto al activo,
    // empezamos en ASC o DESC según el tipo de campo.
    if (current.field != field) {
      final first = firstTapAsc ? SortState.asc : SortState.desc;
      return SortSelection(field: field, state: first).toOrderingParam();
    }

    // Si es el mismo, avanzamos el ciclo
    // Para strings (firstTapAsc=true) queremos: ASC -> DESC -> NONE
    // Para el resto seguimos: DESC -> ASC -> NONE
    final SortState nextState;
    if (firstTapAsc) {
      switch (current.state) {
        case SortState.none:
          nextState = SortState.asc;
          break;
        case SortState.asc:
          nextState = SortState.desc;
          break;
        case SortState.desc:
          nextState = SortState.none;
          break;
      }
    } else {
      nextState = current.state.next();
    }
    final nextSelection = (nextState == SortState.none)
        ? const SortSelection.none()
        : SortSelection(field: field, state: nextState);

    return nextSelection.toOrderingParam();
  }
}

class SortResult {
  final bool applied;
  final String? ordering;

  const SortResult._({
    required this.applied,
    required this.ordering,
  });

  /// El usuario canceló / volvió atrás -> no se aplica nada
  const SortResult.cancel() : this._(applied: false, ordering: null);

  /// El usuario pulsó Aplicar -> se aplica el ordering (puede ser null si limpió)
  const SortResult.apply(String? ordering)
      : this._(applied: true, ordering: ordering);

  bool get isApplied => applied;
}