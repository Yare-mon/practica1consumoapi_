import 'package:go_router/go_router.dart';

import '../presentation/screens/detalle_libro_screen.dart';
import '../presentation/screens/editar_libro_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/nuevo_libro_screen.dart';
import '../presentation/screens/splash_screen.dart';

/// Navegacion de la app.
///   /splash      -> prueba de conexion (entra primero)
///   /home        -> lista de libros (GET)
///   /nuevo       -> formulario de alta (POST)
///   /editar/:id  -> formulario de edicion (PUT)
final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/nuevo', builder: (_, __) => const NuevoLibroScreen()),
    GoRoute(
      path: '/libro/:id',
      builder: (_, state) => DetalleLibroScreen(
        id: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/editar/:id',
      builder: (_, state) {
        final id = int.parse(state.pathParameters['id']!);
        return EditarLibroScreen(id: id);
      },
    ),
  ],
);
