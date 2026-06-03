// screens/home/home_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../local/app_database.dart';
import '../../services/api_client.dart';
import '../../services/global_sync_service.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/categorization_repository.dart';
import '../../models/place_type.dart';
import '../../config/app_images.dart';
import '../../models/bottom_action.dart';
import '../../widgets/app_scaffold.dart';
import '../foods/foods_list_screen.dart';
import '../places/places_list_screen.dart';

// ✅ NUEVO: añadir visita (flow)
import '../visits/add_visit/add_visit_flow.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  final ApiClient apiClient;
  final AuthRepository authRepository;
  final AppDatabase db;
  final GlobalSyncService syncService;

  const HomeScreen({
    super.key,
    required this.apiClient,
    required this.authRepository,
    required this.db,
    required this.syncService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final CategorizationRepository _repo;

  List<PlaceType>? _placeTypes;
  bool _placeTypesLoading = true;
  String? _placeTypesError;
  bool _debugSyncing = false;

  @override
  void initState() {
    super.initState();
    _repo = CategorizationRepository(
      widget.apiClient,
      dao: widget.db.placeTypesDao,
    );
    widget.syncService.syncIfNeeded();
    _init();
  }

  Future<void> _init() async {
    final cached = await _repo.getCachedPlaceTypes();
    if (!mounted) return;
    if (cached != null && cached.isNotEmpty) {
      setState(() {
        _placeTypes = cached;
        _placeTypesLoading = false;
      });
    }

    try {
      final fresh = await _repo.listPlaceTypes(isActive: true);
      if (!mounted) return;
      setState(() {
        _placeTypes = fresh;
        _placeTypesLoading = false;
        _placeTypesError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _placeTypesLoading = false;
        if (_placeTypes == null || _placeTypes!.isEmpty) {
          _placeTypesError = e.toString();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colores base (alineados con login: frescos, verde/azul suaves)
    final card = Colors.white;
    final border = const Color(0xFFBFE6E3); // verde-agua suave

    return AppScaffold(
      left: BottomAction.home(),
      center: BottomAction.primary(
        icon: Icons.add,
        // ✅ NUEVO: pantalla de nueva visita
        onTap: (ctx) async {
          final created = await Navigator.of(ctx).push<bool>(
            MaterialPageRoute(builder: (_) => AddVisitFlow(db: widget.db)),
          );

          // Opcional: feedback rápido si se creó
          if (created == true && ctx.mounted) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Visita creada')),
            );
          }
        },
      ),
      right: BottomAction.back(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
                children: [
                  // ── Gear button (top-left) ─────────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        popupMenuTheme: PopupMenuThemeData(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(
                              color: Color(0xFFBFE6E3),
                              width: 1.0,
                            ),
                          ),
                          elevation: 4,
                          textStyle: const TextStyle(
                            color: Color(0xFF2BB7A9),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.settings_rounded,
                          size: 22,
                          color: Color(0xFF2BB7A9),
                        ),
                        tooltip: 'Ajustes',
                        itemBuilder: (context) => const [
                          PopupMenuItem<String>(
                            value: 'sync_status',
                            child: Text('Estado de sincronización'),
                          ),
                        ],
                        onSelected: (_) {
                          // placeholder — próximo paso: mostrar estado de sync
                        },
                      ),
                    ),
                  ),
                  if (kDebugMode) ...[
                    ElevatedButton.icon(
                      onPressed: _debugSyncing
                          ? null
                          : () async {
                              setState(() => _debugSyncing = true);
                              await widget.syncService.forceSync();
                              if (mounted) setState(() => _debugSyncing = false);
                            },
                      icon: _debugSyncing
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync, size: 16),
                      label: Text(_debugSyncing ? 'Sincronizando…' : '[DEBUG] Sync ahora'),
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  _SectionTitle(title: ""), // Accesos
                  const SizedBox(height: 10),

                  Column(
                    children: [
                      // -------- Sección 0: 🖼️ Imagen superior 🖼️ --------
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          AppImages.logo,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // -------- Sección 1: COMIDAS / RESTAURANTES (1 columna) --------
                      _BigButton(
                        label: "COMIDAS",
                        background: card,
                        borderColor: border,
                        onTap: _openFoodsList,
                      ),
                      const SizedBox(height: 12),
                      _BigButton(
                        label: "RESTAURANTES",
                        background: card,
                        borderColor: border,
                        onTap: _openRestaurantsList,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // -------- Sección 2: PlaceTypes (2 columnas, scroll si hay muchos) --------
                  _SectionTitle(title: ""), // Categorías
                  const SizedBox(height: 10),

                  Expanded(
                    child: _buildCategoriesGrid(border),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoriesGrid(Color border) {
    if (_placeTypesLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_placeTypesError != null) {
      return Center(
        child: Text(
          'Error cargando categorías\n$_placeTypesError',
          textAlign: TextAlign.center,
        ),
      );
    }

    final items = _placeTypes ?? [];
    final filtered = items
        .where((pt) => pt.name.trim().toLowerCase() != 'restaurante')
        .toList();

    if (filtered.isEmpty) {
      return const Center(child: Text(''));
    }

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 160),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.4,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final pt = filtered[index];
        return _SmallButton(
          label: pt.name,
          background: Colors.white,
          borderColor: border,
          onTap: () => _openGenericPlacetypeList(pt),
        );
      },
    );
  }

  Future<void> _openRestaurantsList() async {
    final types = _placeTypes;
    if (types == null || types.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cargando categorías, intenta de nuevo')),
      );
      return;
    }

    try {
      final rest = types.firstWhere(
        (pt) => pt.name.trim().toLowerCase() == 'restaurante',
      );

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlacesListScreen(
            placeTypeId: rest.id,
            title: 'Restaurantes',
            ordering: '-avg_rating',
            apiClient: widget.apiClient,
            db: widget.db,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo abrir Restaurantes: $e'),
        ),
      );
    }
  }

  Future<void> _openFoodsList() async {
    try {
      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FoodsListScreen(
            title: 'Comidas',
            ordering: 'name',
            apiClient: widget.apiClient,
            db: widget.db,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo abrir Comidas: $e'),
        ),
      );
    }
  }

  Future<void> _openGenericPlacetypeList(PlaceType placeType) async {
    try {
      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlacesListScreen(
            placeTypeId: placeType.id,
            title: placeType.name,
            ordering: '-avg_rating',
            apiClient: widget.apiClient,
            db: widget.db,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo abrir ${placeType.name}: $e'),
        ),
      );
    }
  }
}

// -------------------- Widgets UI reutilizables (solo Home por ahora) --------------------

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color borderColor;
  final VoidCallback onTap;

  const _BigButton({
    required this.label,
    required this.background,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color borderColor;
  final VoidCallback onTap;

  const _SmallButton({
    required this.label,
    required this.background,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
        ),
      ),
    );
  }
}
