// ═══════════════════════════════════════════════════════════════════════════
//  cliente_shell.dart  —  Shell del área de cliente
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'cliente_inicio_screen.dart';
import 'cliente_mascotas_screen.dart';
import 'cliente_citas_screen.dart';
import 'cliente_perfil_screen.dart';

class ClienteShell extends StatefulWidget {
  const ClienteShell({super.key});

  @override
  State<ClienteShell> createState() => _ClienteShellState();
}

class _ClienteShellState extends State<ClienteShell> {
  int _indice = 0;

  static const _destinos = [
    _NavDestino(Icons.home_rounded, Icons.home_outlined, 'Inicio'),
    _NavDestino(Icons.pets_rounded, Icons.pets_outlined, 'Mis mascotas'),
    _NavDestino(
        Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Citas'),
    _NavDestino(Icons.person_rounded, Icons.person_outline_rounded, 'Perfil'),
  ];

  static const _titulos = ['Inicio', 'Mis mascotas', 'Citas', 'Mi perfil'];

  late final List<Widget> _pantallas = [
    const ClienteInicioScreen(),
    const ClienteMascotasScreen(),
    const ClienteCitasScreen(),
    const ClientePerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ProveedorAuth>();
    final nombre = auth.usuario?.nombre ?? 'Cliente';

    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: AppColors.primario,
        foregroundColor: AppColors.blanco,
        title: Row(
          children: [
            const Icon(Icons.pets_rounded, size: 20),
            const SizedBox(width: 8),
            Text(
              _indice == 0
                  ? 'Hola, $nombre 👋'
                  : 'Polivet Pro · ${_titulos[_indice]}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.fondo,
                  title: const Text('Cerrar sesión'),
                  content: const Text('¿Deseas salir de tu cuenta?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancelar')),
                    ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Salir')),
                  ],
                ),
              );
              if (ok == true && mounted) {
                context.read<ProveedorAuth>().cerrarSesion();
              }
            },
          ),
        ],
      ),
      body: IndexedStack(index: _indice, children: _pantallas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        backgroundColor: AppColors.fondoTarjeta,
        indicatorColor: AppColors.secundario.withOpacity(0.3),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: _destinos
            .map((d) => NavigationDestination(
                  icon: Icon(d.iconoOff, color: AppColors.textoMedio),
                  selectedIcon: Icon(d.icono, color: AppColors.primario),
                  label: d.label,
                ))
            .toList(),
      ),
    );
  }
}

class _NavDestino {
  final IconData icono;
  final IconData iconoOff;
  final String label;
  const _NavDestino(this.icono, this.iconoOff, this.label);
}
