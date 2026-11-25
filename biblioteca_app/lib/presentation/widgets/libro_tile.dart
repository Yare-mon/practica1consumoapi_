import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/models/libro.dart';
import '../controllers/libro_controller.dart';

/// Un renglon de la lista con los botones Editar (PUT) y Eliminar (DELETE).
/// Los botones YA estan conectados al controller: ustedes solo completan
/// los TODO del service, repository y controller.
class LibroTile extends StatelessWidget {
  const LibroTile({super.key, required this.libro});
  final Libro libro;

  Future<void> _confirmarEliminar(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final controller = context.read<LibroController>();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar libro'),
        content: Text('¿Eliminar "${libro.titulo}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmar != true) return;

    final error = await controller.eliminar(libro.id!);
    messenger.showSnackBar(SnackBar(content: Text(error ?? 'Libro eliminado')));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push('/libro/${libro.id}'),
      leading: Icon(
        libro.disponible ? Icons.menu_book : Icons.lock_clock,
        color: libro.disponible ? Colors.green : Colors.orange,
      ),
      title: Text(libro.titulo),
      subtitle: Text('${libro.autor} · ${libro.anio}'
          '${libro.disponible ? '' : ' · Prestado'}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Editar (PUT)',
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/editar/${libro.id}'),
          ),
          IconButton(
            tooltip: 'Eliminar (DELETE)',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmarEliminar(context),
          ),
        ],
      ),
    );
  }
}
