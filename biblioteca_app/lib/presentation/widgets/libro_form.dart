import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/libro.dart';

/// Formulario reutilizable para crear (POST) y editar (PUT).
/// MEJORA: validacion del año.
/// [onGuardar] regresa null si salio bien, o el mensaje de error.
class LibroForm extends StatefulWidget {
  const LibroForm({
    super.key,
    this.inicial,
    required this.textoBoton,
    required this.onGuardar,
  });

  final Libro? inicial;
  final String textoBoton;
  final Future<String?> Function(Libro libro) onGuardar;

  @override
  State<LibroForm> createState() => _LibroFormState();
}

class _LibroFormState extends State<LibroForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titulo;
  late final TextEditingController _autor;
  late final TextEditingController _anio;
  late bool _disponible;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final l = widget.inicial;
    _titulo = TextEditingController(text: l?.titulo ?? '');
    _autor = TextEditingController(text: l?.autor ?? '');
    _anio = TextEditingController(text: l != null ? '${l.anio}' : '');
    _disponible = l?.disponible ?? true;
  }

  @override
  void dispose() {
    _titulo.dispose();
    _autor.dispose();
    _anio.dispose();
    super.dispose();
  }

  /// MEJORA: el año debe ser un numero entre 1450 (imprenta de Gutenberg)
  /// y el año actual.
  String? _validarAnio(String? valor) {
    final anio = int.tryParse(valor?.trim() ?? '');
    if (anio == null) return 'Escribe un año válido';
    final actual = DateTime.now().year;
    if (anio < 1450 || anio > actual) return 'El año debe estar entre 1450 y $actual';
    return null;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final base = Libro(
      titulo: _titulo.text.trim(),
      autor: _autor.text.trim(),
      anio: int.parse(_anio.text.trim()),
      disponible: _disponible,
    );
    // Si estamos editando, conservamos el id original.
    final libro = widget.inicial != null
        ? widget.inicial!.copyWith(
            titulo: base.titulo,
            autor: base.autor,
            anio: base.anio,
            disponible: base.disponible,
          )
        : base;

    final messenger = ScaffoldMessenger.of(context);
    final error = await widget.onGuardar(libro);
    if (!mounted) return;
    setState(() => _guardando = false);

    if (error == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Guardado correctamente')));
      context.pop();
    } else {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _titulo,
            decoration: const InputDecoration(labelText: 'Título'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Escribe el título' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _autor,
            decoration: const InputDecoration(labelText: 'Autor'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Escribe el autor' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _anio,
            decoration: const InputDecoration(labelText: 'Año de publicación'),
            keyboardType: TextInputType.number,
            validator: _validarAnio,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Disponible para préstamo'),
            value: _disponible,
            onChanged: (v) => setState(() => _disponible = v),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _guardando ? null : _guardar,
            child: Text(_guardando ? 'Guardando...' : widget.textoBoton),
          ),
        ],
      ),
    );
  }
}