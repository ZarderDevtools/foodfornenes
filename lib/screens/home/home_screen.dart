import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/categorization_repository.dart';
import '../../models/place_type.dart';
import '../../config/app_images.dart';
import '../../models/bottom_action.dart';
import '../../widgets/bottom_bar.dart';
import '../foods/foods_list_screen.dart';
import '../places/places_list_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  final ApiClient apiClient;
  final AuthRepository authRepository;

  const HomeScreen({
    super.key,
    required this.apiClient,
    required this.authRepository,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final CategorizationRepository _repo;
  late Future<List<PlaceType>> _futurePlaceTypes;

  @override
  void initState() {
    super.initState();
    _repo = CategorizationRepository(widget.apiClient);
    _futurePlaceTypes = _repo.listPlaceTypes(isActive: true);
  }

  @override
  Widget build(BuildContext context) {
    // Colores base (alineados con login: frescos, verde/azul suaves)
    final bg = const Color(0xFFF6FBFF);
    final card = Colors.white;
    final border = const Color(0xFFBFE6E3); // verde-agua suave

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // ---------------- CONTENIDO PRINCIPAL ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                children: [
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
                    child: FutureBuilder<List<PlaceType>>(
                      future: _futurePlaceTypes,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error cargando categorías\n${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        final items = snapshot.data ?? [];

                        // Excluir "Restaurante"
                        final filtered = items
                            .where((pt) => pt.name.trim().toLowerCase() != 'restaurante')
                            .toList();

                        if (filtered.isEmpty) {
                          return const Center(child: Text(''));
                        }

                        return GridView.builder(
                          // IMPORTANTE:
                          // Dejamos bastante espacio abajo para que la barra no tape el grid
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
                              onTap: () {
                                _openGenericPlacetypeList(pt);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ---------------- SECCIÓN 3: BARRA INFERIOR (3 slots) ----------------
            BottomBar3Slots(
              left: BottomAction.home(),
              center: BottomAction.primary(
                icon: Icons.add,
                // AQUI indicar pantalla de nueva visita
                // Por ahora, lo dejamos apuntando a Home para validar que funciona:
                onTap: (ctx) => Navigator.of(ctx).pushNamed(HomeScreen.routeName),
              ),
              right: BottomAction.back(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openRestaurantsList() async {
    try {
      final items = await _futurePlaceTypes;

      final rest = items.firstWhere(
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
          builder: (_) => const FoodsListScreen(
            title: 'Comidas',
            ordering: 'name',
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
