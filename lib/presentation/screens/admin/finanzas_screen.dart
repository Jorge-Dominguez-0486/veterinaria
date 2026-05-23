// ═══════════════════════════════════════════════════════════════════════════
//  finanzas_screen.dart
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/modelos/finanzas_modelo.dart';
import '../../providers/finanzas_provider.dart';
import '../../providers/clientes_mascotas_provider.dart';
import '../../providers/inventario_provider.dart';
import '../../providers/rrhh_provider.dart';
import '../../widgets/widgets_comunes.dart';

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({super.key});

  static void abrirFormulario(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.fondo,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _FormVenta(),
    );
  }

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProveedorFinanzas>().cargarTodo();
      context.read<ProveedorClientes>().cargarClientes();
      context.read<ProveedorInventario>().cargarTodo();
      context.read<ProveedorRRHH>().cargarTodo();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fin = context.watch<ProveedorFinanzas>();

    return Column(
      children: [
        // ── Resumen financiero ────────────────────────────────────────
        Container(
          color: AppColors.fondoTarjeta,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _ResumenChip(
                  label: 'Ventas/mes',
                  valor: '\$${fin.totalVentasMes.toStringAsFixed(0)}',
                  color: AppColors.exito),
              const SizedBox(width: 8),
              _ResumenChip(
                  label: 'Gastos/mes',
                  valor: '\$${fin.totalGastosMes.toStringAsFixed(0)}',
                  color: AppColors.error),
              const SizedBox(width: 8),
              _ResumenChip(
                label: 'Balance',
                valor:
                    '\$${(fin.totalVentasMes - fin.totalGastosMes).toStringAsFixed(0)}',
                color: (fin.totalVentasMes - fin.totalGastosMes) >= 0
                    ? AppColors.exito
                    : AppColors.error,
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabs,
          labelColor: AppColors.primario,
          unselectedLabelColor: AppColors.textoMedio,
          indicatorColor: AppColors.primario,
          tabs: const [
            Tab(text: 'Ventas'),
            Tab(text: 'Gastos'),
            Tab(text: 'Compras'),
          ],
        ),
        Expanded(
          child: fin.cargando
              ? const CargandoIndicador()
              : TabBarView(
                  controller: _tabs,
                  children: [
                    _ListaVentas(ventas: fin.ventas),
                    _ListaGastos(gastos: fin.gastos),
                    _ListaCompras(compras: fin.compras),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ResumenChip extends StatelessWidget {
  final String label;
  final String valor;
  final Color color;
  const _ResumenChip(
      {required this.label, required this.valor, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10, color: color, fontWeight: FontWeight.w600)),
            Text(valor,
                style: TextStyle(
                    fontSize: 15, color: color, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

// ── Lista ventas ──────────────────────────────────────────────────────────
class _ListaVentas extends StatelessWidget {
  final List<VentaModelo> ventas;
  const _ListaVentas({required this.ventas});

  @override
  Widget build(BuildContext context) {
    if (ventas.isEmpty) {
      return EstadoVacio(
        mensaje: 'No hay ventas registradas',
        icono: Icons.receipt_long_rounded,
        labelBoton: 'Nueva venta',
        onBoton: () => FinanzasScreen.abrirFormulario(context),
      );
    }
    return RefreshIndicator(
      color: AppColors.primario,
      onRefresh: () => context.read<ProveedorFinanzas>().cargarTodo(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ventas.length,
        itemBuilder: (_, i) => _VentaTile(venta: ventas[i]),
      ),
    );
  }
}

class _VentaTile extends StatelessWidget {
  final VentaModelo venta;
  const _VentaTile({required this.venta});

  @override
  Widget build(BuildContext context) {
    final clientes = context.watch<ProveedorClientes>();
    final cliente = clientes.obtenerPorId(venta.clienteId);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0x334CAF50),
          child: Icon(Icons.receipt_rounded, color: AppColors.exito, size: 22),
        ),
        title: Text(
          '\$${venta.total.toStringAsFixed(2)} · ${cliente?.nombreCompleto ?? 'Sin cliente'}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          '${_formatFecha(venta.fecha)} · ${venta.metodoPago} · ${venta.items.length} artículos',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChipEstado(estado: venta.estado),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 20),
              onPressed: () async {
                final ok = await confirmarEliminacion(context,
                    titulo: 'Eliminar venta',
                    descripcion: '¿Eliminar esta venta?');
                if (ok == true && context.mounted) {
                  final exito = await context
                      .read<ProveedorFinanzas>()
                      .eliminarVenta(venta.id);
                  if (context.mounted) {
                    exito
                        ? mostrarExito(context, 'Venta eliminada')
                        : mostrarError(context, 'Error');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatFecha(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}

// ── Lista gastos ──────────────────────────────────────────────────────────
class _ListaGastos extends StatelessWidget {
  final List<GastoModelo> gastos;
  const _ListaGastos({required this.gastos});

  @override
  Widget build(BuildContext context) {
    if (gastos.isEmpty) {
      return EstadoVacio(
        mensaje: 'No hay gastos registrados',
        icono: Icons.money_off_rounded,
        labelBoton: 'Registrar gasto',
        onBoton: () => _abrirFormGasto(context),
      );
    }
    return RefreshIndicator(
      color: AppColors.primario,
      onRefresh: () => context.read<ProveedorFinanzas>().cargarTodo(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: gastos.length,
        itemBuilder: (_, i) {
          final g = gastos[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0x33E53935),
                child: Icon(Icons.money_off_rounded,
                    color: AppColors.error, size: 22),
              ),
              title: Text(g.concepto,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(
                  '${g.categoria} · ${g.fecha.day}/${g.fecha.month}/${g.fecha.year}',
                  style: const TextStyle(fontSize: 12)),
              trailing: Text('\$${g.monto.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                      fontSize: 14)),
            ),
          );
        },
      ),
    );
  }

  void _abrirFormGasto(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.fondo,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _FormGasto(),
    );
  }
}

// ── Lista compras ─────────────────────────────────────────────────────────
class _ListaCompras extends StatelessWidget {
  final List<CompraModelo> compras;
  const _ListaCompras({required this.compras});

  @override
  Widget build(BuildContext context) {
    if (compras.isEmpty) {
      return const EstadoVacio(
        mensaje: 'No hay compras registradas',
        icono: Icons.shopping_cart_rounded,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: compras.length,
      itemBuilder: (_, i) {
        final c = compras[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0x331976D2),
              child: Icon(Icons.shopping_cart_rounded,
                  color: AppColors.informacion, size: 22),
            ),
            title: Text('\$${c.total.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text(
                '${c.fecha.day}/${c.fecha.month}/${c.fecha.year} · ${c.items.length} artículos',
                style: const TextStyle(fontSize: 12)),
            trailing: ChipEstado(estado: c.estado),
          ),
        );
      },
    );
  }
}

// ── Formulario venta ──────────────────────────────────────────────────────
class _FormVenta extends StatefulWidget {
  const _FormVenta();
  @override
  State<_FormVenta> createState() => _FormVentaState();
}

class _FormVentaState extends State<_FormVenta> {
  final _form = GlobalKey<FormState>();
  String? _clienteId;
  String? _empleadoId;
  String _metodoPago = 'efectivo';
  final List<ItemTransaccion> _items = [];
  final TextEditingController _notas = TextEditingController();
  bool _guardando = false;

  double get _total =>
      _items.fold(0, (s, i) => s + i.cantidad * i.precioUnitario);

  @override
  void dispose() {
    _notas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientes = context.watch<ProveedorClientes>();
    final inv = context.watch<ProveedorInventario>();
    final rrhh = context.watch<ProveedorRRHH>();

    return Padding(
      padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EncabezadoForm(
                  titulo: 'Nueva venta',
                  onCerrar: () => Navigator.of(context).pop()),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _clienteId,
                decoration: const InputDecoration(labelText: 'Cliente *'),
                items: clientes.clientesActivos
                    .map((c) => DropdownMenuItem(
                        value: c.id, child: Text(c.nombreCompleto)))
                    .toList(),
                onChanged: (v) => setState(() => _clienteId = v),
                validator: (v) => v == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _empleadoId,
                decoration: const InputDecoration(labelText: 'Empleado'),
                items: rrhh.empleadosActivos
                    .map((e) => DropdownMenuItem(
                        value: e.id, child: Text('${e.nombre} ${e.apellido}')))
                    .toList(),
                onChanged: (v) => setState(() => _empleadoId = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _metodoPago,
                decoration: const InputDecoration(labelText: 'Método de pago'),
                items: ['efectivo', 'tarjeta', 'transferencia']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _metodoPago = v ?? 'efectivo'),
              ),
              const SizedBox(height: 16),
              // Agregar productos
              Row(
                children: [
                  const Text('Productos',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textoOscuro)),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Agregar'),
                    onPressed: () => _agregarProducto(context, inv),
                  ),
                ],
              ),
              if (_items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Sin productos. Presiona Agregar.',
                      style: TextStyle(
                          color: AppColors.textoClaro,
                          fontSize: 13,
                          fontStyle: FontStyle.italic)),
                )
              else
                ..._items.asMap().entries.map((entry) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(entry.value.nombreProducto,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                          '${entry.value.cantidad} × \$${entry.value.precioUnitario.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              '\$${(entry.value.cantidad * entry.value.precioUnitario).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primario)),
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                size: 18, color: AppColors.error),
                            onPressed: () =>
                                setState(() => _items.removeAt(entry.key)),
                          ),
                        ],
                      ),
                    )),
              const Divider(),
              Align(
                alignment: Alignment.centerRight,
                child: Text('Total: \$${_total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primario)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notas,
                decoration: const InputDecoration(labelText: 'Notas'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              BotonGuardar(
                  guardando: _guardando, esEdicion: false, onGuardar: _guardar),
            ],
          ),
        ),
      ),
    );
  }

  void _agregarProducto(BuildContext context, ProveedorInventario inv) {
    String? productoId;
    final cantCtrl = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppColors.fondo,
          title: const Text('Agregar producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: productoId,
                decoration: const InputDecoration(labelText: 'Producto'),
                items: inv.productos
                    .map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(
                            '${p.nombre} - \$${p.precioVenta.toStringAsFixed(2)}')))
                    .toList(),
                onChanged: (v) => setS(() => productoId = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cantCtrl,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (productoId == null) return;
                final prod =
                    inv.productos.firstWhere((p) => p.id == productoId!);
                final cant = int.tryParse(cantCtrl.text) ?? 1;
                setState(() => _items.add(ItemTransaccion(
                      productoId: prod.id,
                      nombreProducto: prod.nombre,
                      cantidad: cant,
                      precioUnitario: prod.precioVenta,
                    )));
                Navigator.of(ctx).pop();
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    if (_items.isEmpty) {
      mostrarError(context, 'Agrega al menos un producto');
      return;
    }
    setState(() => _guardando = true);
    final prov = context.read<ProveedorFinanzas>();
    final exito = await prov.crearVenta(VentaModelo(
      id: '',
      clienteId: _clienteId ?? '',
      empleadoId: _empleadoId ?? '',
      items: _items,
      total: _total,
      descuento: 0,
      metodoPago: _metodoPago,
      estado: 'pagada',
      fecha: DateTime.now(),
      notas: _notas.text.trim(),
    ));
    if (mounted) {
      Navigator.of(context).pop();
      exito
          ? mostrarExito(context, 'Venta registrada')
          : mostrarError(context, prov.error ?? 'Error');
    }
  }
}

// ── Formulario gasto ──────────────────────────────────────────────────────
class _FormGasto extends StatefulWidget {
  const _FormGasto();
  @override
  State<_FormGasto> createState() => _FormGastoState();
}

class _FormGastoState extends State<_FormGasto> {
  final _form = GlobalKey<FormState>();
  final _concepto = TextEditingController();
  final _monto = TextEditingController();
  final _notas = TextEditingController();
  String _categoria = 'servicios';
  bool _guardando = false;

  @override
  void dispose() {
    _concepto.dispose();
    _monto.dispose();
    _notas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EncabezadoForm(
                titulo: 'Registrar gasto',
                onCerrar: () => Navigator.of(context).pop()),
            const SizedBox(height: 16),
            TextFormField(
              controller: _concepto,
              decoration: const InputDecoration(labelText: 'Concepto *'),
              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _categoria,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: ['servicios', 'nomina', 'mantenimiento', 'otros']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _categoria = v ?? 'servicios'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _monto,
              decoration:
                  const InputDecoration(labelText: 'Monto *', prefixText: '\$'),
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notas,
              decoration: const InputDecoration(labelText: 'Notas'),
            ),
            const SizedBox(height: 24),
            BotonGuardar(
                guardando: _guardando, esEdicion: false, onGuardar: _guardar),
          ],
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);
    final prov = context.read<ProveedorFinanzas>();
    final exito = await prov.crearGasto(GastoModelo(
      id: '',
      concepto: _concepto.text.trim(),
      categoria: _categoria,
      monto: double.tryParse(_monto.text) ?? 0,
      fecha: DateTime.now(),
      empleadoId: '',
      notas: _notas.text.trim(),
    ));
    if (mounted) {
      Navigator.of(context).pop();
      exito
          ? mostrarExito(context, 'Gasto registrado')
          : mostrarError(context, prov.error ?? 'Error');
    }
  }
}
