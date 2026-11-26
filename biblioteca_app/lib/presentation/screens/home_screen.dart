import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controllers/libro_controller.dart';
import '../widgets/barra_busqueda.dart';
import '../widgets/filtros_disponibilidad.dart';
import '../widgets/libro_tile.dart';

/// Lista de libros (GET). Escucha al controller con context.watch.
/// MEJORA: buscador por titulo o autor y filtros Disponibles / Prestados.
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
      final libros = c.visibles; // lista ya filtrada por busqueda y chips
      cuerpo = Column(
        children: [
          const BarraBusqueda(),
          const FiltrosDisponibilidad(),
          Expanded(
            child: libros.isEmpty
                ? _SinResultados(
                    onVerTodos: () =>
                        c.cambiarFiltro(FiltroDisponibilidad.todos),
                  )
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
  const _SinResultados({required this.onVerTodos});
  final VoidCallback onVerTodos;

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
            OutlinedButton(
                onPressed: onVerTodos, child: const Text('Ver todos')),
          ],
        ),
      ),
    );
  }
}
