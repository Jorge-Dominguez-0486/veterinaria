// ═══════════════════════════════════════════════════════════════════════════
//  admin_shell.dart  —  Shell del Panel de Administración
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'dashboard_screen.dart';
import 'clientes_screen.dart';
import 'mascotas_screen.dart';
import 'citas_screen.dart';
import 'inventario_screen.dart';
import 'rrhh_screen.dart';
import 'finanzas_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _indice = 0;

  static const _destinos = [
    _NavDestino(Icons.dashboard_rounded, Icons.dashboard_outlined, 'Inicio'),
    _NavDestino(Icons.people_rounded, Icons.people_outline_rounded, 'Clientes'),
    _NavDestino(Icons.pets_rounded, Icons.pets_outlined, 'Mascotas'),
    _NavDestino(
        Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Citas'),
    _NavDestino(
        Icons.inventory_2_rounded, Icons.inventory_2_outlined, 'Inventario'),
    _NavDestino(Icons.badge_rounded, Icons.badge_outlined, 'RRHH'),
    _NavDestino(Icons.attach_money_rounded, Icons.money_outlined, 'Finanzas'),
  ];

  static const _titulos = [
    'Dashboard',
    'Clientes',
    'Mascotas',
    'Citas',
    'Inventario',
    'RRHH',
    'Finanzas',
  ];

  static const _pantallas = [
    DashboardScreen(),
    ClientesScreen(),
    MascotasScreen(),
    CitasScreen(),
    InventarioScreen(),
    RrhhScreen(),
    FinanzasScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final esEscritorio = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: AppColors.primario,
        foregroundColor: AppColors.blanco,
        title: Row(
          children: [
            const Icon(Icons.pets_rounded, size: 22),
            const SizedBox(width: 8),
            Text(
              'Polivet Pro · ${_titulos[_indice]}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
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
      body: esEscritorio
          ? Row(
              children: [
                _RailNav(
                  indice: _indice,
                  destinos: _destinos,
                  onCambio: (i) => setState(() => _indice = i),
                ),
                const VerticalDivider(width: 1, color: AppColors.borde),
                Expanded(child: _pantallas[_indice]),
              ],
            )
          : _pantallas[_indice],
      bottomNavigationBar: esEscritorio
          ? null
          : _BottomNav(
              indice: _indice,
              destinos: _destinos,
              onCambio: (i) => setState(() => _indice = i),
            ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget? _buildFab() {
    if (_indice == 0) return null;
    final labels = [
      '',
      'Agregar cliente',
      'Agregar mascota',
      'Nueva cita',
      'Nuevo producto',
      'Nuevo empleado',
      'Nueva venta'
    ];
    final icons = [
      null,
      Icons.person_add_rounded,
      Icons.add_rounded,
      Icons.event_available_rounded,
      Icons.add_box_rounded,
      Icons.person_add_rounded,
      Icons.receipt_long_rounded
    ];
    final keys = [
      'fab_clientes',
      'fab_mascotas',
      'fab_citas',
      'fab_inventario',
      'fab_rrhh',
      'fab_finanzas'
    ];
    return FloatingActionButton.extended(
      key: ValueKey(keys[_indice - 1]),
      backgroundColor: AppColors.primario,
      foregroundColor: AppColors.blanco,
      icon: Icon(icons[_indice]),
      label: Text(labels[_indice]),
      onPressed: () {
        final ctx = context;
        switch (_indice) {
          case 1:
            // TODO: Se activará cuando reparemos ClientesScreen
            // ClientesScreen.abrirFormulario(ctx);
            break;
          case 2:
            // TODO: Se activará cuando reparemos MascotasScreen
            // MascotasScreen.abrirFormulario(ctx);
            break;
          case 3:
            // CitasScreen.abrirFormulario(ctx);
            break;
          case 4:
            // InventarioScreen.abrirFormulario(ctx);
            break;
          case 5:
            // RrhhScreen.abrirFormulario(ctx);
            break;
          case 6:
            // FinanzasScreen.abrirFormulario(ctx);
            break;
        }
      },
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int indice;
  final List<_NavDestino> destinos;
  final ValueChanged<int> onCambio;

  const _BottomNav(
      {required this.indice, required this.destinos, required this.onCambio});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: indice,
      onDestinationSelected: onCambio,
      backgroundColor: AppColors.fondoTarjeta,
      indicatorColor: AppColors.secundario.withOpacity(0.3),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      destinations: destinos
          .map((d) => NavigationDestination(
                icon: Icon(d.iconoOff, color: AppColors.textoMedio),
                selectedIcon: Icon(d.icono, color: AppColors.primario),
                label: d.label,
              ))
          .toList(),
    );
  }
}

class _RailNav extends StatelessWidget {
  final int indice;
  final List<_NavDestino> destinos;
  final ValueChanged<int> onCambio;

  const _RailNav(
      {required this.indice, required this.destinos, required this.onCambio});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: indice,
      onDestinationSelected: onCambio,
      backgroundColor: AppColors.fondoTarjeta,
      indicatorColor: AppColors.secundario.withOpacity(0.25),
      selectedIconTheme: const IconThemeData(color: AppColors.primario),
      unselectedIconTheme: const IconThemeData(color: AppColors.textoMedio),
      selectedLabelTextStyle: const TextStyle(
          color: AppColors.primario, fontWeight: FontWeight.w700, fontSize: 12),
      unselectedLabelTextStyle:
          const TextStyle(color: AppColors.textoMedio, fontSize: 12),
      labelType: NavigationRailLabelType.all,
      leading: const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Icon(Icons.pets_rounded, color: AppColors.primario, size: 30),
      ),
      destinations: destinos
          .map((d) => NavigationRailDestination(
                icon: Icon(d.iconoOff),
                selectedIcon: Icon(d.icono),
                label: Text(d.label),
              ))
          .toList(),
    );
  }
}

class _NavDestino {
  final IconData icono;
  final IconData iconoOff;
  final String label;
  const _NavDestino(this.icono, this.iconoOff, this.label);
}
