// lib/screens/filters/filter_definition.dart

/// Tipos de filtros soportados por la pantalla genérica.
/// (La UI se implementará después)
enum FilterType {
  text,               // TextBox simple
  multiSelect,        // Chips: selección múltiple (pocas opciones fijas)
  multiSelectSearch,  // Campo compacto + bottom sheet con búsqueda (muchas opciones)
  number,             // Número (ej: rating, precio)
}

/// Definición genérica de un filtro.
/// Describe QUÉ es el filtro, no CÓMO se pinta.
class FilterDefinition<T> {
  /// Identificador único del filtro (ej: "name", "price_range")
  final String id;

  /// Título que se muestra en la UI
  final String label;

  /// Tipo de filtro (textbox, multi, número…)
  final FilterType type;

  /// Obtiene el valor actual desde el estado T
  final Object? Function(T state) getValue;

  /// Devuelve un nuevo estado T con el valor actualizado
  final T Function(T state, Object? value) setValue;

  /// Opciones posibles (solo para multiSelect)
  final List<FilterOption>? options;

  const FilterDefinition({
    required this.id,
    required this.label,
    required this.type,
    required this.getValue,
    required this.setValue,
    this.options,
  });
}

/// Opción de un filtro multiSelect
class FilterOption {
  final String value;
  final String label;

  const FilterOption({
    required this.value,
    required this.label,
  });
}
