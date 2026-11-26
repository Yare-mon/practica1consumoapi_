import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/libro.dart';
import '../controllers/libro_controller.dart';

/// RETO: detalle de un libro. Consume GET /api/libros/{id} directamente
/// (no usa la lista en memoria), asi se ve el 404 si el libro ya no existe.
/// MEJORA: encabezado con icono en circulo, titulo y autor.
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
    // El Future se crea una sola vez para no repetir la peticion en cada build.
    _futuro = context.read<LibroController>().repo.getLibro(widget.id);
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
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off, size: 64),
                  const SizedBox(height: 12),
                  Text(_mensajeError(snap.error!),
                      style: Theme.of(context).textTheme.titleMedium),
                ],
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
        const SizedBox(height: 24),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Autor'),
                subtitle: Text(libro.autor),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Año'),
                subtitle: Text('${libro.anio}'),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Estado'),
                subtitle: Text(libro.disponible ? 'Disponible' : 'Prestado'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}