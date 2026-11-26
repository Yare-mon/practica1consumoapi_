import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/libro_controller.dart';

/// MEJORA: chips para filtrar la lista en Todos / Disponibles / Prestados.
/// Cada chip muestra cuantos libros hay en esa categoria.
class FiltrosDisponibilidad extends StatelessWidget {
  const FiltrosDisponibilidad({super.key});

  @override
  Widget build(BuildContext context) {
    // watch: los contadores y el chip seleccionado cambian con la lista.
    final c = context.watch<LibroController>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          _chip(c, FiltroDisponibilidad.todos, 'Todos', c.items.length,
              Icons.library_books),
          const SizedBox(width: 8),
          _chip(c, FiltroDisponibilidad.disponibles, 'Disponibles',
              c.totalDisponibles, Icons.menu_book),
          const SizedBox(width: 8),
          _chip(c, FiltroDisponibilidad.prestados, 'Prestados',
              c.totalPrestados, Icons.lock_clock),
        ],
      ),
    );
  }

  Widget _chip(
    LibroController c,
    FiltroDisponibilidad opcion,
    String texto,
    int cantidad,
    IconData icono,
  ) {
    return ChoiceChip(
      showCheckmark: false,
      avatar: Icon(icono, size: 18),
      label: Text('$texto ($cantidad)'),
      selected: c.filtro == opcion,
      onSelected: (_) => c.cambiarFiltro(opcion),
    );
  }
}
