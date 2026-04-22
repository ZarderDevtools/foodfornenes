// lib/screens/foods/food_detail_screen.dart

import 'package:flutter/material.dart';

import '../../models/bottom_action.dart';
import '../../models/food.dart';
import '../../repositories/foods_repository.dart';
import '../../services/api_client.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/detail_field.dart';
import 'edit_food/edit_food_flow.dart';
import 'food_visits_screen.dart';

class FoodDetailScreen extends StatefulWidget {
  final String foodId;

  const FoodDetailScreen({super.key, required this.foodId});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  Food? _food;
  bool _ready = false;
  String? _error;
  bool _wasEdited = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _openEdit() async {
    final updated = await Navigator.of(context).push<Food>(
      MaterialPageRoute(
        builder: (_) => EditFoodFlow(foodId: widget.foodId),
      ),
    );
    if (!mounted || updated == null) return;
    _wasEdited = true;
    setState(() => _food = updated);
  }

  Future<void> _load() async {
    try {
      final api = await ApiClient.create();
      final repo = FoodsRepository(api);
      final food = await repo.fetchFood(widget.foodId);

      if (!mounted) return;
      setState(() {
        _food = food;
        _ready = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _ready = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final home = BottomAction.home();
    final back = BottomAction.back().copyWith(
      onTap: (ctx) => Navigator.of(ctx).pop(_wasEdited),
    );
    final edit = BottomAction.primary(
      id: 'edit',
      icon: Icons.edit_rounded,
      onTap: (_) => _openEdit(),
    );

    if (!_ready) {
      return AppScaffold(
        title: 'Detalle',
        floatingBar: false,
        left: home,
        center: edit,
        right: back,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return AppScaffold(
        title: 'Detalle',
        floatingBar: false,
        left: home,
        center: edit,
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
                  'Error al cargar el detalle.',
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
                    _load();
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

    final food = _food!;

    return AppScaffold(
      title: food.name,
      floatingBar: false,
      left: home,
      center: edit,
      right: back,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Información general ──────────────────────────────────────
            DetailSection(
              title: '',
              children: [
                DetailField(label: 'Nombre', value: food.name),
              ],
            ),

            const SizedBox(height: 24),

            // ── Acciones ─────────────────────────────────────────────────
            _VisitsButton(onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FoodVisitsScreen(
                    foodId: food.id,
                    foodName: food.name,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _VisitsButton extends StatelessWidget {
  final VoidCallback onTap;

  const _VisitsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBFE6E3), width: 1.2),
        ),
        child: Row(
          children: [
            const Icon(Icons.history_rounded, color: Color(0xFF2BB7A9)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Ver visitas',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2BB7A9),
                    ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF2BB7A9),
            ),
          ],
        ),
      ),
    );
  }
}
