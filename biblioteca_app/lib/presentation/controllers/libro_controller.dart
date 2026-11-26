import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/libro.dart';
import '../../domain/repository/libro_repository.dart';

/// Opciones del filtro de la lista (mejora: buscador y filtros).
enum FiltroDisponibilidad { todos, disponibles, prestados }

enum OrdenLibros { registro, titulo, autor, anio }

class LibroController extends ChangeNotifier {
  LibroController(this.repo);
  final LibroRepository repo;

  List<Libro> items = [];
  bool loading = false;
  String? error;

  // ---------------------------------------------------------------------------
  // MEJORA: buscador, filtros y orden (se aplican sobre la lista ya cargada,
  // no hacen peticiones nuevas a la API).
  // ---------------------------------------------------------------------------
  String busqueda = '';
  FiltroDisponibilidad filtro = FiltroDisponibilidad.todos;
  OrdenLibros orden = OrdenLibros.registro;

  /// Libros que se muestran en Home despues de aplicar busqueda, filtro y orden.
  List<Libro> get visibles {
    final texto = busqueda.trim().toLowerCase();
    final lista = items.where((l) {
      final coincide = texto.isEmpty ||
          l.titulo.toLowerCase().contains(texto) ||
          l.autor.toLowerCase().contains(texto);
      final pasaFiltro = switch (filtro) {
        FiltroDisponibilidad.todos => true,
        FiltroDisponibilidad.disponibles => l.disponible,
        FiltroDisponibilidad.prestados => !l.disponible,
      };
      return coincide && pasaFiltro;
    }).toList();

    // Ordenar la lista ya filtrada (registro = no se ordena).
    switch (orden) {
      case OrdenLibros.registro:
        break;
      case OrdenLibros.titulo:
        lista.sort(
            (a, b) => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()));
      case OrdenLibros.autor:
        lista.sort(
            (a, b) => a.autor.toLowerCase().compareTo(b.autor.toLowerCase()));
      case OrdenLibros.anio:
        lista.sort((a, b) => a.anio.compareTo(b.anio));
    }
    return lista;
  }

  int get totalDisponibles => items.where((l) => l.disponible).length;
  int get totalPrestados => items.length - totalDisponibles;

  void buscar(String texto) {
    busqueda = texto;
    notifyListeners();
  }

  void cambiarFiltro(FiltroDisponibilidad nuevo) {
    filtro = nuevo;
    notifyListeners();
  }

  void cambiarOrden(OrdenLibros nuevo) {
    orden = nuevo;
    notifyListeners();
  }

  /// Busca un libro ya cargado en la lista (lo usa la vista de editar).
  Libro? buscarPorId(int id) {
    for (final l in items) {
      if (l.id == id) return l;
    }
    return null;
  }

  // GET: se llama al abrir Home
  Future<void> cargar() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await repo.getLibros();
    } on DioException catch (e) {
      error = 'No se pudo conectar con la API (${e.type.name}).\n'
          '¿Está corriendo Spring Boot en el puerto 8080?';
    } catch (e) {
      error = 'Error inesperado: $e';
    }
    loading = false;
    notifyListeners();
  }

  // POST: regresa null si salio bien, o el mensaje de error
  Future<String?> crear(Libro libro) async {
    try {
      await repo.crear(libro);
      await cargar(); // recargar la lista para ver el nuevo libro
      return null;
    } on DioException catch (e) {
      return _mensaje(e);
    } catch (e) {
      return '$e';
    }
  }

  // PUT (TODO 3a)
  Future<String?> actualizar(Libro libro) async {
    try {
      await repo.actualizar(libro);
      await cargar(); // recargar la lista para ver el cambio
      return null;
    } on DioException catch (e) {
      return _mensaje(e);
    } catch (e) {
      return '$e';
    }
  }

  // DELETE (TODO 3b)
  Future<String?> eliminar(int id) async {
    try {
      await repo.eliminar(id);
      await cargar(); // recargar la lista para ver el cambio
      return null;
    } on DioException catch (e) {
      return _mensaje(e);
    } catch (e) {
      return '$e';
    }
  }

  String _mensaje(DioException e) {
    final code = e.response?.statusCode;
    switch (code) {
      case 400:
        return 'Datos inválidos (400): título y autor son obligatorios';
      case 404:
        return 'El libro no existe (404)';
      case 500:
        return 'Error del servidor (500)';
      default:
        return code != null
            ? 'Error $code'
            : 'Sin conexión con la API (${e.type.name})';
    }
  }
}
