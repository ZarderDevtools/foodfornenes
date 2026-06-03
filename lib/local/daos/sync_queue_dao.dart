import 'package:drift/drift.dart';

import '../app_database.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<int> insertPending({
    required String entityType,
    required String operation,
    required String localEntityId,
    required String payloadJson,
  }) =>
      into(syncQueue).insert(
        SyncQueueCompanion.insert(
          entityType: entityType,
          operation: operation,
          localEntityId: localEntityId,
          payloadJson: payloadJson,
          createdAt: DateTime.now(),
          status: const Value('pending'),
        ),
      );

  Future<List<SyncQueueEntry>> getPendingCreates(String entityType) =>
      (select(syncQueue)
            ..where(
              (t) =>
                  t.entityType.equals(entityType) &
                  t.operation.equals('create') &
                  t.status.equals('pending'),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<void> deleteEntry(int id) =>
      (delete(syncQueue)..where((t) => t.id.equals(id))).go();

  Future<void> markFailed(int id, String error) async {
    final current = await (select(syncQueue)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (current == null) return;
    await (update(syncQueue)..where((t) => t.id.equals(id))).write(
      SyncQueueCompanion(
        retries: Value(current.retries + 1),
        lastError: Value(error),
        status: const Value('failed'),
      ),
    );
  }

  Future<void> updatePayload(int id, String newPayloadJson) =>
      (update(syncQueue)..where((t) => t.id.equals(id)))
          .write(SyncQueueCompanion(payloadJson: Value(newPayloadJson)));

  Future<int> countPending() =>
      (select(syncQueue)..where((t) => t.status.equals('pending')))
          .get()
          .then((list) => list.length);

  Future<int> countFailed() =>
      (select(syncQueue)..where((t) => t.status.equals('failed')))
          .get()
          .then((list) => list.length);
}
