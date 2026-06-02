// lib/services/pending_sync_service.dart

import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';
import '../models/food.dart';
import '../models/food_visit.dart';
import '../models/place.dart';
import '../models/visit.dart';
import 'api_client.dart';

class PendingSyncService {
  final ApiClient _api;
  final AppDatabase _db;

  PendingSyncService({required ApiClient api, required AppDatabase db})
      : _api = api,
        _db = db;

  Future<void> syncPending() async {
    await _syncFoodCreates();
    await _syncPlaceCreates();
    await _syncVisitCreates();
    await _syncFoodVisitCreates();
  }

  // ── Food creates ──────────────────────────────────────────────────────────

  Future<void> _syncFoodCreates() async {
    final pending = await _db.syncQueueDao.getPendingCreates('food');

    for (final entry in pending) {
      try {
        final payload = jsonDecode(entry.payloadJson) as Map<String, dynamic>;

        final res = await _api.post('/api/v1/foods/', data: payload);

        final responseData = res.data;
        if (responseData is! Map<String, dynamic>) continue;

        final food = Food.fromJson(responseData);

        await _db.transaction(() async {
          await _db.foodsDao.deleteFoodById(entry.localEntityId);
          await _db.foodsDao.upsertFood(_foodToCompanion(food));
          await _db.syncQueueDao.deleteEntry(entry.id);

          // Repoint any pending FoodVisits that reference this local Food ID.
          await _db.foodVisitsDao.updateFoodId(entry.localEntityId, food.id);

          final pendingFoodVisitEntries =
              await _db.syncQueueDao.getPendingCreates('food_visit');
          for (final fvEntry in pendingFoodVisitEntries) {
            try {
              final composite =
                  jsonDecode(fvEntry.payloadJson) as Map<String, dynamic>;
              final fvPayload =
                  composite['foodVisitPayload'] as Map<String, dynamic>?;
              if (fvPayload != null &&
                  fvPayload['food'] == entry.localEntityId) {
                final updatedComposite = Map<String, dynamic>.from(composite)
                  ..['foodVisitPayload'] =
                      (Map<String, dynamic>.from(fvPayload)
                        ..['food'] = food.id);
                await _db.syncQueueDao
                    .updatePayload(fvEntry.id, jsonEncode(updatedComposite));
              }
            } catch (_) {
              // Malformed payload: skip, leave entry as-is.
            }
          }
        });
      } on ApiException catch (e) {
        final code = e.statusCode;
        // 4xx definitive (except 401 which may be recoverable by re-login)
        if (code != null && code >= 400 && code < 500 && code != 401) {
          await _db.syncQueueDao.markFailed(entry.id, e.toString());
          await _db.foodsDao.updateSyncStatus(entry.localEntityId, 'sync_failed');
        }
        // 401, 5xx, network, timeout: leave pending for next attempt
      } catch (_) {
        // Unexpected error: leave pending
      }
    }
  }

  // ── Place creates ─────────────────────────────────────────────────────────

  Future<void> _syncPlaceCreates() async {
    final pending = await _db.syncQueueDao.getPendingCreates('place');

    for (final entry in pending) {
      try {
        final payload = jsonDecode(entry.payloadJson) as Map<String, dynamic>;

        final res = await _api.post('/api/v1/places/', data: payload);

        final responseData = res.data;
        if (responseData is! Map<String, dynamic>) continue;

        final place = Place.fromJson(responseData);

        await _db.transaction(() async {
          await _db.placesDao.deletePlaceById(entry.localEntityId);
          await _db.placesDao.upsertPlace(_placeToCompanion(place));
          await _db.syncQueueDao.deleteEntry(entry.id);

          // Atomically repoint any pending Visits that reference this local Place ID.
          // If the process dies here the whole transaction rolls back, leaving the
          // Place entry still in SyncQueue as pending — safe to retry next sync.
          await _db.visitsDao.updatePlaceId(entry.localEntityId, place.id);

          final pendingVisitEntries =
              await _db.syncQueueDao.getPendingCreates('visit');
          for (final visitEntry in pendingVisitEntries) {
            try {
              final vPayload =
                  jsonDecode(visitEntry.payloadJson) as Map<String, dynamic>;
              if (vPayload['place'] == entry.localEntityId) {
                final updated = Map<String, dynamic>.from(vPayload)
                  ..['place'] = place.id;
                await _db.syncQueueDao
                    .updatePayload(visitEntry.id, jsonEncode(updated));
              }
            } catch (_) {
              // Malformed payload: skip, leave entry as-is.
            }
          }

          // Also update visitPayload['place'] embedded in pending food_visit entries.
          final pendingFoodVisitEntries =
              await _db.syncQueueDao.getPendingCreates('food_visit');
          for (final fvEntry in pendingFoodVisitEntries) {
            try {
              final composite =
                  jsonDecode(fvEntry.payloadJson) as Map<String, dynamic>;
              final vPayload =
                  composite['visitPayload'] as Map<String, dynamic>?;
              if (vPayload != null &&
                  vPayload['place'] == entry.localEntityId) {
                final updatedComposite = Map<String, dynamic>.from(composite)
                  ..['visitPayload'] = (Map<String, dynamic>.from(vPayload)
                    ..['place'] = place.id);
                await _db.syncQueueDao
                    .updatePayload(fvEntry.id, jsonEncode(updatedComposite));
              }
            } catch (_) {
              // Malformed payload: skip, leave entry as-is.
            }
          }
        });
      } on ApiException catch (e) {
        final code = e.statusCode;
        // 4xx definitive (except 401 which may be recoverable by re-login)
        if (code != null && code >= 400 && code < 500 && code != 401) {
          await _db.syncQueueDao.markFailed(entry.id, e.toString());
          await _db.placesDao.updateSyncStatus(entry.localEntityId, 'sync_failed');
        }
        // 401, 5xx, network, timeout: leave pending for next attempt
      } catch (_) {
        // Unexpected error: leave pending
      }
    }
  }

  // ── Visit creates ─────────────────────────────────────────────────────────

  Future<void> _syncVisitCreates() async {
    final pending = await _db.syncQueueDao.getPendingCreates('visit');

    for (final entry in pending) {
      try {
        final payload = jsonDecode(entry.payloadJson) as Map<String, dynamic>;

        final res = await _api.post('/api/v1/visits/', data: payload);

        final responseData = res.data;
        if (responseData is! Map<String, dynamic>) continue;

        final visit = Visit.fromJson(responseData);

        await _db.transaction(() async {
          await _db.visitsDao.deleteVisitById(entry.localEntityId);
          await _db.visitsDao.upsertVisit(_visitToCompanion(visit));
          await _db.syncQueueDao.deleteEntry(entry.id);
        });
      } on ApiException catch (e) {
        final code = e.statusCode;
        // 4xx definitivos (excepto 401 que puede ser recuperable por re-login)
        if (code != null && code >= 400 && code < 500 && code != 401) {
          await _db.syncQueueDao.markFailed(entry.id, e.toString());
          await _db.visitsDao.updateSyncStatus(entry.localEntityId, 'sync_failed');
        }
        // 401, 5xx, red, timeout: dejar pendiente para el siguiente intento
      } catch (_) {
        // Error inesperado: dejar pendiente
      }
    }
  }

  // ── FoodVisit creates ─────────────────────────────────────────────────────

  Future<void> _syncFoodVisitCreates() async {
    final pending = await _db.syncQueueDao.getPendingCreates('food_visit');

    for (final entry in pending) {
      await _processFoodVisitCreate(entry);
    }
  }

  Future<void> _processFoodVisitCreate(SyncQueueEntry entry) async {
    late final Map<String, dynamic> composite;
    try {
      composite = jsonDecode(entry.payloadJson) as Map<String, dynamic>;
    } catch (_) {
      await _db.syncQueueDao.markFailed(entry.id, 'malformed payload JSON');
      return;
    }

    final localVisitId = (composite['localVisitId'] as String?) ?? '';
    final localFoodVisitId = (composite['localFoodVisitId'] as String?) ?? '';
    final visitPayload =
        (composite['visitPayload'] as Map<String, dynamic>?) ?? {};
    final foodVisitPayload = Map<String, dynamic>.from(
      (composite['foodVisitPayload'] as Map<String, dynamic>?) ?? {},
    );
    String? backendVisitId = composite['backendVisitId'] as String?;

    // Defer if a parent entity hasn't synced yet (local ID still in payload).
    // Sending a local_ ID to the backend causes an avoidable 4xx that would be
    // treated as definitive and permanently fail this entry.
    final foodId = (foodVisitPayload['food'] as String?) ?? '';
    final placeId = (visitPayload['place'] as String?) ?? '';
    if (foodId.startsWith('local_') ||
        (backendVisitId == null && placeId.startsWith('local_'))) {
      return;
    }

    try {
      // Step 1: Create Visit on backend if not already done.
      // backendVisitId != null means a previous attempt already created the Visit;
      // skip the POST to avoid duplicating it.
      if (backendVisitId == null) {
        final res = await _api.post('/api/v1/visits/', data: visitPayload);
        final responseData = res.data;
        if (responseData is! Map<String, dynamic>) {
          await _markFoodVisitCreateFailed(
              entry, localVisitId, localFoodVisitId, 'malformed visit response');
          return;
        }

        backendVisitId = (responseData['id'] ?? '').toString();
        if (backendVisitId.isEmpty) {
          await _markFoodVisitCreateFailed(
              entry, localVisitId, localFoodVisitId, 'visit POST returned no id');
          return;
        }

        // Checkpoint: persist backendVisitId before the FoodVisit POST so that
        // a crash/timeout here won't cause the Visit to be created twice on retry.
        final updated = Map<String, dynamic>.from(composite)
          ..['backendVisitId'] = backendVisitId;
        await _db.syncQueueDao.updatePayload(entry.id, jsonEncode(updated));
      }

      // Step 2: Create FoodVisit on backend.
      final fvPost = Map<String, dynamic>.from(foodVisitPayload)
        ..['visit'] = backendVisitId;

      final fvRes = await _api.post('/api/v1/visit-foods/', data: fvPost);
      final fvData = fvRes.data;
      if (fvData is! Map<String, dynamic>) {
        await _markFoodVisitCreateFailed(
            entry, localVisitId, localFoodVisitId, 'malformed food_visit response');
        return;
      }

      final foodVisit = FoodVisit.fromJson(fvData);

      // Step 3: Commit everything atomically.
      // localVisitId is empty when an existing Visit was reused — skip Visit ops.
      await _db.transaction(() async {
        if (localVisitId.isNotEmpty) {
          await _db.visitsDao.deleteVisitById(localVisitId);
          await _db.visitsDao.upsertVisit(
            _visitFromPayload(backendVisitId!, visitPayload),
          );
        }
        await _db.foodVisitsDao.deleteFoodVisitById(localFoodVisitId);
        await _db.foodVisitsDao.upsertFoodVisit(_foodVisitToCompanion(foodVisit));
        await _db.syncQueueDao.deleteEntry(entry.id);
      });
    } on ApiException catch (e) {
      final code = e.statusCode;
      if (code != null && code >= 400 && code < 500 && code != 401) {
        // Definitive client error: mark failed and surface in UI.
        // Local records are kept (not deleted) so the user can see what failed.
        await _markFoodVisitCreateFailed(
            entry, localVisitId, localFoodVisitId, e.toString());
      }
      // 401, 5xx, network/timeout: leave pending.
      // If backendVisitId was saved above, the checkpoint is preserved for retry.
    } catch (_) {
      // Unexpected error: leave pending.
    }
  }

  Future<void> _markFoodVisitCreateFailed(
    SyncQueueEntry entry,
    String localVisitId,
    String localFoodVisitId,
    String error,
  ) async {
    await _db.transaction(() async {
      await _db.syncQueueDao.markFailed(entry.id, error);
      if (localVisitId.isNotEmpty) {
        await _db.visitsDao.updateSyncStatus(localVisitId, 'sync_failed');
      }
      await _db.foodVisitsDao.updateSyncStatus(localFoodVisitId, 'sync_failed');
    });
  }

  // ── Companion builders ────────────────────────────────────────────────────

  PlacesCacheCompanion _placeToCompanion(Place p) => PlacesCacheCompanion(
        id: Value(p.id),
        householdId: Value(p.householdId),
        name: Value(p.name),
        placeTypeId: Value(p.placeTypeId),
        areaId: Value(p.areaId),
        areaName: Value(p.areaName),
        priceRange: Value(p.priceRange),
        description: Value(p.description),
        url: Value(p.url),
        avgRating: Value(p.avgRating),
        avgPricePp: Value(p.avgPricePp),
        visitsCount: Value(p.visitsCount),
        lastVisitAt: Value(p.lastVisitAt),
        tags: Value(p.tags),
        syncStatus: const Value('synced'),
        createdAt: Value(p.createdAt),
        updatedAt: Value(p.updatedAt),
      );

  FoodsCacheCompanion _foodToCompanion(Food f) => FoodsCacheCompanion(
        id: Value(f.id),
        householdId: Value(f.householdId),
        name: Value(f.name),
        isActive: Value(f.isActive),
        syncStatus: const Value('synced'),
        createdAt: Value(f.createdAt),
        updatedAt: Value(f.updatedAt),
      );

  VisitsCacheCompanion _visitToCompanion(Visit v) => VisitsCacheCompanion(
        id: Value(v.id),
        placeId: Value(v.placeId),
        authorId: Value(v.authorId),
        date: Value(v.date),
        rating: Value(v.rating),
        pricePp: Value(v.pricePp),
        comment: Value(v.comment),
        syncStatus: const Value('synced'),
        createdAt: Value(v.createdAt),
      );

  // Builds a Visit companion from the original visitPayload + backendId.
  // Used for both first-attempt and checkpoint-retry paths in food_visit/create,
  // since the POST response is not retained between retries.
  // authorId defaults to '' and createdAt to now(); both are corrected by the
  // next GlobalSyncService full pull.
  VisitsCacheCompanion _visitFromPayload(
    String backendId,
    Map<String, dynamic> payload,
  ) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.trim());
      return null;
    }

    return VisitsCacheCompanion(
      id: Value(backendId),
      placeId: Value((payload['place'] ?? '').toString()),
      authorId: const Value(''),
      date: Value(DateTime.parse(payload['date'] as String)),
      rating: Value(toDouble(payload['rating'])),
      pricePp: Value(toDouble(payload['price_per_person'])),
      comment: Value((payload['comment'] ?? '').toString()),
      syncStatus: const Value('synced'),
      createdAt: Value(DateTime.now()),
    );
  }

  FoodVisitsCacheCompanion _foodVisitToCompanion(FoodVisit fv) =>
      FoodVisitsCacheCompanion(
        id: Value(fv.id),
        visitId: Value(fv.visitId),
        foodId: Value(fv.foodId),
        placeName: Value(fv.placeName),
        date: Value(fv.date),
        rating: Value(fv.rating),
        pricePp: Value(fv.pricePp),
        comment: Value(fv.comment),
        syncStatus: const Value('synced'),
        createdAt: Value(fv.createdAt),
      );
}
