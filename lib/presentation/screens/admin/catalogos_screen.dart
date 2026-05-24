// ═══════════════════════════════════════════════════════════════════════════
//  catalogos_screen.dart  —  Catálogos: Especies, Razas, Categorías, Proveedores
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/modelos/especie_modelo.dart';
import '../../../data/modelos/raza_modelo.dart';
import '../../../data/modelos/categoria_proveedor_modelo.dart';
import '../../providers/catalogos_provider.dart';
import '../../widgets/widgets_comunes.dart';

// ── Tabs disponibles ───────────────────────────────────────────────────────
enum _TabCatalogo { especies, razas, categorias, proveedores }

class CatalogosScreen extends StatefulWidget {
  const CatalogosScreen({super.key});

  static void abrirFormulario(BuildContext context) {
    // El FAB abre el diálogo de la pestaña activa; se maneja dentro del State
    // mediante GlobalKey, pero para simplicidad se deja vacío aquí.
    // El FAB en AdminShell llama a este método; la lógica real está en el State.
  }

  @override
  State<CatalogosScreen> createState() => CatalogosScreenState();
}

class CatalogosScreenState extends State<CatalogosScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  _TabCatalogo get _tabActual => _TabCatalogo.values[_tabCtrl.index];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProveedorCatalogos>().cargarTodo();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  /// Llamado desde AdminShell FAB
  void abrirNuevo() {
    switch (_tabActual) {
      case _TabCatalogo.especies:
        _mostrarFormEspecie(context);
      case _TabCatalogo.razas:
        _mostrarFormRaza(context);
      case _TabCatalogo.categorias:
        _mostrarFormCategoria(context);
      case _TabCatalogo.proveedores:
        _mostrarFormProveedor(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProveedorCatalogos>();

    return Column(
      children: [
        // ── TabBar ──────────────────────────────────────────────────────
        Material(
          color: AppColors.fondoTarjeta,
          child: TabBar(
            controller: _tabCtrl,
            labelColor: AppColors.primario,
            unselectedLabelColor: AppColors.textoMedio,
            indicatorColor: AppColors.primario,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(icon: Icon(Icons.category_rounded), text: 'Especies'),
              Tab(icon: Icon(Icons.pets_rounded), text: 'Razas'),
              Tab(icon: Icon(Icons.label_rounded), text: 'Categorías'),
              Tab(
                  icon: Icon(Icons.local_shipping_rounded),
                  text: 'Proveedores'),
            ],
          ),
        ),

        // ── Indicador de carga / error ───────────────────────────────────
        if (prov.cargando)
          const LinearProgressIndicator(
              backgroundColor: AppColors.fondoTarjeta,
              color: AppColors.primario),
        if (prov.error != null)
          MaterialBanner(
            content:
                Text(prov.error!, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red.shade700,
            actions: [
              TextButton(
                onPressed: prov.limpiarError,
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              )
            ],
          ),

        // ── Contenido de cada pestaña ────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _TabEspecies(
                  prov: prov, onNuevo: () => _mostrarFormEspecie(context)),
              _TabRazas(prov: prov, onNuevo: () => _mostrarFormRaza(context)),
              _TabCategorias(
                  prov: prov, onNuevo: () => _mostrarFormCategoria(context)),
              _TabProveedores(
                  prov: prov, onNuevo: () => _mostrarFormProveedor(context)),
            ],
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  DIÁLOGOS
  // ════════════════════════════════════════════════════════════════════════

  void _mostrarFormEspecie(BuildContext ctx, {EspecieModelo? especie}) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.fondo,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FormEspecie(especie: especie),
    );
  }

  void _mostrarFormRaza(BuildContext ctx, {RazaModelo? raza}) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.fondo,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FormRaza(raza: raza),
    );
  }

  void _mostrarFormCategoria(BuildContext ctx, {CategoriaModelo? cat}) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.fondo,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FormCategoria(categoria: cat),
    );
  }

  void _mostrarFormProveedor(BuildContext ctx, {ProveedorModelo? prov}) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.fondo,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FormProveedor(proveedor: prov),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  TAB ESPECIES
// ════════════════════════════════════════════════════════════════════════════
class _TabEspecies extends StatefulWidget {
  final ProveedorCatalogos prov;
  final VoidCallback onNuevo;
  const _TabEspecies({required this.prov, required this.onNuevo});

  @override
  State<_TabEspecies> createState() => _TabEspeciesState();
}

class _TabEspeciesState extends State<_TabEspecies> {
  final _ctrl = TextEditingController();
  String _q = '';

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() => _q = _ctrl.text));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lista = widget.prov.especies.where((e) {
      if (_q.isEmpty) return true;
      return e.nombre.toLowerCase().contains(_q.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: BarraBusqueda(controller: _ctrl, hint: 'Buscar especie…'),
        ),
        Expanded(
          child: lista.isEmpty
              ? EstadoVacio(
                  mensaje: 'No hay especies registradas',
                  icono: Icons.category_rounded,
                  labelBoton: 'Agregar especie',
                  onBoton: widget.onNuevo,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                  itemCount: lista.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _TarjetaEspecie(
                    especie: lista[i],
                    prov: widget.prov,
                  ),
                ),
        ),
      ],
    );
  }
}

class _TarjetaEspecie extends StatelessWidget {
  final EspecieModelo especie;
  final ProveedorCatalogos prov;
  const _TarjetaEspecie({required this.especie, required this.prov});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.fondoTarjeta,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.secundario.withOpacity(0.2),
          child: const Icon(Icons.category_rounded, color: AppColors.primario),
        ),
        title: Text(especie.nombre,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: especie.descripcion.isNotEmpty
            ? Text(especie.descripcion,
                maxLines: 1, overflow: TextOverflow.ellipsis)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ChipActivo(activo: especie.activo),
            const SizedBox(width: 4),
            _MenuAcciones(
              onEditar: () => _editarEspecie(context),
              onEliminar: () => _confirmarEliminar(context),
            ),
          ],
        ),
      ),
    );
  }

  void _editarEspecie(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.fondo,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FormEspecie(especie: especie),
    );
  }

  void _confirmarEliminar(BuildContext context) {
    _confirmarBorrado(
      context: context,
      nombre: especie.nombre,
      onConfirmar: () async {
        final ok = await prov.eliminarEspecie(especie.id);
        if (!ok && context.mounted) {
          _mostrarError(context, prov.error ?? 'Error al eliminar');
        }
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  TAB RAZAS
// ════════════════════════════════════════════════════════════════════════════
class _TabRazas extends StatefulWidget {
  final ProveedorCatalogos prov;
  final VoidCallback onNuevo;
  const _TabRazas({required this.prov, required this.onNuevo});

  @override
  State<_TabRazas> createState() => _TabRazasState();
}

class _TabRazasState extends State<_TabRazas> {
  final _ctrl = TextEditingController();
  String _q = '';
  String? _especieFiltro;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() => _q = _ctrl.text));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final especies = widget.prov.especies;
    List<RazaModelo> lista = widget.prov.razas;

    if (_especieFiltro != null) {
      lista = lista.where((r) => r.especieId == _especieFiltro).toList();
    }
    if (_q.isNotEmpty) {
      lista = lista
          .where((r) => r.nombre.toLowerCase().contains(_q.toLowerCase()))
          .toList();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: BarraBusqueda(controller: _ctrl, hint: 'Buscar raza…'),
        ),
        // Filtro por especie
        if (especies.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _ChipFiltro(
                  label: 'Todas',
                  seleccionado: _especieFiltro == null,
                  onTap: () => setState(() => _especieFiltro = null),
                ),
                ...especies.map((e) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: _ChipFiltro(
                        label: e.nombre,
                        seleccionado: _especieFiltro == e.id,
                        onTap: () => setState(() => _especieFiltro = e.id),
                      ),
                    )),
              ],
            ),
          ),
        Expanded(
          child: lista.isEmpty
              ? EstadoVacio(
                  mensaje: 'No hay razas registradas',
                  icono: Icons.pets_rounded,
                  labelBoton: 'Agregar raza',
                  onBoton: widget.onNuevo,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                  itemCount: lista.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _TarjetaRaza(
                    raza: lista[i],
                    prov: widget.prov,
                  ),
                ),
        ),
      ],
    );
  }
}

class _TarjetaRaza extends StatelessWidget {
  final RazaModelo raza;
  final ProveedorCatalogos prov;
  const _TarjetaRaza({required this.raza, required this.prov});

  @override
  Widget build(BuildContext context) {
    final especie = prov.obtenerEspeciePorId(raza.especieId);

    return Card(
      color: AppColors.fondoTarjeta,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.secundario.withOpacity(0.2),
          child: const Icon(Icons.pets_rounded, color: AppColors.primario),
        ),
        title: Text(raza.nombre,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(especie?.nombre ?? raza.especieId,
            style: const TextStyle(color: AppColors.textoMedio, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ChipActivo(activo: raza.activo),
            const SizedBox(width: 4),
            _MenuAcciones(
              onEditar: () => _editarRaza(context),
              onEliminar: () => _confirmarEliminar(context),
            ),
          ],
        ),
      ),
    );
  }

  void _editarRaza(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.fondo,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FormRaza(raza: raza),
    );
  }

  void _confirmarEliminar(BuildContext context) {
    _confirmarBorrado(
      context: context,
      nombre: raza.nombre,
      onConfirmar: () async {
        final ok = await prov.eliminarRaza(raza.id);
        if (!ok && context.mounted) {
          _mostrarError(context, prov.error ?? 'Error al eliminar');
        }
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  TAB CATEGORÍAS
// ════════════════════════════════════════════════════════════════════════════
class _TabCategorias extends StatefulWidget {
  final ProveedorCatalogos prov;
  final VoidCallback onNuevo;
  const _TabCategorias({required this.prov, required this.onNuevo});

  @override
  State<_TabCategorias> createState() => _TabCategoriasState();
}

class _TabCategoriasState extends State<_TabCategorias> {
  final _ctrl = TextEditingController();
  String _q = '';

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() => _q = _ctrl.text));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lista = widget.prov.categorias.where((c) {
      if (_q.isEmpty) return true;
      return c.nombre.toLowerCase().contains(_q.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: BarraBusqueda(controller: _ctrl, hint: 'Buscar categoría…'),
        ),
        Expanded(
          child: lista.isEmpty
              ? EstadoVacio(
                  mensaje: 'No hay categorías registradas',
                  icono: Icons.label_rounded,
                  labelBoton: 'Agregar categoría',
                  onBoton: widget.onNuevo,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                  itemCount: lista.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _TarjetaCategoria(
                    cat: lista[i],
                    prov: widget.prov,
                  ),
                ),
        ),
      ],
    );
  }
}

class _TarjetaCategoria extends StatelessWidget {
  final CategoriaModelo cat;
  final ProveedorCatalogos prov;
  const _TarjetaCategoria({required this.cat, required this.prov});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.fondoTarjeta,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.secundario.withOpacity(0.2),
          child: const Icon(Icons.label_rounded, color: AppColors.primario),
        ),
        title: Text(cat.nombre,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: cat.descripcion.isNotEmpty
            ? Text(cat.descripcion,
                maxLines: 1, overflow: TextOverflow.ellipsis)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ChipActivo(activo: cat.activo),
            const SizedBox(width: 4),
            _MenuAcciones(
              onEditar: () => _editar(context),
              onEliminar: () => _confirmarEliminar(context),
            ),
          ],
        ),
      ),
    );
  }

  void _editar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.fondo,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FormCategoria(categoria: cat),
    );
  }

  void _confirmarEliminar(BuildContext context) {
    _confirmarBorrado(
      context: context,
      nombre: cat.nombre,
      onConfirmar: () async {
        final ok = await prov.eliminarCategoria(cat.id);
        if (!ok && context.mounted) {
          _mostrarError(context, prov.error ?? 'Error al eliminar');
        }
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  TAB PROVEEDORES
// ════════════════════════════════════════════════════════════════════════════
class _TabProveedores extends StatefulWidget {
  final ProveedorCatalogos prov;
  final VoidCallback onNuevo;
  const _TabProveedores({required this.prov, required this.onNuevo});

  @override
  State<_TabProveedores> createState() => _TabProveedoresState();
}

class _TabProveedoresState extends State<_TabProveedores> {
  final _ctrl = TextEditingController();
  String _q = '';
  bool _soloActivos = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() => _q = _ctrl.text));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<ProveedorModelo> lista =
        _soloActivos ? widget.prov.proveedoresActivos : widget.prov.proveedores;
    if (_q.isNotEmpty) {
      final q = _q.toLowerCase();
      lista = lista
          .where((p) =>
              p.nombre.toLowerCase().contains(q) ||
              p.contacto.toLowerCase().contains(q) ||
              p.telefono.contains(q))
          .toList();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: BarraBusqueda(controller: _ctrl, hint: 'Buscar proveedor…'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              const Text('Solo activos',
                  style: TextStyle(color: AppColors.textoMedio)),
              Switch(
                value: _soloActivos,
                activeColor: AppColors.primario,
                onChanged: (v) => setState(() => _soloActivos = v),
              ),
              const Spacer(),
              Text('${lista.length} proveedores',
                  style: const TextStyle(
                      color: AppColors.textoMedio, fontSize: 12)),
            ],
          ),
        ),
        Expanded(
          child: lista.isEmpty
              ? EstadoVacio(
                  mensaje: 'No hay proveedores registrados',
                  icono: Icons.local_shipping_rounded,
                  labelBoton: 'Agregar proveedor',
                  onBoton: widget.onNuevo,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                  itemCount: lista.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _TarjetaProveedor(
                    proveedor: lista[i],
                    prov: widget.prov,
                  ),
                ),
        ),
      ],
    );
  }
}

class _TarjetaProveedor extends StatelessWidget {
  final ProveedorModelo proveedor;
  final ProveedorCatalogos prov;
  const _TarjetaProveedor({required this.proveedor, required this.prov});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.fondoTarjeta,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.secundario.withOpacity(0.2),
          child: const Icon(Icons.local_shipping_rounded,
              color: AppColors.primario),
        ),
        title: Text(proveedor.nombre,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(proveedor.contacto,
            style: const TextStyle(fontSize: 12, color: AppColors.textoMedio)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ChipActivo(activo: proveedor.activo),
            _MenuAcciones(
              onEditar: () => _editar(context),
              onEliminar: () => _confirmarDesactivar(context),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                if (proveedor.telefono.isNotEmpty)
                  _FilaDetalle(Icons.phone_rounded, proveedor.telefono),
                if (proveedor.email.isNotEmpty)
                  _FilaDetalle(Icons.email_rounded, proveedor.email),
                if (proveedor.direccion.isNotEmpty)
                  _FilaDetalle(Icons.location_on_rounded, proveedor.direccion),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.fondo,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FormProveedor(proveedor: proveedor),
    );
  }

  void _confirmarDesactivar(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.fondo,
        title: const Text('Desactivar proveedor'),
        content: Text(
            '¿Desactivar a "${proveedor.nombre}"? Podrás reactivarlo después.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final ok = await prov.eliminarProveedor(proveedor.id);
              if (!ok && context.mounted) {
                _mostrarError(context, prov.error ?? 'Error al desactivar');
              }
            },
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  FORMULARIOS
// ════════════════════════════════════════════════════════════════════════════

// ── Formulario Especie ────────────────────────────────────────────────────
class _FormEspecie extends StatefulWidget {
  final EspecieModelo? especie;
  const _FormEspecie({this.especie});

  @override
  State<_FormEspecie> createState() => _FormEspecieState();
}

class _FormEspecieState extends State<_FormEspecie> {
  final _formKey = GlobalKey<FormState>();
  late final _nombre =
      TextEditingController(text: widget.especie?.nombre ?? '');
  late final _desc =
      TextEditingController(text: widget.especie?.descripcion ?? '');
  bool _activo = true;
  bool _guardando = false;

  bool get _esEdicion => widget.especie != null;

  @override
  void initState() {
    super.initState();
    _activo = widget.especie?.activo ?? true;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TituloForm(
                  titulo: _esEdicion ? 'Editar especie' : 'Nueva especie'),
              const SizedBox(height: 16),
              _Campo(
                ctrl: _nombre,
                label: 'Nombre *',
                icono: Icons.category_rounded,
                validar: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              _Campo(
                ctrl: _desc,
                label: 'Descripción',
                icono: Icons.notes_rounded,
                maxLineas: 2,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Activo'),
                value: _activo,
                activeColor: AppColors.primario,
                onChanged: (v) => setState(() => _activo = v),
              ),
              const SizedBox(height: 16),
              _BotonesForm(
                guardando: _guardando,
                onGuardar: _guardar,
                onCancelar: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    final prov = context.read<ProveedorCatalogos>();
    final modelo = EspecieModelo(
      id: widget.especie?.id ?? '',
      nombre: _nombre.text.trim(),
      descripcion: _desc.text.trim(),
      activo: _activo,
    );
    final ok = _esEdicion
        ? await prov.actualizarEspecie(modelo)
        : await prov.crearEspecie(modelo);
    if (!mounted) return;
    setState(() => _guardando = false);
    if (ok) {
      Navigator.of(context).pop();
    } else {
      _mostrarError(context, prov.error ?? 'Error al guardar');
    }
  }
}

// ── Formulario Raza ───────────────────────────────────────────────────────
class _FormRaza extends StatefulWidget {
  final RazaModelo? raza;
  const _FormRaza({this.raza});

  @override
  State<_FormRaza> createState() => _FormRazaState();
}

class _FormRazaState extends State<_FormRaza> {
  final _formKey = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.raza?.nombre ?? '');
  late final _desc =
      TextEditingController(text: widget.raza?.descripcion ?? '');
  String? _especieId;
  bool _activo = true;
  bool _guardando = false;

  bool get _esEdicion => widget.raza != null;

  @override
  void initState() {
    super.initState();
    _especieId = widget.raza?.especieId;
    _activo = widget.raza?.activo ?? true;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final especies = context.watch<ProveedorCatalogos>().especies;

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TituloForm(titulo: _esEdicion ? 'Editar raza' : 'Nueva raza'),
              const SizedBox(height: 16),
              // Dropdown Especie
              DropdownButtonFormField<String>(
                value: _especieId,
                decoration: const InputDecoration(
                  labelText: 'Especie *',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                items: especies
                    .map((e) =>
                        DropdownMenuItem(value: e.id, child: Text(e.nombre)))
                    .toList(),
                onChanged: (v) => setState(() => _especieId = v),
                validator: (v) => v == null ? 'Selecciona una especie' : null,
              ),
              const SizedBox(height: 12),
              _Campo(
                ctrl: _nombre,
                label: 'Nombre *',
                icono: Icons.pets_rounded,
                validar: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              _Campo(
                ctrl: _desc,
                label: 'Descripción',
                icono: Icons.notes_rounded,
                maxLineas: 2,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Activo'),
                value: _activo,
                activeColor: AppColors.primario,
                onChanged: (v) => setState(() => _activo = v),
              ),
              const SizedBox(height: 16),
              _BotonesForm(
                guardando: _guardando,
                onGuardar: _guardar,
                onCancelar: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    final prov = context.read<ProveedorCatalogos>();
    final modelo = RazaModelo(
      id: widget.raza?.id ?? '',
      nombre: _nombre.text.trim(),
      especieId: _especieId!,
      descripcion: _desc.text.trim(),
      activo: _activo,
    );
    final ok = _esEdicion
        ? await prov.actualizarRaza(modelo)
        : await prov.crearRaza(modelo);
    if (!mounted) return;
    setState(() => _guardando = false);
    if (ok) {
      Navigator.of(context).pop();
    } else {
      _mostrarError(context, prov.error ?? 'Error al guardar');
    }
  }
}

// ── Formulario Categoría ──────────────────────────────────────────────────
class _FormCategoria extends StatefulWidget {
  final CategoriaModelo? categoria;
  const _FormCategoria({this.categoria});

  @override
  State<_FormCategoria> createState() => _FormCategoriaState();
}

class _FormCategoriaState extends State<_FormCategoria> {
  final _formKey = GlobalKey<FormState>();
  late final _nombre =
      TextEditingController(text: widget.categoria?.nombre ?? '');
  late final _desc =
      TextEditingController(text: widget.categoria?.descripcion ?? '');
  bool _activo = true;
  bool _guardando = false;

  bool get _esEdicion => widget.categoria != null;

  @override
  void initState() {
    super.initState();
    _activo = widget.categoria?.activo ?? true;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TituloForm(
                  titulo: _esEdicion ? 'Editar categoría' : 'Nueva categoría'),
              const SizedBox(height: 16),
              _Campo(
                ctrl: _nombre,
                label: 'Nombre *',
                icono: Icons.label_rounded,
                validar: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              _Campo(
                ctrl: _desc,
                label: 'Descripción',
                icono: Icons.notes_rounded,
                maxLineas: 2,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Activo'),
                value: _activo,
                activeColor: AppColors.primario,
                onChanged: (v) => setState(() => _activo = v),
              ),
              const SizedBox(height: 16),
              _BotonesForm(
                guardando: _guardando,
                onGuardar: _guardar,
                onCancelar: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    final prov = context.read<ProveedorCatalogos>();
    final modelo = CategoriaModelo(
      id: widget.categoria?.id ?? '',
      nombre: _nombre.text.trim(),
      descripcion: _desc.text.trim(),
      activo: _activo,
    );
    final ok = _esEdicion
        ? await prov.actualizarCategoria(modelo)
        : await prov.crearCategoria(modelo);
    if (!mounted) return;
    setState(() => _guardando = false);
    if (ok) {
      Navigator.of(context).pop();
    } else {
      _mostrarError(context, prov.error ?? 'Error al guardar');
    }
  }
}

// ── Formulario Proveedor ──────────────────────────────────────────────────
class _FormProveedor extends StatefulWidget {
  final ProveedorModelo? proveedor;
  const _FormProveedor({this.proveedor});

  @override
  State<_FormProveedor> createState() => _FormProveedorState();
}

class _FormProveedorState extends State<_FormProveedor> {
  final _formKey = GlobalKey<FormState>();
  late final _nombre =
      TextEditingController(text: widget.proveedor?.nombre ?? '');
  late final _contacto =
      TextEditingController(text: widget.proveedor?.contacto ?? '');
  late final _telefono =
      TextEditingController(text: widget.proveedor?.telefono ?? '');
  late final _email =
      TextEditingController(text: widget.proveedor?.email ?? '');
  late final _direccion =
      TextEditingController(text: widget.proveedor?.direccion ?? '');
  bool _activo = true;
  bool _guardando = false;

  bool get _esEdicion => widget.proveedor != null;

  @override
  void initState() {
    super.initState();
    _activo = widget.proveedor?.activo ?? true;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _contacto.dispose();
    _telefono.dispose();
    _email.dispose();
    _direccion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TituloForm(
                  titulo: _esEdicion ? 'Editar proveedor' : 'Nuevo proveedor'),
              const SizedBox(height: 16),
              _Campo(
                ctrl: _nombre,
                label: 'Nombre empresa *',
                icono: Icons.business_rounded,
                validar: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              _Campo(
                ctrl: _contacto,
                label: 'Nombre de contacto',
                icono: Icons.person_rounded,
              ),
              const SizedBox(height: 12),
              _Campo(
                ctrl: _telefono,
                label: 'Teléfono',
                icono: Icons.phone_rounded,
                teclado: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _Campo(
                ctrl: _email,
                label: 'Email',
                icono: Icons.email_rounded,
                teclado: TextInputType.emailAddress,
                validar: (v) {
                  if (v != null && v.isNotEmpty && !v.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _Campo(
                ctrl: _direccion,
                label: 'Dirección',
                icono: Icons.location_on_rounded,
                maxLineas: 2,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Activo'),
                value: _activo,
                activeColor: AppColors.primario,
                onChanged: (v) => setState(() => _activo = v),
              ),
              const SizedBox(height: 16),
              _BotonesForm(
                guardando: _guardando,
                onGuardar: _guardar,
                onCancelar: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    final prov = context.read<ProveedorCatalogos>();
    final modelo = ProveedorModelo(
      id: widget.proveedor?.id ?? '',
      nombre: _nombre.text.trim(),
      contacto: _contacto.text.trim(),
      telefono: _telefono.text.trim(),
      email: _email.text.trim(),
      direccion: _direccion.text.trim(),
      activo: _activo,
    );
    final ok = _esEdicion
        ? await prov.actualizarProveedor(modelo)
        : await prov.crearProveedor(modelo);
    if (!mounted) return;
    setState(() => _guardando = false);
    if (ok) {
      Navigator.of(context).pop();
    } else {
      _mostrarError(context, prov.error ?? 'Error al guardar');
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  WIDGETS AUXILIARES LOCALES
// ════════════════════════════════════════════════════════════════════════════

class _TituloForm extends StatelessWidget {
  final String titulo;
  const _TituloForm({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(titulo,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _Campo extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icono;
  final int maxLineas;
  final TextInputType? teclado;
  final String? Function(String?)? validar;

  const _Campo({
    required this.ctrl,
    required this.label,
    required this.icono,
    this.maxLineas = 1,
    this.teclado,
    this.validar,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLineas,
      keyboardType: teclado,
      validator: validar,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono),
      ),
    );
  }
}

class _BotonesForm extends StatelessWidget {
  final bool guardando;
  final VoidCallback onGuardar;
  final VoidCallback onCancelar;

  const _BotonesForm({
    required this.guardando,
    required this.onGuardar,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: guardando ? null : onCancelar,
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: guardando ? null : onGuardar,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primario,
                foregroundColor: AppColors.blanco),
            child: guardando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.blanco))
                : const Text('Guardar'),
          ),
        ),
      ],
    );
  }
}

class _ChipActivo extends StatelessWidget {
  final bool activo;
  const _ChipActivo({required this.activo});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(activo ? 'Activo' : 'Inactivo',
          style: TextStyle(
              fontSize: 11,
              color: activo ? Colors.green.shade800 : Colors.red.shade800)),
      backgroundColor:
          activo ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.1),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ChipFiltro extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;

  const _ChipFiltro(
      {required this.label, required this.seleccionado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: seleccionado,
      selectedColor: AppColors.secundario.withOpacity(0.3),
      checkmarkColor: AppColors.primario,
      labelStyle: TextStyle(
        color: seleccionado ? AppColors.primario : AppColors.textoMedio,
        fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal,
      ),
      onSelected: (_) => onTap(),
    );
  }
}

class _FilaDetalle extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _FilaDetalle(this.icono, this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icono, size: 16, color: AppColors.textoMedio),
          const SizedBox(width: 8),
          Expanded(
              child: Text(texto,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textoOscuro))),
        ],
      ),
    );
  }
}

class _MenuAcciones extends StatelessWidget {
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _MenuAcciones({required this.onEditar, required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textoMedio),
      itemBuilder: (_) => [
        const PopupMenuItem(
            value: 'editar',
            child: Row(children: [
              Icon(Icons.edit_rounded, size: 18),
              SizedBox(width: 8),
              Text('Editar')
            ])),
        const PopupMenuItem(
            value: 'eliminar',
            child: Row(children: [
              Icon(Icons.delete_rounded, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Eliminar', style: TextStyle(color: Colors.red))
            ])),
      ],
      onSelected: (v) {
        if (v == 'editar') onEditar();
        if (v == 'eliminar') onEliminar();
      },
    );
  }
}

// ── Helpers globales ──────────────────────────────────────────────────────
void _confirmarBorrado({
  required BuildContext context,
  required String nombre,
  required VoidCallback onConfirmar,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.fondo,
      title: const Text('Confirmar eliminación'),
      content: Text('¿Eliminar "$nombre"? Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
          onPressed: () {
            Navigator.of(ctx).pop();
            onConfirmar();
          },
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
}

void _mostrarError(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: Colors.red.shade700,
  ));
}
