// lib/widgets/form_fields/multi_relation_field_spec.dart

import '../../screens/add_record/form_values.dart';
import 'field_spec.dart';
import 'relation_field_spec.dart' show RelationFetcher;

/// Spec para selección múltiple de una entidad relacionada.
///
/// Guarda en [AddFormValues]:
///   - spec.key                → List<String>  (ids seleccionados)
///   - "${spec.key}__labels"   → List<String>  (labels en paralelo para UI)
///
/// Uso en onSubmit:
///   final ids = values.get<List<String>>('tags') ?? [];
class MultiRelationFieldSpec<T> extends FieldSpec {
  /// Carga el listado de opciones disponibles (con búsqueda opcional).
  final RelationFetcher<T> fetchItems;

  /// Convierte un item a su id (String).
  final String Function(T item) getId;

  /// Convierte un item a su label visible.
  final String Function(T item) getLabel;

  /// Texto del botón/área de apertura del selector.
  final String placeholder;

  /// Hint para el buscador del modal.
  final String searchHint;

  /// Texto del botón para crear una nueva entidad (opcional).
  final String? createLabel;

  /// Acción de crear. Si devuelve un T, se autoañade a la selección.
  final Future<T?> Function(AddFormValues values)? onCreate;

  const MultiRelationFieldSpec({
    required super.key,
    required super.label,
    super.hint,
    super.required = false,
    super.requiredMessage,
    super.defaultValue,
    super.validator,
    super.onChanged,
    required this.fetchItems,
    required this.getId,
    required this.getLabel,
    this.placeholder = 'Añadir…',
    this.searchHint = 'Buscar…',
    this.createLabel,
    this.onCreate,
  }) : super(kind: FieldKind.multiRelation);

  // ── Despacho tipado (evita el error de contravarianza) ──────────────────
  String labelOf(dynamic item) => getLabel(item as T);
  String idOf(dynamic item) => getId(item as T);
}
