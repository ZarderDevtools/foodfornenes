// lib/screens/list/list_screen.dart

import 'package:flutter/material.dart';

import '../../config/network/paged_result.dart';
import '../../models/bottom_action.dart';
import '../../widgets/bottom_bar.dart';

typedef FetchItems<T> = Future<List<T>> Function();

// NUEVO: paginación para APIs tipo DRF (scroll infinito)
typedef FetchFirstPage<T> = Future<PagedResult<T>> Function();
typedef FetchNextPage<T> = Future<PagedResult<T>> Function();
typedef HasNextPage = bool Function();

class ListScreen<T> extends StatefulWidget {
  const ListScreen({
    super.key,
    required this.title,

    // Modo simple (sin paginación)
    this.fetchItems,

    // Modo paginado (scroll infinito)
    this.fetchFirstPage,
    this.fetchNextPage,
    this.hasNextPage,

    required this.getName,
    required this.getTags,
    required this.getRatingAvg,
    required this.getPriceLevel,
    required this.onTapItem,
    required this.onCreate,
    required this.onHome,
    required this.onBack,
    this.emptyMessageOverride,
    this.onFilters, // (por ahora opcional)
    this.onSort, // (por ahora opcional)
    this.hasActiveFilters = false,
    this.hasActiveSort = false,
  }) : assert(
          fetchItems != null ||
              (fetchFirstPage != null && fetchNextPage != null && hasNextPage != null),
          'Debes pasar fetchItems o (fetchFirstPage, fetchNextPage, hasNextPage).',
        );

  // Identidad
  final String title;

  // Datos (modo simple)
  final FetchItems<T>? fetchItems;

  // Datos (modo paginado)
  final FetchFirstPage<T>? fetchFirstPage;
  final FetchNextPage<T>? fetchNextPage;
  final HasNextPage? hasNextPage;

  // Adaptadores de UI (cómo extraer datos del item)
  final String Function(T item) getName;
  final List<String> Function(T item) getTags;
  final double? Function(T item) getRatingAvg;
  final String? Function(T item) getPriceLevel;

  // Acciones
  final void Function(T item) onTapItem;
  final VoidCallback onCreate;
  final VoidCallback onHome;
  final VoidCallback onBack;

  // Opcionales (para más adelante)
  final VoidCallback? onFilters;
  final VoidCallback? onSort;
  final bool hasActiveFilters;
  final bool hasActiveSort;

  // Mensaje vacío
  final String? emptyMessageOverride;

  @override
  State<ListScreen<T>> createState() => _ListScreenState<T>();
}

class _ListScreenState<T> extends State<ListScreen<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _loading = true;
  bool _loadingMore = false;

  String? _error;
  List<T> _items = const [];

  // ---- Barra inferior de Filtros/Ordenar con "slide up/down"
  bool _showBottomTools = true;
  double _lastPixels = 0;

  bool get _hasAnyTool => widget.onFilters != null || widget.onSort != null;

  @override
  void initState() {
    super.initState();
    _load(initial: true);
  }

  @override
  void didUpdateWidget(covariant ListScreen<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final fetchChanged =
        oldWidget.fetchItems != widget.fetchItems ||
        oldWidget.fetchFirstPage != widget.fetchFirstPage;

    if (fetchChanged) {
      // 1) Sube arriba (en el siguiente frame para evitar errores si aún no hay posiciones)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        }
      });

      // 2) Recarga
      _load(initial: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load({bool initial = false}) async {
    if (!mounted) return;
    setState(() {
      _error = null;
      if (initial) _loading = true;
    });

    try {
      // ✅ MODO PAGINADO
      if (widget.fetchFirstPage != null) {
        final page1 = await widget.fetchFirstPage!();
        if (!mounted) return;
        setState(() {
          _items = page1.results;
        });
      }
      // ✅ MODO SIMPLE
      else {
        final items = await widget.fetchItems!();
        if (!mounted) return;
        setState(() {
          _items = items;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (widget.fetchNextPage == null) return;
    if (_loading || _loadingMore) return;

    if (widget.hasNextPage != null && !widget.hasNextPage!()) return;

    setState(() => _loadingMore = true);

    try {
      final pageN = await widget.fetchNextPage!();
      if (!mounted) return;

      if (pageN.results.isNotEmpty) {
        setState(() {
          _items = [..._items, ...pageN.results];
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  // Detecta dirección de scroll para mostrar/ocultar la barra (slide)
  void _handleScrollForBottomTools(ScrollMetrics metrics) {
    if (!_hasAnyTool) return;

    final pixels = metrics.pixels;

    // Umbral para que no parpadee
    const deltaThreshold = 12.0;
    final delta = pixels - _lastPixels;

    if (delta.abs() < deltaThreshold) return;

    // Si bajas (delta positivo) => ocultar.
    if (delta > 0 && _showBottomTools) {
      setState(() => _showBottomTools = false);
    }

    // Si subes (delta negativo) => mostrar.
    if (delta < 0 && !_showBottomTools) {
      setState(() => _showBottomTools = true);
    }

    _lastPixels = pixels;
  }

  @override
  Widget build(BuildContext context) {
    final emptyMsg = widget.emptyMessageOverride ??
        'No existen ${widget.title.toLowerCase()} actualmente';

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFF),
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Contenido principal (LISTA / LOADING / ERROR / EMPTY)
          Expanded(
            child: _buildContent(emptyMsg),
          ),

          // ✅ Botones abajo + "slide up/down"
          if (_hasAnyTool) _BottomToolsBar(
            visible: _showBottomTools,
            onFilters: widget.onFilters,
            onSort: widget.onSort,
            filtersActive: widget.hasActiveFilters,
            sortActive: widget.hasActiveSort,
          ),
        ],
      ),
      bottomNavigationBar: BottomBar3Slots(
        floating: false,
        left: BottomAction.home(),
        center: BottomAction.primary(
          icon: Icons.add,
          onTap: (ctx) => widget.onCreate(),
        ),
        right: BottomAction.back(),
      ),
    );
  }

  Widget _buildContent(String emptyMsg) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 36),
              const SizedBox(height: 10),
              const Text(
                'Ha ocurrido un error al cargar el listado.',
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
                onPressed: () => _load(initial: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            emptyMsg,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    // ✅ Pull-to-refresh + ✅ Scroll infinito + ✅ slide tools bar
    return RefreshIndicator.adaptive(
      onRefresh: _load,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          // Slide up/down para la barra inferior (filtros/ordenar)
          if (n is ScrollUpdateNotification) {
            _handleScrollForBottomTools(n.metrics);
          }

          // Scroll infinito: Solo aplica si está en modo paginado
          if (widget.fetchNextPage == null || widget.hasNextPage == null) return false;

          if (_loading || _loadingMore) return false;
          if (!widget.hasNextPage!()) return false;

          final metrics = n.metrics;
          final threshold = 300.0;
          final nearBottom = metrics.maxScrollExtent - metrics.pixels <= threshold;

          if (nearBottom) {
            _loadMore();
          }

          return false;
        },
        child: ListView.separated(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          itemCount: _items.length + 1, // +1 para footer (loader final)
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == _items.length) {
              if (_loadingMore) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return const SizedBox(height: 24);
            }

            final item = _items[index];
            return _ListCard<T>(
              item: item,
              getName: widget.getName,
              getTags: widget.getTags,
              getRatingAvg: widget.getRatingAvg,
              getPriceLevel: widget.getPriceLevel,
              onTap: () => widget.onTapItem(item),
            );
          },
        ),
      ),
    );
  }
}

class _BottomToolsBar extends StatelessWidget {
  final bool visible;
  final VoidCallback? onFilters;
  final VoidCallback? onSort;

  final bool filtersActive;
  final bool sortActive;

  const _BottomToolsBar({
    required this.visible,
    required this.onFilters,
    required this.onSort,
    required this.filtersActive,
    required this.sortActive,
  });

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF6FBFF);
    const border = Color(0xFFBFE6E3);
    const accent = Color(0xFF2BB7A9);

    final filtersButtonStyle = OutlinedButton.styleFrom(
      backgroundColor: filtersActive ? accent.withOpacity(0.12) : Colors.white,
      side: BorderSide(color: filtersActive ? accent : border, width: 1.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
    final sortButtonStyle = OutlinedButton.styleFrom(
      backgroundColor: sortActive ? accent.withOpacity(0.12) : Colors.white,
      side: BorderSide(color: sortActive ? accent : border, width: 1.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );

    final child = Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onFilters,
              icon: Icon(
                Icons.tune_rounded,
                color: filtersActive ? accent : null,
              ),
              label: Text(
                'Filtros',
                style: filtersActive
                    ? const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: accent,
                      )
                    : null,
              ),
              style: filtersButtonStyle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onSort,
              icon: Icon(
                Icons.sort_rounded,
                color: sortActive ? accent : null,
              ),
              label: Text(
                'Ordenar',
                style: sortActive
                    ? const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: accent,
                      )
                    : null,
              ),
              style: sortButtonStyle,
            ),
          ),
        ],
      ),
    );

    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: Container(
          color: bg,
          child: SafeArea(
            top: false,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _ListCard<T> extends StatelessWidget {
  const _ListCard({
    required this.item,
    required this.getName,
    required this.getTags,
    required this.getRatingAvg,
    required this.getPriceLevel,
    required this.onTap,
  });

  final T item;
  final String Function(T item) getName;
  final List<String> Function(T item) getTags;
  final double? Function(T item) getRatingAvg;
  final String? Function(T item) getPriceLevel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = getName(item).trim();

    final tags =
        getTags(item).map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

    final rating = getRatingAvg(item);
    final hasRating = rating != null;
    final ratingText = hasRating ? rating!.toStringAsFixed(1) : '';

    final price = (getPriceLevel(item) ?? '').trim();
    final hasPrice = price.isNotEmpty;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Izquierda: nombre + tags (Expanded limita el ancho)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _TagsRow(tags: tags),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Derecha: rating + price (no se ve afectada por los tags)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (hasRating)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          ratingText,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),

                  if (hasRating && hasPrice) const SizedBox(height: 6),

                  if (hasPrice)
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Chips de tags ──────────────────────────────────────────────────────────

class _TagsRow extends StatelessWidget {
  final List<String> tags;

  const _TagsRow({required this.tags});

  @override
  Widget build(BuildContext context) {
    const maxVisible = 3;
    final visible = tags.take(maxVisible).toList();
    final overflow = tags.length - visible.length;

    return Wrap(
      spacing: 5,
      runSpacing: 4,
      children: [
        for (final tag in visible) _TagChip(label: tag),
        if (overflow > 0) _TagChip(label: '+$overflow'),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFE6E3), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF2BB7A9),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
