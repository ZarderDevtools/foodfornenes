// lib/screens/places/place_detail_screen.dart

import 'package:flutter/material.dart';

import '../../models/bottom_action.dart';
import '../../models/place.dart';
import '../../repositories/places_repository.dart';
import '../../services/api_client.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/detail_field.dart';
import '../../widgets/tag_chip.dart';
import 'edit_place/edit_place_flow.dart';
import 'place_visits_screen.dart';

class PlaceDetailScreen extends StatefulWidget {
  final String placeId;

  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  Place? _place;
  bool _ready = false;
  String? _error;
  bool _wasEdited = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _openEdit() async {
    final updated = await Navigator.of(context).push<Place>(
      MaterialPageRoute(
        builder: (_) => PlaceEditFlow(placeId: widget.placeId),
      ),
    );
    if (!mounted || updated == null) return;
    _wasEdited = true;
    setState(() => _place = updated);
  }

  Future<void> _load() async {
    try {
      final api = await ApiClient.create();
      final repo = PlacesRepository(api);
      final place = await repo.fetchPlace(widget.placeId);

      if (!mounted) return;
      setState(() {
        _place = place;
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

    final place = _place!;

    final ratingStr = place.avgRating != null
        ? place.avgRating!.toStringAsFixed(1)
        : null;

    final priceStr = place.avgPricePp != null
        ? '${place.avgPricePp!.toStringAsFixed(2)} €'
        : null;

    return AppScaffold(
      title: place.name,
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
              title: 'Información general',
              children: [
                DetailField(label: 'Nombre', value: place.name),
                const SizedBox(height: 12),
                DetailField(label: 'Área', value: place.areaName),
                const SizedBox(height: 12),
                DetailField(
                  label: 'Descripción',
                  value: place.description.isEmpty ? null : place.description,
                ),
                const SizedBox(height: 12),
                DetailField(
                  label: 'URL',
                  value: place.url.isEmpty ? null : place.url,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Estadísticas ─────────────────────────────────────────────
            DetailSection(
              title: 'Estadísticas',
              children: [
                DetailField(label: 'Valoración media', value: ratingStr),
                const SizedBox(height: 12),
                DetailField(label: 'Precio medio p.p.', value: priceStr),
                const SizedBox(height: 12),
                DetailField(
                  label: 'Número de visitas',
                  value: '${place.visitsCount}',
                ),
              ],
            ),

            // ── Etiquetas ────────────────────────────────────────────────
            if (place.tags.isNotEmpty) ...[
              const SizedBox(height: 24),
              DetailSection(
                title: 'Etiquetas',
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: place.tags
                        .map((t) => TagChip(label: t))
                        .toList(),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // ── Acciones ─────────────────────────────────────────────────
            _VisitsButton(onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PlaceVisitsScreen(
                    placeId: place.id,
                    placeName: place.name,
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
