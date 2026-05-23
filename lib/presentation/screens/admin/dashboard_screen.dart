// ═══════════════════════════════════════════════════════════════════════════
//  dashboard_screen.dart
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/clientes_mascotas_provider.dart';
import '../../providers/veterinaria_provider.dart';
import '../../providers/inventario_provider.dart';
import '../../providers/finanzas_provider.dart';
import '../../providers/rrhh_provider.dart';
// ¡Ruta corregida aquí! 👇
import '../../widgets/widgets_comunes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProveedorClientes>().cargarClientes();
      context.read<ProveedorMascotas>().cargarMascotas();
      context.read<ProveedorVeterinaria>().cargarTodo();
      context.read<ProveedorInventario>().cargarTodo();
      context.read<ProveedorFinanzas>().cargarTodo();
      context.read<ProveedorRRHH>().cargarTodo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ProveedorAuth>();
    final clientes = context.watch<ProveedorClientes>();
    final mascotas = context.watch<ProveedorMascotas>();
    final vet = context.watch<ProveedorVeterinaria>();
    final inv = context.watch<ProveedorInventario>();
    final fin = context.watch<ProveedorFinanzas>();
    final rrhh = context.watch<ProveedorRRHH>();

    final hora = TimeOfDay.now().hour;
    final saludo = hora < 12
        ? 'Buenos días'
        : hora < 18
            ? 'Buenas tardes'
            : 'Buenas noches';
    final nombre = auth.usuario?.nombreCompleto.split(' ').first ?? 'Admin';

    return RefreshIndicator(
      color: AppColors.primario,
      onRefresh: () async {
        await Future.wait([
          context.read<ProveedorClientes>().cargarClientes(),
          context.read<ProveedorMascotas>().cargarMascotas(),
          context.read<ProveedorVeterinaria>().cargarTodo(),
          context.read<ProveedorInventario>().cargarTodo(),
          context.read<ProveedorFinanzas>().cargarTodo(),
          context.read<ProveedorRRHH>().cargarTodo(),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Saludo ────────────────────────────────────────────────
          _TarjetaSaludo(saludo: saludo, nombre: nombre),
          const SizedBox(height: 20),

          // ── KPIs principales ──────────────────────────────────────
          Text('Resumen general', style: _estiloSeccion(context)),
          const SizedBox(height: 10),
          _GridKpis(children: [
            _KpiCard(
              icono: Icons.people_rounded,
              label: 'Clientes activos',
              valor: '${clientes.clientesActivos.length}',
              color: AppColors.informacion,
            ),
            _KpiCard(
              icono: Icons.pets_rounded,
              label: 'Mascotas',
              valor: '${mascotas.mascotas.length}',
              color: AppColors.primario,
            ),
            _KpiCard(
              icono: Icons.calendar_today_rounded,
              label: 'Citas hoy',
              valor: '${vet.citasHoy.length}',
              color: AppColors.advertencia,
            ),
            _KpiCard(
              icono: Icons.event_rounded,
              label: 'Citas programadas',
              valor: '${vet.citasProgramadas.length}',
              color: AppColors.secundario,
            ),
            _KpiCard(
              icono: Icons.inventory_2_rounded,
              label: 'Productos',
              valor: '${inv.productos.length}',
              color: AppColors.exito,
            ),
            _KpiCard(
              icono: Icons.warning_amber_rounded,
              label: 'Stock bajo',
              valor: '${inv.stockBajo.length}', // Corrección aquí
              color: AppColors.error,
            ),
            _KpiCard(
              icono: Icons.badge_rounded,
              label: 'Empleados activos',
              valor: '${rrhh.empleadosActivos.length}',
              color: AppColors.textoMedio,
            ),
            _KpiCard(
              icono: Icons.receipt_long_rounded,
              label: 'Ventas del mes',
              valor: '\$${fin.totalVentasMes.toStringAsFixed(0)}',
              color: AppColors.exito,
            ),
          ]),
          const SizedBox(height: 24),

          // ── Citas de hoy ──────────────────────────────────────────
          Text('Citas de hoy', style: _estiloSeccion(context)),
          const SizedBox(height: 10),
          if (vet.citasHoy.isEmpty)
            const _MensajeVacioInline(
                texto: 'No hay citas programadas para hoy')
          else
            ...vet.citasHoy.map((c) => _CitaMiniTile(
                  mascotaId: c.mascotaId,
                  hora:
                      '${c.fechaHora.hour.toString().padLeft(2, '0')}:${c.fechaHora.minute.toString().padLeft(2, '0')}',
                  motivo: c.motivo,
                  estado: c.estado,
                  mascotas: mascotas,
                  clientes: clientes,
                )),
          const SizedBox(height: 24),

          // ── Alertas de stock ──────────────────────────────────────
          if (inv.stockBajo.isNotEmpty) ...[
            Text('⚠️ Alertas de inventario', style: _estiloSeccion(context)),
            const SizedBox(height: 10),
            // Corrección lógica aquí 👇
            ...inv.stockBajo.take(5).map((item) {
              final prod = inv.obtenerProductoPorId(item.productoId);
              return _AlertaStockTile(
                nombre: prod?.nombre ?? 'Producto Desconocido',
                stockActual: item.cantidadActual,
                stockMinimo: item.cantidadMinima,
              );
            }),
            const SizedBox(height: 24),
          ],

          // ── Últimas ventas ────────────────────────────────────────
          Text('Últimas ventas', style: _estiloSeccion(context)),
          const SizedBox(height: 10),
          if (fin.ventas.isEmpty)
            const _MensajeVacioInline(texto: 'Sin ventas registradas')
          else
            ...fin.ventas.take(5).map((v) => _VentaMiniTile(
                  fecha: v.fecha,
                  total: v.total,
                  estado: v.estado,
                  metodoPago: v.metodoPago,
                )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  TextStyle _estiloSeccion(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!.copyWith(
            color: AppColors.textoOscuro,
            fontWeight: FontWeight.w700,
          );
}

// ── Tarjeta de saludo ─────────────────────────────────────────────────────
class _TarjetaSaludo extends StatelessWidget {
  final String saludo;
  final String nombre;
  const _TarjetaSaludo({required this.saludo, required this.nombre});

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    final dias = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo'
    ];
    final fechaStr =
        '${dias[hoy.weekday - 1].substring(0, 1).toUpperCase()}${dias[hoy.weekday - 1].substring(1)}, ${hoy.day} de ${meses[hoy.month - 1]}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primario, AppColors.primarioClaro],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.primario.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$saludo, $nombre 👋',
                    style: const TextStyle(
                        color: AppColors.blanco,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(fechaStr,
                    style: TextStyle(
                        color: AppColors.blanco.withOpacity(0.85),
                        fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.pets_rounded, color: Colors.white38, size: 52),
        ],
      ),
    );
  }
}

// ── Grid de KPIs ──────────────────────────────────────────────────────────
class _GridKpis extends StatelessWidget {
  final List<Widget> children;
  const _GridKpis({required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: children,
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;
  final Color color;
  const _KpiCard(
      {required this.icono,
      required this.label,
      required this.valor,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icono, color: color, size: 20),
                const Spacer(),
                Text(valor,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: color)),
              ],
            ),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textoMedio,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Cita mini tile ────────────────────────────────────────────────────────
class _CitaMiniTile extends StatelessWidget {
  final String mascotaId;
  final String hora;
  final String motivo;
  final String estado;
  final ProveedorMascotas mascotas;
  final ProveedorClientes clientes;
  const _CitaMiniTile({
    required this.mascotaId,
    required this.hora,
    required this.motivo,
    required this.estado,
    required this.mascotas,
    required this.clientes,
  });

  @override
  Widget build(BuildContext context) {
    final mascota =
        mascotas.mascotas.where((m) => m.id == mascotaId).firstOrNull;
    final cliente =
        mascota != null ? clientes.obtenerPorId(mascota.clienteId) : null;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primario.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(hora,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primario,
                  fontSize: 13)),
        ),
        title: Text(mascota?.nombre ?? mascotaId,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text('${cliente?.nombreCompleto ?? ''} · $motivo',
            style: const TextStyle(fontSize: 11)),
        trailing: ChipEstado(estado: estado),
      ),
    );
  }
}

// ── Alerta stock tile ─────────────────────────────────────────────────────
class _AlertaStockTile extends StatelessWidget {
  final String nombre;
  final int stockActual;
  final int stockMinimo;
  const _AlertaStockTile(
      {required this.nombre,
      required this.stockActual,
      required this.stockMinimo});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.warning_amber_rounded,
            color: AppColors.error, size: 22),
        title: Text(nombre,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text('Stock: $stockActual · Mínimo: $stockMinimo',
            style: const TextStyle(fontSize: 11)),
        trailing: const ChipEstado(estado: 'pendiente'),
      ),
    );
  }
}

// ── Venta mini tile ───────────────────────────────────────────────────────
class _VentaMiniTile extends StatelessWidget {
  final DateTime fecha;
  final double total;
  final String estado;
  final String metodoPago;
  const _VentaMiniTile(
      {required this.fecha,
      required this.total,
      required this.estado,
      required this.metodoPago});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.receipt_rounded,
            color: AppColors.primario, size: 22),
        title: Text('\$${total.toStringAsFixed(2)}',
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.primario)),
        subtitle: Text(
            '${fecha.day}/${fecha.month}/${fecha.year} · $metodoPago',
            style: const TextStyle(fontSize: 11)),
        trailing: ChipEstado(estado: estado),
      ),
    );
  }
}

class _MensajeVacioInline extends StatelessWidget {
  final String texto;
  const _MensajeVacioInline({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(texto,
          style: const TextStyle(
              color: AppColors.textoClaro,
              fontSize: 13,
              fontStyle: FontStyle.italic)),
    );
  }
}
