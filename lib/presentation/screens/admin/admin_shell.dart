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
import 'catalogos_screen.dart';
import 'usuarios_roles_screen.dart';
import '../cliente/cliente_shell.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _indice = 0;

  // GlobalKey para poder llamar abrirNuevo() desde el FAB
  final _catalogosKey = GlobalKey<CatalogosScreenState>();

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
    _NavDestino(Icons.menu_book_rounded, Icons.menu_book_outlined, 'Catálogos'),
    _NavDestino(Icons.manage_accounts_rounded, Icons.manage_accounts_outlined,
        'Usuarios'),
  ];

  static const _titulos = [
    'Dashboard',
    'Clientes',
    'Mascotas',
    'Citas',
    'Inventario',
    'RRHH',
    'Finanzas',
    'Catálogos',
    'Usuarios',
  ];

  List<Widget> get _pantallas => [
        const DashboardScreen(),
        const ClientesScreen(),
        const MascotasScreen(),
        const CitasScreen(),
        const InventarioScreen(),
        const RrhhScreen(),
        const FinanzasScreen(),
        CatalogosScreen(key: _catalogosKey),
        const UsuariosRolesScreen(),
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
          // Botón para previsualizar la app como la ve un cliente
          IconButton(
            tooltip: 'Ver vista del cliente',
            icon: const Icon(Icons.preview_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => const _VistaClientePreview(),
              ),
            ),
          ),
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
      'Nueva venta',
      'Nuevo registro',
      '', // Usuarios no tiene FAB
    ];
    final icons = [
      null,
      Icons.person_add_rounded,
      Icons.add_rounded,
      Icons.event_available_rounded,
      Icons.add_box_rounded,
      Icons.person_add_rounded,
      Icons.receipt_long_rounded,
      Icons.add_rounded,
      null,
    ];
    final keys = [
      'fab_clientes',
      'fab_mascotas',
      'fab_citas',
      'fab_inventario',
      'fab_rrhh',
      'fab_finanzas',
      'fab_catalogos',
      'fab_usuarios',
    ];

    // La pantalla de Usuarios no tiene FAB
    if (_indice == 8) return null;

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
            ClientesScreen.abrirFormulario(ctx);
          case 2:
            MascotasScreen.abrirFormulario(ctx);
          case 3:
            CitasScreen.abrirFormulario(ctx);
          case 4:
            InventarioScreen.abrirFormulario(ctx);
          case 5:
            RrhhScreen.abrirFormulario(ctx);
          case 6:
            FinanzasScreen.abrirFormulario(ctx);
          case 7:
            // Delega al State interno de CatalogosScreen
            _catalogosKey.currentState?.abrirNuevo();
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

// ── Vista previa del área de cliente (solo para admin) ────────────────────
class _VistaClientePreview extends StatelessWidget {
  const _VistaClientePreview();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ClienteShell(),
        // Banner indicador de que es modo previsualización
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 56),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility_rounded,
                        color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text('Vista previa — cliente',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavDestino {
  final IconData icono;
  final IconData iconoOff;
  final String label;
  const _NavDestino(this.icono, this.iconoOff, this.label);
}
