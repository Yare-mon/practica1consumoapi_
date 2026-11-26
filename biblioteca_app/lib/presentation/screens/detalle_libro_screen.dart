import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/models/libro.dart';
import '../controllers/libro_controller.dart';
import '../widgets/acciones_detalle.dart';

/// RETO: detalle de un libro. Consume GET /api/libros/{id} directamente
/// (no usa la lista en memoria), asi se ve el 404 si el libro ya no existe.
/// MEJORA: nuevo diseno, boton Reintentar y acciones Editar / Eliminar.
class DetalleLibroScreen extends StatefulWidget {
  const DetalleLibroScreen({super.key, required this.id});
  final int id;

  @override
  State<DetalleLibroScreen> createState() => _DetalleLibroScreenState();
}

class _DetalleLibroScreenState extends State<DetalleLibroScreen> {
  late Future<Libro> _futuro;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  /// Pide el libro a la API. Se llama al abrir, al reintentar y al volver de editar.
  void _cargar() {
    _futuro = context.read<LibroController>().repo.getLibro(widget.id);
  }

  void _reintentar() => setState(_cargar);

  /// Abre el formulario de edicion y, al regresar, vuelve a pedir el libro
  /// para mostrar los datos actualizados.
  Future<void> _editar() async {
    await context.push('/editar/${widget.id}');
    if (!mounted) return;
    setState(_cargar);
  }

  /// Pide confirmacion, elimina con el controller y regresa a la lista.
  Future<void> _eliminar(Libro libro) async {
    final messenger = ScaffoldMessenger.of(context);
    final controller = context.read<LibroController>();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar libro'),
        content: Text('¿Eliminar "${libro.titulo}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmar != true) return;

    final error = await controller.eliminar(libro.id!);
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(error ?? 'Libro eliminado')));

    if (error == null) {
      // Si se llego por URL directa no hay pantalla atras: se va a Home.
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    }
  }

  String _mensajeError(Object e) {
    if (e is DioException) {
      if (e.response?.statusCode == 404) return 'El libro no existe';
      if (e.response == null) {
        return 'Sin conexión con la API (${e.type.name})';
      }
      return 'Error ${e.response?.statusCode}';
    }
    return 'Error inesperado: $e';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Libro #${widget.id}')),
      body: FutureBuilder<Libro>(
        future: _futuro,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            final noExiste = snap.error is DioException &&
                (snap.error as DioException).response?.statusCode == 404;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(noExiste ? Icons.search_off : Icons.wifi_off, size: 64),
                    const SizedBox(height: 12),
                    Text(_mensajeError(snap.error!),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    // Si el libro no existe no tiene caso reintentar.
                    noExiste
                        ? OutlinedButton(
                            onPressed: () => context.go('/home'),
                            child: const Text('Volver a la lista'),
                          )
                        : FilledButton(
                            onPressed: _reintentar,
                            child: const Text('Reintentar'),
                          ),
                  ],
                ),
              ),
            );
          }
          return _contenido(context, snap.data!);
        },
      ),
    );
  }

  Widget _contenido(BuildContext context, Libro libro) {
    final colores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final colorEstado = libro.disponible ? Colors.green : Colors.orange;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Encabezado: icono en circulo con el color del estado.
        Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: colorEstado.shade100,
            child: Icon(
              libro.disponible ? Icons.menu_book : Icons.lock_clock,
              size: 44,
              color: colorEstado,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(libro.titulo, textAlign: TextAlign.center, style: textos.headlineSmall),
        const SizedBox(height: 4),
        Text(
          libro.autor,
          textAlign: TextAlign.center,
          style: textos.titleMedium?.copyWith(color: colores.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        // Chip con el estado del libro.
        Center(
          child: Chip(
            avatar: Icon(Icons.circle, size: 12, color: colorEstado),
            label: Text(libro.disponible ? 'Disponible' : 'Prestado'),
          ),
        ),
        const SizedBox(height: 16),
        // Tarjeta con los datos del libro.
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.tag),
                title: const Text('ID en la API'),
                subtitle: Text('${libro.id}'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Autor'),
                subtitle: Text(libro.autor),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Año de publicación'),
                subtitle: Text('${libro.anio}'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // MEJORA: botones Editar y Eliminar.
        AccionesDetalle(
          onEditar: _editar,
          onEliminar: () => _eliminar(libro),
        ),
      ],
    );
  }
}