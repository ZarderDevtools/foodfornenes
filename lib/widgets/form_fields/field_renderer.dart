// lib/widgets/form_fields/field_renderer.dart

import 'package:flutter/material.dart';

import '../../screens/add_record/form_values.dart';
import 'choice_field_spec.dart';
import 'choice_field_widget.dart';
import 'field_spec.dart';
import 'number_field_spec.dart';
import 'number_field_widget.dart';
import 'relation_field_spec.dart';
import 'relation_field_widget.dart';
import 'text_field_spec.dart';
import 'text_field_widget.dart';

class FieldRenderer extends StatelessWidget {
  final FieldSpec spec;
  final AddFormValues values;

  const FieldRenderer({
    super.key,
    required this.spec,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final errorText = values.fieldError(spec.key);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          spec.label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _buildField(context, errorText),
        if (spec.hint != null && spec.hint!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            spec.hint!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _buildField(BuildContext context, String? errorText) {
    switch (spec.kind) {
      case FieldKind.text:
        final s = spec as TextFieldSpec;
        return TextFieldWidget(
          spec: s,
          values: values,
          errorText: errorText,
        );

      case FieldKind.number:
        final s = spec as NumberFieldSpec;
        return NumberFieldWidget(
          spec: s,
          values: values,
          errorText: errorText,
        );

      case FieldKind.choice:
        final s = spec as ChoiceFieldSpec<dynamic>;
        return ChoiceFieldWidget<dynamic>(
          spec: s,
          values: values,
          errorText: errorText,
        );

      case FieldKind.relation:
        final s = spec as RelationFieldSpec; // <-- sin <dynamic>
        return RelationFieldWidget(
          spec: s,
          values: values,
          errorText: errorText,
        );
    }
  }
}
