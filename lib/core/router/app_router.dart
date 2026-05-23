// ═══════════════════════════════════════════════════════════════════════════
//  app_router.dart  —  Rutas de la aplicación (Fase 4 completa)
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/auth/bienvenida_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/registro_screen.dart';
import '../../presentation/screens/admin/admin_shell.dart';

class AppRutas {
  AppRutas._();
  static const String bienvenida = '/bienvenida';
  static const String login = '/login';
  static const String registro = '/registro';
  static const String panel = '/panel';
}

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRutas.bienvenida,
    debugLogDiagnostics: true,
    redirect: _guardia,
    routes: [
      GoRoute(
        path: AppRutas.bienvenida,
        name: 'bienvenida',
        builder: (context, state) => const BienvenidaScreen(),
      ),
      GoRoute(
        path: AppRutas.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRutas.registro,
        name: 'registro',
        builder: (context, state) => const RegistroScreen(),
      ),
      GoRoute(
        path: AppRutas.panel,
        name: 'panel',
        builder: (context, state) => const AdminShell(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFFFEFAE0),
      body: Center(
        child: Text(
          'Ruta no encontrada: ${state.uri.path}',
          style: const TextStyle(color: Color(0xFFBC6C25)),
        ),
      ),
    ),
  );

  static String? _guardia(BuildContext context, GoRouterState state) {
    final auth = context.read<ProveedorAuth>();
    final autenticado = auth.estaAutenticado;
    final rutasPublicas = [
      AppRutas.bienvenida,
      AppRutas.login,
      AppRutas.registro,
    ];
    final enRutaPublica = rutasPublicas.contains(state.matchedLocation);

    if (!autenticado && !enRutaPublica) return AppRutas.bienvenida;
    if (autenticado && enRutaPublica) return AppRutas.panel;
    return null;
  }
}
