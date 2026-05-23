// ═══════════════════════════════════════════════════════════════════════════
//  inventario_screen.dart
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/modelos/producto_inventario_modelo.dart';
import '../../providers/inventario_provider.dart';
import '../../providers/catalogos_provider.dart';
import 'widgets/widgets_comunes.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  static void abrirFormulario(BuildContext context,
      {ProductoModelo? producto}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.fondo,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FormProducto(producto: producto),
    );
  }

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _busqueda = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProveedorInventario>().cargarTodo();
      context.read<ProveedorCatalogos>().cargarTodo();
    });
    _busqueda.addListener(() => setState(() => _query = _busqueda.text));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _busqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProveedorInventario>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child:
              BarraBusqueda(controller: _busqueda, hint: 'Buscar producto...'),
        ),
        TabBar(
          controller: _tabs,
          labelColor: AppColors.primario,
          unselectedLabelColor: AppColors.textoMedio,
          indicatorColor: AppColors.primario,
          tabs: [
            Tab(text: 'Todos (${prov.productos.length})'),
            Tab(text: 'Stock bajo (${prov.productosStockBajo.length})'),
          ],
        ),
        Expanded(
          child: prov.cargando
              ? const CargandoIndicador()
              : TabBarView(
                  controller: _tabs,
                  children: [
                    _ListaProductos(
                        productos: prov.productos, query: _query, prov: prov),
                    _ListaProductos(
                        productos: prov.productosStockBajo,
                        query: _query,
                        prov: prov,
                        esAlerta: true),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ListaProductos extends StatelessWidget {
  final List<ProductoModelo> productos;
  final String query;
  final ProveedorInventario prov;
  final bool esAlerta;
  const _ListaProductos(
      {required this.productos,
      required this.query,
      required this.prov,
      this.esAlerta = false});

  @override
  Widget build(BuildContext context) {
    final filtrados = query.isEmpty
        ? productos
        : productos
            .where((p) => p.nombre.toLowerCase().contains(query.toLowerCase()))
            .toList();

    if (filtrados.isEmpty) {
      return EstadoVacio(
        mensaje: esAlerta
            ? 'Sin productos con stock bajo 🎉'
            : 'No hay productos registrados',
        icono: Icons.inventory_2_rounded,
        labelBoton: 'Nuevo producto',
        onBoton: () => InventarioScreen.abrirFormulario(context),
      );
    }

    return RefreshIndicator(
      color: AppColors.primario,
      onRefresh: () => context.read<ProveedorInventario>().cargarTodo(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtrados.length,
        itemBuilder: (_, i) => _ProductoTile(
          producto: filtrados[i],
          stock: prov.stockDe(filtrados[i].id),
          stockMin: prov.stockMinimoDe(filtrados[i].id),
          onEditar: () =>
              InventarioScreen.abrirFormulario(context, producto: filtrados[i]),
          onEliminar: () => _eliminar(context, filtrados[i]),
          onAjustar: () => _ajustarStock(context, filtrados[i]),
        ),
      ),
    );
  }

  Future<void> _eliminar(BuildContext context, ProductoModelo p) async {
    final ok = await confirmarEliminacion(context,
        titulo: 'Eliminar producto', descripcion: '¿Desactivar a ${p.nombre}?');
    if (ok == true) {
      final exito =
          await context.read<ProveedorInventario>().eliminarProducto(p.id);
      if (context.mounted) {
        exito
            ? mostrarExito(context, 'Producto desactivado')
            : mostrarError(context, 'Error');
      }
    }
  }

  void _ajustarStock(BuildContext context, ProductoModelo p) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.fondo,
        title: Text('Ajustar stock: ${p.nombre}'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: 'Nueva cantidad',
              prefixIcon: Icon(Icons.inventory_rounded)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final cantidad = int.tryParse(ctrl.text) ?? -1;
              if (cantidad < 0) return;
              Navigator.of(ctx).pop();
              final exito = await context
                  .read<ProveedorInventario>()
                  .ajustarStock(p.id, cantidad);
              if (context.mounted) {
                exito
                    ? mostrarExito(context, 'Stock actualizado')
                    : mostrarError(context, 'Error');
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _ProductoTile extends StatelessWidget {
  final ProductoModelo producto;
  final int stock;
  final int stockMin;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final VoidCallback onAjustar;
  const _ProductoTile({
    required this.producto,
    required this.stock,
    required this.stockMin,
    required this.onEditar,
    required this.onEliminar,
    required this.onAjustar,
  });

  @override
  Widget build(BuildContext context) {
    final stockBajo = stock <= stockMin;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: stockBajo
              ? AppColors.error.withOpacity(0.12)
              : AppColors.exito.withOpacity(0.12),
          child: Icon(Icons.inventory_2_rounded,
              color: stockBajo ? AppColors.error : AppColors.exito, size: 22),
        ),
        title: Text(producto.nombre,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(
          'Stock: $stock · Mín: $stockMin · \$${producto.precioVenta.toStringAsFixed(2)}',
          style: TextStyle(
              fontSize: 12,
              color: stockBajo ? AppColors.error : AppColors.textoMedio),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                tooltip: 'Ajustar stock',
                icon: const Icon(Icons.add_circle_outline_rounded,
                    color: AppColors.exito, size: 20),
                onPressed: onAjustar),
            IconButton(
                icon: const Icon(Icons.edit_rounded,
                    color: AppColors.primario, size: 20),
                onPressed: onEditar),
            IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: 20),
                onPressed: onEliminar),
          ],
        ),
      ),
    );
  }
}

// ── Formulario producto ───────────────────────────────────────────────────
class _FormProducto extends StatefulWidget {
  final ProductoModelo? producto;
  const _FormProducto({this.producto});
  @override
  State<_FormProducto> createState() => _FormProductoState();
}

class _FormProductoState extends State<_FormProducto> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;
  late final TextEditingController _precioCompra;
  late final TextEditingController _precioVenta;
  late final TextEditingController _unidad;
  late final TextEditingController _stockInicial;
  late final TextEditingController _stockMin;
  late final TextEditingController _stockMax;
  String? _categoriaId;
  bool _guardando = false;

  bool get _esEdicion => widget.producto != null;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _nombre = TextEditingController(text: p?.nombre ?? '');
    _descripcion = TextEditingController(text: p?.descripcion ?? '');
    _precioCompra =
        TextEditingController(text: p?.precioCompra.toString() ?? '');
    _precioVenta = TextEditingController(text: p?.precioVenta.toString() ?? '');
    _unidad = TextEditingController(text: p?.unidadMedida ?? 'pieza');
    _stockInicial = TextEditingController(text: '0');
    _stockMin = TextEditingController(text: '5');
    _stockMax = TextEditingController(text: '100');
    _categoriaId = p?.categoriaId;
  }

  @override
  void dispose() {
    for (final c in [
      _nombre,
      _descripcion,
      _precioCompra,
      _precioVenta,
      _unidad,
      _stockInicial,
      _stockMin,
      _stockMax
    ]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogos = context.watch<ProveedorCatalogos>();

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
              _EncabezadoForm(
                  titulo: _esEdicion ? 'Editar producto' : 'Nuevo producto',
                  onCerrar: () => Navigator.of(context).pop()),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre *'),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcion,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _categoriaId,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: catalogos.categorias
                    .map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.nombre)))
                    .toList(),
                onChanged: (v) => setState(() => _categoriaId = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    controller: _precioCompra,
                    decoration: const InputDecoration(
                        labelText: 'Precio compra', prefixText: '\$'),
                    keyboardType: TextInputType.number,
                  )),
                  const SizedBox(width: 12),
                  Expanded(
                      child: TextFormField(
                    controller: _precioVenta,
                    decoration: const InputDecoration(
                        labelText: 'Precio venta *', prefixText: '\$'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  )),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _unidad,
                decoration:
                    const InputDecoration(labelText: 'Unidad de medida'),
              ),
              if (!_esEdicion) ...[
                const SizedBox(height: 16),
                Text('Stock inicial',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: AppColors.textoMedio)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                            controller: _stockInicial,
                            decoration:
                                const InputDecoration(labelText: 'Cantidad'),
                            keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: TextFormField(
                            controller: _stockMin,
                            decoration:
                                const InputDecoration(labelText: 'Mínimo'),
                            keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: TextFormField(
                            controller: _stockMax,
                            decoration:
                                const InputDecoration(labelText: 'Máximo'),
                            keyboardType: TextInputType.number)),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              _BotonGuardar(
                  guardando: _guardando,
                  esEdicion: _esEdicion,
                  onGuardar: _guardar),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);
    final prov = context.read<ProveedorInventario>();
    bool exito;
    if (_esEdicion) {
      exito = await prov.actualizarProducto(widget.producto!.copyWith(
        nombre: _nombre.text.trim(),
        descripcion: _descripcion.text.trim(),
        categoriaId: _categoriaId ?? '',
        precioCompra: double.tryParse(_precioCompra.text) ?? 0,
        precioVenta: double.tryParse(_precioVenta.text) ?? 0,
        unidadMedida: _unidad.text.trim(),
      ));
    } else {
      exito = await prov.crearProductoConStock(
        ProductoModelo(
          id: '',
          nombre: _nombre.text.trim(),
          descripcion: _descripcion.text.trim(),
          categoriaId: _categoriaId ?? '',
          proveedorId: '',
          precioCompra: double.tryParse(_precioCompra.text) ?? 0,
          precioVenta: double.tryParse(_precioVenta.text) ?? 0,
          unidadMedida: _unidad.text.trim(),
          activo: true,
        ),
        stockInicial: int.tryParse(_stockInicial.text) ?? 0,
        stockMinimo: int.tryParse(_stockMin.text) ?? 5,
        stockMaximo: int.tryParse(_stockMax.text) ?? 100,
      );
    }
    if (mounted) {
      Navigator.of(context).pop();
      exito
          ? mostrarExito(
              context, _esEdicion ? 'Producto actualizado' : 'Producto creado')
          : mostrarError(context, prov.error ?? 'Error');
    }
  }
}
