import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controllers/libro_controller.dart';
import '../widgets/barra_busqueda.dart';
import '../widgets/filtros_disponibilidad.dart';
import '../widgets/libro_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<LibroController>();

    Widget cuerpo;
    if (c.loading) {
      cuerpo = const Center(child: CircularProgressIndicator());
    } else if (c.error != null) {
      cuerpo = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 48),
              const SizedBox(height: 12),
              Text(c.error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                  onPressed: c.cargar, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    } else if (c.items.isEmpty) {
      cuerpo = const Center(child: Text('No hay libros registrados'));
    } else {
      final libros = c.visibles; // lista ya filtrada, buscada y ordenada
      cuerpo = Column(
        children: [
          const BarraBusqueda(),
          const FiltrosDisponibilidad(),
          // MEJORA: cuantos libros se ven de cuantos hay + boton Limpiar.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Mostrando ${libros.length} de ${c.items.length} libros',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                if (c.hayFiltros)
                  TextButton.icon(
                    onPressed: c.limpiarFiltros,
                    icon: const Icon(Icons.filter_alt_off, size: 18),
                    label: const Text('Limpiar'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: libros.isEmpty
                ? _SinResultados(onLimpiar: c.limpiarFiltros)
                : RefreshIndicator(
                    onRefresh: c.cargar,
                    child: ListView.separated(
                      itemCount: libros.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) => LibroTile(libro: libros[i]),
                    ),
                  ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca ITT'),
        actions: [
          // MEJORA: menu para elegir el orden de la lista.
          PopupMenuButton<OrdenLibros>(
            tooltip: 'Ordenar',
            icon: const Icon(Icons.sort),
            initialValue: c.orden,
            onSelected: c.cambiarOrden,
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: OrdenLibros.registro,
                  child: Text('Orden de registro')),
              PopupMenuItem(
                  value: OrdenLibros.titulo, child: Text('Título (A-Z)')),
              PopupMenuItem(
                  value: OrdenLibros.autor, child: Text('Autor (A-Z)')),
              PopupMenuItem(
                  value: OrdenLibros.anio,
                  child: Text('Año (más antiguo primero)')),
            ],
          ),
          IconButton(
            tooltip: 'Recargar (GET)',
            icon: const Icon(Icons.refresh),
            onPressed: c.cargar,
          ),
        ],
      ),
      body: cuerpo,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/nuevo'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo (POST)'),
      ),
    );
  }
}

/// Mensaje cuando la busqueda o el filtro no dejan ningun libro.
class _SinResultados extends StatelessWidget {
  const _SinResultados({required this.onLimpiar});
  final VoidCallback onLimpiar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Ningún libro coincide.\nPrueba con otra búsqueda o cambia el filtro.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onLimpiar,
              icon: const Icon(Icons.filter_alt_off),
              label: const Text('Limpiar búsqueda y filtros'),
            ),
          ],
        ),
      ),
    );
  }
}
