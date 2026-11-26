import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/libro_controller.dart';

/// MEJORA: caja de texto para buscar libros por titulo o autor.
/// Cada letra que se escribe llama a controller.buscar(), que filtra
/// la lista que ya esta en memoria (no hace peticiones a la API).
class BarraBusqueda extends StatefulWidget {
  const BarraBusqueda({super.key});

  @override
  State<BarraBusqueda> createState() => _BarraBusquedaState();
}

class _BarraBusquedaState extends State<BarraBusqueda> {
  late final LibroController _controller;
  late final TextEditingController _texto;

  @override
  void initState() {
    super.initState();
    _controller = context.read<LibroController>();
    // Conserva lo que se habia buscado al regresar a Home.
    _texto = TextEditingController(text: _controller.busqueda);
    // Si la busqueda se limpia desde otro lado (boton Limpiar), se borra la caja.
    _controller.addListener(_sincronizar);
  }

  void _sincronizar() {
    if (_controller.busqueda != _texto.text) {
      _texto.text = _controller.busqueda;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_sincronizar);
    _texto.dispose();
    super.dispose();
  }

  void _limpiar() {
    _texto.clear();
    _controller.buscar('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _texto,
        textInputAction: TextInputAction.search,
        onChanged: (valor) {
          _controller.buscar(valor);
          setState(() {}); // para mostrar u ocultar el boton de limpiar
        },
        decoration: InputDecoration(
          hintText: 'Buscar por título o autor',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _texto.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpiar búsqueda',
                  icon: const Icon(Icons.clear),
                  onPressed: _limpiar,
                ),
          filled: true,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
