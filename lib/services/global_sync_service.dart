// lib/services/global_sync_service.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../local/app_database.dart';
import '../models/food_list_query.dart';
import '../models/place_list_query.dart';
import '../repositories/categorization_repository.dart';
import '../repositories/foods_repository.dart';
import '../repositories/places_repository.dart';
import '../repositories/visits_repository.dart';
import 'api_client.dart';
import 'pending_sync_service.dart';

class GlobalSyncService {
  final ApiClient _api;
  final AppDatabase _db;
  final PendingSyncService _pendingSync;

  static const _ttlMinutes = 30;
  static const _lastSyncKey = 'global_sync_last_at';

  bool _isSyncing = false;

  GlobalSyncService({
    required ApiClient api,
    required AppDatabase db,
    required PendingSyncService pendingSync,
  })  : _api = api,
        _db = db,
        _pendingSync = pendingSync;

  /// Launches a background sync if not already running and TTL has elapsed.
  /// Fire-and-forget: do not await this from the UI.
  Future<void> syncIfNeeded() async {
    if (_isSyncing) return;
    if (!await _shouldSync()) return;

    debugPrint('[Sync] Se está ejecutando la sincronización (automática)');
    _isSyncing = true;
    try {
      await _runSync();
      await _markSynced();
      debugPrint('[Sync] Sincronización automática finalizada correctamente');
    } catch (e) {
      debugPrint('[Sync] Sincronización automática finalizada con error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Forces a full sync ignoring TTL. Respects concurrency guard.
  /// For debug/testing only — do not call in production flows.
  Future<void> forceSync() async {
    if (_isSyncing) return;

    debugPrint('[Sync] Se está ejecutando la sincronización (manual)');
    _isSyncing = true;
    try {
      await _runSync();
      await _markSynced();
      debugPrint('[Sync] Sincronización manual finalizada correctamente');
    } catch (e) {
      debugPrint('[Sync] Sincronización manual finalizada con error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<DateTime?> getLastSyncAt() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_lastSyncKey);
    if (str == null) return null;
    return DateTime.tryParse(str);
  }

  /// Returns true if the backend API is responding correctly.
  /// Online:  2xx (success) or 401/403 (server up, auth/permission issue).
  /// Offline: 5xx (server error), other 4xx, timeout, network failure.
  Future<bool> checkConnectivity() async {
    const path = '/api/v1/place-types/';
    try {
      await _api.get(path);
      debugPrint('[Connectivity] GET $path → 2xx → Online');
      return true;
    } on ApiException catch (e) {
      final code = e.statusCode;
      final isOnline = code != null && (code == 401 || code == 403);
      debugPrint('[Connectivity] GET $path → ${code ?? 'no response'} → ${isOnline ? 'Online' : 'Offline'}');
      return isOnline;
    } catch (e) {
      debugPrint('[Connectivity] GET $path → error: $e → Offline');
      return false;
    }
  }

  Future<bool> _shouldSync() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStr = prefs.getString(_lastSyncKey);
    if (lastStr == null) return true;
    final last = DateTime.tryParse(lastStr);
    if (last == null) return true;
    return DateTime.now().difference(last).inMinutes >= _ttlMinutes;
  }

  Future<void> _markSynced() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  Future<void> _runSync() async {
    debugPrint('[Sync] → Sincronizando pendientes offline...');
    try {
      await _pendingSync.syncPending();
      debugPrint('[Sync]   ✓ Pendientes offline sincronizados');
    } catch (e) {
      debugPrint('[Sync]   ✗ Error sincronizando pendientes: $e');
    }

    final catRepo = CategorizationRepository(
      _api,
      dao: _db.placeTypesDao,
      areasDao: _db.areasDao,
      tagsDao: _db.tagsDao,
    );

    debugPrint('[Sync] → Sincronizando tipos de lugar...');
    try {
      await catRepo.listPlaceTypes(isActive: true);
      debugPrint('[Sync]   ✓ Tipos de lugar sincronizados');
    } catch (e) {
      debugPrint('[Sync]   ✗ Error sincronizando tipos de lugar: $e');
    }

    debugPrint('[Sync] → Sincronizando áreas...');
    try {
      await catRepo.listAreas();
      debugPrint('[Sync]   ✓ Áreas sincronizadas');
    } catch (e) {
      debugPrint('[Sync]   ✗ Error sincronizando áreas: $e');
    }

    debugPrint('[Sync] → Sincronizando tags...');
    try {
      await catRepo.listTags();
      debugPrint('[Sync]   ✓ Tags sincronizados');
    } catch (e) {
      debugPrint('[Sync]   ✗ Error sincronizando tags: $e');
    }

    debugPrint('[Sync] → Sincronizando comidas...');
    try {
      final repo = FoodsRepository(_api, dao: _db.foodsDao);
      await _syncAllFoodsPages(repo);
      debugPrint('[Sync]   ✓ Comidas sincronizadas');
    } catch (e) {
      debugPrint('[Sync]   ✗ Error sincronizando comidas: $e');
    }

    debugPrint('[Sync] → Sincronizando lugares...');
    try {
      final repo = PlacesRepository(_api, dao: _db.placesDao);
      await _syncAllPlacesPages(repo);
      debugPrint('[Sync]   ✓ Lugares sincronizados');
    } catch (e) {
      debugPrint('[Sync]   ✗ Error sincronizando lugares: $e');
    }

    debugPrint('[Sync] → Sincronizando visitas...');
    try {
      final repo = VisitsRepository(_api, visitsDao: _db.visitsDao);
      await _syncAllVisitsPages(repo);
      debugPrint('[Sync]   ✓ Visitas sincronizadas');
    } catch (e) {
      debugPrint('[Sync]   ✗ Error sincronizando visitas: $e');
    }

    debugPrint('[Sync] → Sincronizando visitas de comida...');
    try {
      final repo = VisitsRepository(_api, foodVisitsDao: _db.foodVisitsDao);
      await _syncAllFoodVisitsPages(repo);
      debugPrint('[Sync]   ✓ Visitas de comida sincronizadas');
    } catch (e) {
      debugPrint('[Sync]   ✗ Error sincronizando visitas de comida: $e');
    }
  }

  Future<void> _syncAllFoodsPages(FoodsRepository repo) async {
    const maxPages = 50;
    int page = 1;

    while (page <= maxPages) {
      try {
        final result = await repo.fetchFoods(
          FoodListQuery(isActive: true, page: page),
        );
        if (!result.hasNext) break;
        page++;
      } catch (_) {
        break;
      }
    }
  }

  Future<void> _syncAllPlacesPages(PlacesRepository repo) async {
    const maxPages = 50;
    int page = 1;

    while (page <= maxPages) {
      try {
        final result = await repo.fetchPlaces(
          PlaceListQuery(page: page),
        );
        if (!result.hasNext) break;
        page++;
      } catch (_) {
        break;
      }
    }
  }

  Future<void> _syncAllVisitsPages(VisitsRepository repo) async {
    const maxPages = 50;
    int page = 1;

    while (page <= maxPages) {
      try {
        final result = await repo.fetchGlobalVisitsPage(page);
        if (!result.hasNext) break;
        page++;
      } catch (_) {
        break;
      }
    }
  }

  Future<void> _syncAllFoodVisitsPages(VisitsRepository repo) async {
    const maxPages = 50;
    int page = 1;

    while (page <= maxPages) {
      try {
        final result = await repo.fetchGlobalFoodVisitsPage(page);
        if (!result.hasNext) break;
        page++;
      } catch (_) {
        break;
      }
    }
  }
}
