// lib/widgets/form_fields/relation_field_spec.dart

import '../../screens/add_record/form_values.dart';
import 'field_spec.dart';

typedef RelationFetcher<T> = Future<List<T>> Function(String search, AddFormValues values);

class RelationFieldSpec<T> extends FieldSpec {
  final RelationFetcher<T> fetchItems;

  /// Convierte el item a id (String) que guardaremos en values[spec.key]
  final String Function(T item) getId;

  /// Convierte el item a label (String) para mostrar/guardar en "${key}__label"
  final String Function(T item) getLabel;

  /// Texto placeholder cuando está vacío
  final String placeholder;

  /// Hint para el buscador del modal
  final String searchHint;

  /// Habilitar/deshabilitar dinámicamente
  final bool Function(AddFormValues values)? isEnabled;

  /// Texto opcional si está deshabilitado
  final String? disabledMessage;

  /// Botón opcional debajo ("Añadir X")
  final String? createLabel;

  /// Acción de crear (si devuelve un T, se autoselecciona)
  final Future<T?> Function(AddFormValues values)? onCreate;

  /// ✅ IMPORTANTE: debe coincidir con FieldSpec (Object?)
  @override
  final FieldOnChanged? onChanged;

  /// ✅ Extra opcional tipado a String? (cómodo para tus flows)
  final void Function(String? selectedId, AddFormValues values)? onIdChanged;

  const RelationFieldSpec({
    required super.key,
    required super.label,
    super.hint,
    super.required = false,
    super.requiredMessage,
    super.defaultValue,
    super.validator,

    required this.fetchItems,
    required this.getId,
    required this.getLabel,

    this.placeholder = 'Selecciona…',
    this.searchHint = 'Buscar…',
    this.isEnabled,
    this.disabledMessage,
    this.createLabel,
    this.onCreate,

    this.onChanged,
    this.onIdChanged,
  }) : super(kind: FieldKind.relation);

  /// Si quieres soportar “id inicial sin label cacheado”, puedes resolverlo aquí.
  /// Por defecto no hace nada.
  String? getLabelForStoredValue(Object storedValue) => null;

  /// Métodos de despacho con firma (dynamic) → String.
  /// Necesarios para llamarlos desde código no tipado (FieldRenderer / widgets
  /// que almacenan RelationFieldSpec sin parámetro de tipo), evitando el error
  /// de contravarianza: '(T) => String' no es subtipo de '(dynamic) => String'.
  String labelOf(dynamic item) => getLabel(item as T);
  String idOf(dynamic item) => getId(item as T);

  /// Punto único para notificar cambios (evita líos de tipos)
  void notifyChanged(String? selectedId, AddFormValues values) {
    onChanged?.call(selectedId, values); // selectedId es String? => compatible con Object?
    onIdChanged?.call(selectedId, values);
  }
}
