import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/libro.dart';
import '../controllers/libro_controller.dart';

class DetalleLibroScreen extends StatefulWidget {
  const DetalleLibroScreen({super.key, required this.id});

  final int id;

  @override
  State<DetalleLibroScreen> createState() => _DetalleLibroScreenState();
}

class _DetalleLibroScreenState extends State<DetalleLibroScreen> {
  late final Future<Libro> _libroFuture;

  @override
  void initState() {
    super.initState();
    _libroFuture = context.read<LibroController>().repo.getLibro(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Libro #${widget.id}')),
      body: FutureBuilder<Libro>(
        future: _libroFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            if (error is DioException && error.response?.statusCode == 404) {
              return const Center(child: Text('El libro no existe'));
            }
            return const Center(child: Text('No se pudo cargar el libro'));
          }

          final libro = snapshot.data!;
          return Center(
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(libro.titulo,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    Text('Autor: ${libro.autor}'),
                    const SizedBox(height: 8),
                    Text('Año: ${libro.anio}'),
                    const SizedBox(height: 8),
                    Text(libro.disponible ? 'Disponible' : 'Prestado'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
