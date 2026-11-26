import 'package:flutter/material.dart';

/// MEJORA: botones Editar (PUT) y Eliminar (DELETE) para la pantalla de detalle.
/// Solo dibuja los botones; la pantalla decide que hacer en cada uno.
class AccionesDetalle extends StatelessWidget {
  const AccionesDetalle({
    super.key,
    required this.onEditar,
    required this.onEliminar,
  });

  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onEditar,
            icon: const Icon(Icons.edit),
            label: const Text('Editar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: onEliminar,
            style: FilledButton.styleFrom(
              backgroundColor: colores.error,
              foregroundColor: colores.onError,
            ),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Eliminar'),
          ),
        ),
      ],
    );
  }
}