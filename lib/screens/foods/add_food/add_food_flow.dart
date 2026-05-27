// lib/screens/foods/add_food/add_food_flow.dart

import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../local/app_database.dart';
import '../../../models/food.dart';
import '../../../services/api_client.dart';
import '../../../widgets/form_fields/field_spec.dart';
import '../../../widgets/form_fields/text_field_spec.dart';
import '../../add_record/add_record_config.dart';
import '../../add_record/add_record_screen.dart';
import '../../add_record/form_values.dart';

class AddFoodFlow extends StatelessWidget {
  final ApiClient api;
  final AppDatabase db;

  const AddFoodFlow({super.key, required this.api, required this.db});

  @override
  Widget build(BuildContext context) {
    final config = AddRecordConfig(
      title: 'Añadir comida',
      fields: [
        TextFieldSpec(
          key: 'name',
          label: 'Nombre',
          required: true,
          requiredMessage: 'El nombre es obligatorio.',
          placeholder: 'Ej: Tortilla de patatas',
          validator: FieldValidators.minLen(2, message: 'Mínimo 2 caracteres.'),
        ),
      ],
      onSubmit: (AddFormValues values) async {
        final name = values.textOrEmpty('name');
        if (name.isEmpty) throw Exception('El nombre es obligatorio.');

        // ── Online path ──────────────────────────────────────────────────────
        // Try to POST directly; if it works, cache the server response and let
        // AddRecordScreen pop with true normally.
        try {
          final res = await api.post(
            '/api/v1/foods/',
            data: <String, dynamic>{'name': name, 'is_active': true},
          );
          final data = res.data;
          if (data is Map<String, dynamic>) {
            final food = Food.fromJson(data);
            await db.foodsDao.upsertFood(FoodsCacheCompanion(
              id: Value(food.id),
              householdId: Value(food.householdId),
              name: Value(food.name),
              isActive: Value(food.isActive),
              syncStatus: const Value('synced'),
              createdAt: Value(food.createdAt),
              updatedAt: Value(food.updatedAt),
            ));
          }
          return; // AddRecordScreen calls maybePop(true)
        } on ApiException catch (e) {
          final code = e.statusCode;
          if (code != null && code >= 400 && code < 500) {
            // Definitive client error: show in form, do NOT save offline.
            throw Exception(e.message);
          }
          // 5xx / null statusCode / timeout: fall through to offline path.
        } catch (_) {
          // Network error / unexpected: fall through to offline path.
        }

        // ── Offline fallback ─────────────────────────────────────────────────
        // Save locally with a temporary ID and queue a SyncQueue create entry.
        final localId = 'local_food_${DateTime.now().microsecondsSinceEpoch}';
        final now = DateTime.now();

        await db.transaction(() async {
          await db.foodsDao.upsertFood(FoodsCacheCompanion(
            id: Value(localId),
            householdId: const Value(''),
            name: Value(name),
            isActive: const Value(true),
            syncStatus: const Value('pending_create'),
            createdAt: Value(now),
            updatedAt: Value(now),
          ));
          await db.syncQueueDao.insertPending(
            entityType: 'food',
            operation: 'create',
            localEntityId: localId,
            payloadJson: jsonEncode(<String, dynamic>{
              'name': name,
              'is_active': true,
            }),
          );
        });

        // Pop immediately; AddRecordScreen.maybePop is a no-op after this.
        if (context.mounted) Navigator.of(context).pop(true);
      },
    );

    return AddRecordScreen(config: config);
  }
}
