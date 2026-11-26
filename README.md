# Biblioteca ITT · Consumo de una API Spring Boot desde Flutter

Práctica 1 de **Desarrollo de Aplicaciones Móviles**, Instituto Tecnológico de Tlaxiaco.

**Equipo (bina):** Yaretzy Montesinos López · Elisa Sánchez Coronel
**Asesor:** Josué Israel Vásquez Martínez · **Grupo:** 7 US

App Flutter que hace el **CRUD completo** de libros consumiendo una API REST hecha en Spring Boot.
La práctica traía GET y POST; nosotras programamos **PUT** y **DELETE**, el reto de **detalle por id**
y mejoras en las pantallas: **buscador, filtros y orden** en Home, **detalle con acciones** y **formulario con validaciones**.

---

## Tecnologías

| Parte | Tecnología | Para qué |
|---|---|---|
| API | Spring Boot 3, Spring Web, Spring Data JPA | Endpoints REST `/api/libros` |
| Base de datos | H2 en memoria | Se reinicia con 5 libros de prueba en cada arranque |
| App | Flutter (Dart ≥ 3.4) | Interfaz |
| HTTP | `dio` | Peticiones, timeouts, `LogInterceptor` y manejo de errores con `DioException` |
| Estado | `provider` | Compartir el `LibroController` (`ChangeNotifier`) entre pantallas |
| Navegación | `go_router` | Rutas con parámetros (`/editar/:id`, `/libro/:id`) |

## Cómo ejecutarlo

**1. API** (dejar esta terminal abierta):

```bash
cd backend
mvn spring-boot:run
```

Debe aparecer `Tomcat started on port 8080`. Comprobar en el navegador: `http://localhost:8080/api/libros`.

**2. App** (en otra terminal):

```bash
cd biblioteca_app
flutter pub get
flutter run -d chrome
```

La URL base está en `lib/core/constants/api_config.dart`: Chrome usa `localhost`, el emulador Android `10.0.2.2`
y un celular físico la IP de la PC (`ipCelularFisico`).

## Endpoints

| Método | Ruta | Respuesta |
|---|---|---|
| GET | `/api/libros` | 200 · lista |
| GET | `/api/libros/{id}` | 200 / 404 |
| POST | `/api/libros` | 201 / 400 |
| PUT | `/api/libros/{id}` | 200 / 400 / 404 |
| DELETE | `/api/libros/{id}` | 204 / 404 |

## Arquitectura de la app

```
Vista (screens, widgets)
   ↓  llama métodos del controller
Controller  · LibroController (ChangeNotifier): items, loading, error, búsqueda, filtro y orden
   ↓
Repository  · LibroRepository: JSON ⇄ Libro (toJson / fromJson)
   ↓
Service     · LibroService: solo rutas con dio (get, post, put, delete)
   ↓
Networking  · DioClient: URL base, timeouts, LogInterceptor
   ↓
API Spring Boot (localhost:8080)
```

**Punto de entrada:** `lib/main.dart` arma la cadena `DioClient → LibroService → LibroRepository → LibroController`
y la comparte con `MultiProvider`. En la API, `BibliotecaApiApplication.java`.

```
biblioteca_app/lib/
├── core/constants/api_config.dart       URL base según plataforma
├── networking/dio_client.dart           cliente Dio
├── domain/models/libro.dart             modelo + fromJson / toJson
├── domain/repository/libro_repository.dart
├── services/libro_service.dart
├── presentation/
│   ├── controllers/libro_controller.dart
│   ├── screens/   splash, home, nuevo, editar, detalle_libro
│   └── widgets/   libro_tile, libro_form, barra_busqueda, filtros_disponibilidad, acciones_detalle
└── routes/app_router.dart
```

## Qué hicimos

### Práctica (TODO 1 a 3)

| Archivo | Cambio |
|---|---|
| `libro_service.dart` | `actualizar` con `dio.put('/api/libros/$id')` y `eliminar` con `dio.delete(...)` |
| `libro_repository.dart` | `actualizar` envía `toJson()` y regresa `Libro.fromJson(...)`; `eliminar` delega al service |
| `libro_controller.dart` | `actualizar` y `eliminar` con `try/catch`: si sale bien recargan con `cargar()` y regresan `null`; si falla regresan el mensaje (400, 404, sin conexión) |

### Reto · Detalle por id

`getLibro(id)` en service y repository, ruta `/libro/:id`, `onTap` en `LibroTile` y la pantalla
`DetalleLibroScreen`, que usa `FutureBuilder` y muestra **"El libro no existe"** cuando la API responde 404.

### Mejoras de Yaretzy · Home (10 commits)

- **Buscador** (`BarraBusqueda`): busca por título o autor mientras se escribe. Filtra la lista **en memoria**
  con el getter `visibles` del controller, sin peticiones nuevas a la API.
- **Filtros** (`FiltrosDisponibilidad`): chips **Todos / Disponibles / Prestados** con contador, en verde y naranja.
- **Ordenar**: menú en la barra superior por registro, título, autor o año (`OrdenLibros`).
- **Contador** "Mostrando X de Y libros" y botón **Limpiar** búsqueda y filtros.
- **Lista**: ícono en círculo con el color del estado y *Prestado* resaltado.

### Mejoras de Elisa · Detalle, formulario y README (8 commits)

- **Detalle**: encabezado con ícono en círculo, chip Disponible / Prestado y tarjeta con ID, autor y año.
- Botón **Reintentar** si falla la conexión y **Volver a la lista** si el libro no existe (404).
- `AccionesDetalle`: botones **Editar** (abre el formulario y al volver recarga el libro) y
  **Eliminar** (confirma, elimina con el controller y regresa a la lista).
- **Formulario**: el año debe estar entre 1450 y el año actual; íconos en los campos, límite de caracteres
  y botón con indicador de carga.

## Pruebas realizadas

| Operación | Petición | Código |
|---|---|---|
| Listar | GET `/api/libros` | 200 |
| Editar "Clean Code" | PUT `/api/libros/4` | 200 |
| Eliminar "Cien años de soledad" | DELETE `/api/libros/1` | 204 |
| Detalle de un libro eliminado | GET `/api/libros/1` | 404 |

Las peticiones se ven en la consola del navegador (F12) gracias al `LogInterceptor`.

## Flujo de trabajo en Git

- `main`: versión entregable · `develop`: integración. Ambas protegidas: solo entran cambios por Pull Request
  aprobado por la otra integrante.
- Cada integrante trabajó en sus propias ramas, una por mejora:

| Integrante | Rama | Commits |
|---|---|---|
| Yaretzy | `feature/buscador-filtros` | 4 |
| Yaretzy | `feature/ordenar-y-contador` | 3 |
| Yaretzy | `style/colores-estado` | 2 |
| Yaretzy | `feature/limpiar-filtros` | 1 |
| Elisa | `style/detalle-diseno` | 3 |
| Elisa | `feature/detalle-acciones` | 2 |
| Elisa | `feature/formulario-validaciones` | 2 |
| Elisa | `docs/readme` | 1 |

- Las mejoras de Yaretzy entraron con el PR #1 (aprobado por Elisa) y `develop` se sincronizó con `main`
  en los PR #5 y #6. Las de Elisa entraron a `develop` con un PR por rama, aprobados por Yaretzy.
- Mensajes de commit con prefijo: `feat:`, `style:`, `fix:`, `docs:`.

## Problemas encontrados

| Síntoma | Causa | Solución |
|---|---|---|
| `connectionError` en la app | La API no estaba corriendo | Levantarla con `mvn spring-boot:run` y no cerrar la terminal |
| No aparecía el botón Run de Java | La extensión de Java no estaba activa | Ejecutar la API desde la terminal con Maven |
| Los libros borrados regresan | H2 vive en memoria | Es normal: se recargan al reiniciar la API |