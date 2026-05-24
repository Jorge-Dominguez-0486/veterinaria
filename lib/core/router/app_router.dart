// ═══════════════════════════════════════════════════════════════════════════
//  app_router.dart  —  Rutas con refreshListenable para logout correcto
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/modelos/usuario_modelo.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/auth/bienvenida_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/registro_screen.dart';
import '../../presentation/screens/admin/admin_shell.dart';
import '../../presentation/screens/cliente/cliente_shell.dart';

class AppRutas {
  AppRutas._();
  static const String bienvenida = '/bienvenida';
  static const String login = '/login';
  static const String registro = '/registro';
  static const String panel = '/panel';
  static const String cliente = '/cliente';
}

class AppRouter {
  AppRouter._();

  /// Crea el router inyectando el ProveedorAuth como refreshListenable.
  /// Así go_router re-evalúa el redirect automáticamente cuando el
  /// estado de autenticación cambia (login, logout, registro).
  static GoRouter crearRouter(ProveedorAuth auth) => GoRouter(
        initialLocation: AppRutas.bienvenida,
        debugLogDiagnostics: true,
        refreshListenable: auth, // ← clave para que logout redirija
        redirect: (context, state) => _guardia(auth, state),
        routes: [
          GoRoute(
            path: AppRutas.bienvenida,
            name: 'bienvenida',
            builder: (_, __) => const BienvenidaScreen(),
          ),
          GoRoute(
            path: AppRutas.login,
            name: 'login',
            builder: (_, __) => const LoginScreen(),
          ),
          GoRoute(
            path: AppRutas.registro,
            name: 'registro',
            builder: (_, __) => const RegistroScreen(),
          ),
          GoRoute(
            path: AppRutas.panel,
            name: 'panel',
            builder: (_, __) => const AdminShell(),
          ),
          GoRoute(
            path: AppRutas.cliente,
            name: 'cliente',
            builder: (_, __) => const ClienteShell(),
          ),
        ],
        errorBuilder: (_, state) => Scaffold(
          backgroundColor: const Color(0xFFFEFAE0),
          body: Center(
            child: Text(
              'Ruta no encontrada: ${state.uri.path}',
              style: const TextStyle(color: Color(0xFFBC6C25)),
            ),
          ),
        ),
      );

  static String? _guardia(ProveedorAuth auth, GoRouterState state) {
    if (auth.estado == EstadoAuth.inicial ||
        auth.estado == EstadoAuth.cargando) {
      return null;
    }

    final autenticado = auth.estaAutenticado;
    final rutaActual = state.matchedLocation;
    final rutasPublicas = [
      AppRutas.bienvenida,
      AppRutas.login,
      AppRutas.registro,
    ];
    final enRutaPublica = rutasPublicas.contains(rutaActual);

    if (!autenticado) {
      return enRutaPublica ? null : AppRutas.bienvenida;
    }

    final rol = auth.usuario?.rol ?? RolUsuario.cliente;
    final esAdminOEmpleado =
        rol == RolUsuario.admin || rol == RolUsuario.empleado;
    final destino = esAdminOEmpleado ? AppRutas.panel : AppRutas.cliente;

    if (enRutaPublica) return destino;

    if (!esAdminOEmpleado && rutaActual.startsWith(AppRutas.panel)) {
      return AppRutas.cliente;
    }
    if (esAdminOEmpleado && rutaActual.startsWith(AppRutas.cliente)) {
      return AppRutas.panel;
    }

    return null;
  }
}
