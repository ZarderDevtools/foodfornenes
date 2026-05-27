// lib/screens/places/place_visits_screen.dart

import 'package:flutter/material.dart';

import '../../local/app_database.dart';
import '../../models/bottom_action.dart';
import '../../models/visit.dart';
import '../../repositories/visits_repository.dart';
import '../../services/api_client.dart';
import '../../widgets/app_scaffold.dart';
import '../visits/add_visit/add_visit_flow.dart';

class PlaceVisitsScreen extends StatefulWidget {
  final String placeId;
  final String placeName;
  final String? placeTypeId;
  final AppDatabase db;

  const PlaceVisitsScreen({
    super.key,
    required this.placeId,
    required this.placeName,
    this.placeTypeId,
    required this.db,
  });

  @override
  State<PlaceVisitsScreen> createState() => _PlaceVisitsScreenState();
}

class _PlaceVisitsScreenState extends State<PlaceVisitsScreen> {
  List<Visit> _visits = [];
  bool _ready = false;
  String? _error;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 1;
  bool _offlineEmpty = false;

  VisitsRepository? _repo;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final api = await ApiClient.create();
      final repo = VisitsRepository(api, visitsDao: widget.db.visitsDao);
      _repo = repo;

      final cached = await repo.getCachedPlaceVisits(widget.placeId);

      if (cached != null && cached.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _visits = cached;
          _hasMore = false;
          _ready = true;
        });
        // Refresh from API in background; ignore failures silently.
        try {
          await _loadPage(1);
          // Re-merge pending visits: the API result doesn't include unsynced
          // local records, so we re-read them from cache and prepend them.
          final pending = await repo.getCachedPendingVisits(widget.placeId);
          if (pending.isNotEmpty && mounted) {
            setState(() {
              final apiIds = _visits.map((v) => v.id).toSet();
              final toAdd =
                  pending.where((v) => !apiIds.contains(v.id)).toList();
              if (toAdd.isNotEmpty) _visits = [...toAdd, ..._visits];
            });
          }
        } catch (_) {}
      } else {
        // No local data: try API; on failure show friendly empty state.
        try {
          await _loadPage(1);
        } catch (_) {
          if (!mounted) return;
          setState(() {
            _ready = true;
            _offlineEmpty = true;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _ready = true;
      });
    }
  }

  Future<void> _loadPage(int page) async {
    final repo = _repo;
    if (repo == null) return;

    final result = await repo.fetchPlaceVisits(widget.placeId, page: page);

    if (!mounted) return;
    setState(() {
      if (page == 1) {
        _visits = result.results;
      } else {
        _visits = [..._visits, ...result.results];
      }
      _hasMore = result.next != null;
      _page = page;
      _ready = true;
      _loadingMore = false;
    });
  }

  Future<void> _openAddVisit() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddVisitFlow(
          db: widget.db,
          defaultPlaceId: widget.placeId,
          defaultPlaceName: widget.placeName,
          defaultPlaceTypeId: widget.placeTypeId,
        ),
      ),
    );
    if (!mounted || created != true) return;
    setState(() {
      _visits = [];
      _ready = false;
      _hasMore = false;
      _page = 1;
      _error = null;
      _offlineEmpty = false;
      _loadingMore = false;
    });
    await _init();
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      await _loadPage(_page + 1);
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$d/$m/$y';
  }

  @override
  Widget build(BuildContext context) {
    final home = BottomAction.home();
    final back = BottomAction.back();
    final add = BottomAction.primary(
      id: 'add',
      icon: Icons.add_rounded,
      onTap: (_) => _openAddVisit(),
    );

    if (!_ready) {
      return AppScaffold(
        title: widget.placeName,
        floatingBar: false,
        left: home,
        center: add,
        right: back,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return AppScaffold(
        title: widget.placeName,
        floatingBar: false,
        left: home,
        center: add,
        right: back,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 36),
                const SizedBox(height: 10),
                const Text(
                  'Error al cargar las visitas.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _ready = false;
                      _error = null;
                    });
                    _init();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_visits.isEmpty) {
      final emptyMessage = _offlineEmpty
          ? 'No hay visitas guardadas todavía.\nCuando se sincronice la app, aparecerán aquí.'
          : 'No hay visitas registradas.';
      return AppScaffold(
        title: widget.placeName,
        floatingBar: false,
        left: home,
        center: add,
        right: back,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return AppScaffold(
      title: widget.placeName,
      floatingBar: false,
      left: home,
      center: add,
      right: back,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 200) {
            _loadMore();
          }
          return false;
        },
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: _visits.length + (_loadingMore ? 1 : 0),
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == _visits.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final visit = _visits[index];
            return _VisitCard(
              visit: visit,
              formattedDate: _formatDate(visit.date),
            );
          },
        ),
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final Visit visit;
  final String formattedDate;

  const _VisitCard({required this.visit, required this.formattedDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFE6E3), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Rating · Precio · Fecha (una sola fila) ───────────────────
          Row(
            children: [
              if (visit.rating != null) ...[
                Text(
                  '★: ${visit.displayRating}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2BB7A9),
                  ),
                ),
                const SizedBox(width: 14),
              ],
              if (visit.pricePp != null) ...[
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'pp: ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      TextSpan(
                        text: visit.displayPricePp,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
              ],
              const Spacer(),
              Text(
                formattedDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // ── Comentario ─────────────────────────────────────────────────
          if (visit.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              visit.comment,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
