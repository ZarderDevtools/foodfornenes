// lib/screens/foods/food_visits_screen.dart

import 'package:flutter/material.dart';

import '../../models/bottom_action.dart';
import '../../models/food_visit.dart';
import '../../repositories/visits_repository.dart';
import '../../services/api_client.dart';
import '../../widgets/app_scaffold.dart';
import 'add_food_visit/add_food_visit_flow.dart';

class FoodVisitsScreen extends StatefulWidget {
  final String foodId;
  final String foodName;

  const FoodVisitsScreen({
    super.key,
    required this.foodId,
    required this.foodName,
  });

  @override
  State<FoodVisitsScreen> createState() => _FoodVisitsScreenState();
}

class _FoodVisitsScreenState extends State<FoodVisitsScreen> {
  List<FoodVisit> _visits = [];
  bool _ready = false;
  String? _error;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 1;

  VisitsRepository? _repo;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final api = await ApiClient.create();
      _repo = VisitsRepository(api);
      await _loadPage(1);
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

    final result = await repo.fetchFoodVisits(widget.foodId, page: page);

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

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    await _loadPage(_page + 1);
  }

  Future<void> _openAddVisit() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddFoodVisitFlow(
          foodId: widget.foodId,
          foodName: widget.foodName,
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
    });
    await _init();
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
        title: widget.foodName,
        floatingBar: false,
        left: home,
        center: add,
        right: back,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return AppScaffold(
        title: widget.foodName,
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
      return AppScaffold(
        title: widget.foodName,
        floatingBar: false,
        left: home,
        center: add,
        right: back,
        child: const Center(
          child: Text(
            'No hay visitas registradas.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return AppScaffold(
      title: widget.foodName,
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
          separatorBuilder: (_, __) => const SizedBox(height: 10),
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
            return _FoodVisitCard(
              visit: visit,
              formattedDate: _formatDate(visit.date),
            );
          },
        ),
      ),
    );
  }
}

class _FoodVisitCard extends StatelessWidget {
  final FoodVisit visit;
  final String formattedDate;

  const _FoodVisitCard({required this.visit, required this.formattedDate});

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
          // ── Sitio (si disponible) ──────────────────────────────────────
          if (visit.placeName != null && visit.placeName!.isNotEmpty) ...[
            Text(
              visit.placeName!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
          ],

          // ── Rating · Precio · Fecha ────────────────────────────────────
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
