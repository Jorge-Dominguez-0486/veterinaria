// ═══════════════════════════════════════════════════════════════════════════
//  mascotas_screen.dart
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/modelos/mascota_modelo.dart';
import '../../providers/clientes_mascotas_provider.dart';
import '../../providers/catalogos_provider.dart';
import '../../widgets/widgets_comunes.dart';

class MascotasScreen extends StatefulWidget {
  const MascotasScreen({super.key});

  /// Llamado desde AdminShell → FAB "Agregar mascota"
  static void abrirFormulario(BuildContext context, {MascotaModelo? mascota}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.fondo,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FormMascota(mascota: mascota),
    );
  }

  @override
  State<MascotasScreen> createState() => _MascotasScreenState();
}

enum _FiltroMascota { todas, activas, inactivas }

class _MascotasScreenState extends State<MascotasScreen> {
  final _busqueda = TextEditingController();
  String _query = '';
  _FiltroMascota _filtro = _FiltroMascota.todas;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProveedorMascotas>().cargarMascotas();
      context.read<ProveedorCatalogos>().cargarTodo();
      context.read<ProveedorClientes>().cargarClientes();
    });
    _busqueda.addListener(() => setState(() => _query = _busqueda.text));
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  List<MascotaModelo> _aplicarFiltros(List<MascotaModelo> todas) {
    List<MascotaModelo> lista = switch (_filtro) {
      _FiltroMascota.activas => todas.where((m) => m.activo).toList(),
      _FiltroMascota.inactivas => todas.where((m) => !m.activo).toList(),
      _FiltroMascota.todas => todas,
    };
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      lista = lista.where((m) => m.nombre.toLowerCase().contains(q)).toList();
    }
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProveedorMascotas>();
    final lista = _aplicarFiltros(prov.mascotas);

    return Column(
      children: [
        // ── Búsqueda ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child:
              BarraBusqueda(controller: _busqueda, hint: 'Buscar mascota...'),
        ),
        // ── Chips de filtro ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _chip('Todas', _FiltroMascota.todas, prov.mascotas.length),
              const SizedBox(width: 8),
              _chip('Activas', _FiltroMascota.activas,
                  prov.mascotas.where((m) => m.activo).length),
              const SizedBox(width: 8),
              _chip('Inactivas', _FiltroMascota.inactivas,
                  prov.mascotas.where((m) => !m.activo).length),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // ── Lista ─────────────────────────────────────────────────────
        Expanded(
          child: prov.cargando
              ? const CargandoIndicador()
              : lista.isEmpty
                  ? EstadoVacio(
                      mensaje:
                          'No hay mascotas${_filtro != _FiltroMascota.todas ? ' con ese filtro' : ' registradas'}',
                      icono: Icons.pets_rounded,
                      labelBoton: _filtro == _FiltroMascota.todas
                          ? 'Agregar mascota'
                          : null,
                      onBoton: _filtro == _FiltroMascota.todas
                          ? () => MascotasScreen.abrirFormulario(context)
                          : null,
                    )
                  : RefreshIndicator(
                      color: AppColors.primario,
                      onRefresh: () => prov.cargarMascotas(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: lista.length,
                        itemBuilder: (_, i) => _MascotaTile(
                          mascota: lista[i],
                          onEditar: () => MascotasScreen.abrirFormulario(
                              context,
                              mascota: lista[i]),
                          onEliminar: () => _eliminar(context, lista[i]),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _chip(String label, _FiltroMascota valor, int count) {
    final sel = _filtro == valor;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: sel,
      onSelected: (_) => setState(() => _filtro = valor),
      selectedColor: AppColors.primario.withOpacity(0.15),
      checkmarkColor: AppColors.primario,
      labelStyle: TextStyle(
        color: sel ? AppColors.primario : AppColors.textoMedio,
        fontSize: 12,
        fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
      ),
      side: BorderSide(color: sel ? AppColors.primario : AppColors.borde),
      backgroundColor: AppColors.fondoTarjeta,
    );
  }

  Future<void> _eliminar(BuildContext ctx, MascotaModelo m) async {
    final ok = await confirmarEliminacion(ctx,
        titulo: 'Eliminar mascota',
        descripcion: '¿Deseas desactivar a ${m.nombre}?');
    if (ok == true && mounted) {
      final exito =
          await context.read<ProveedorMascotas>().eliminarMascota(m.id);
      if (mounted) {
        exito
            ? mostrarExito(context, 'Mascota desactivada')
            : mostrarError(
                context, context.read<ProveedorMascotas>().error ?? 'Error');
      }
    }
  }
}

// ── Tile mascota ──────────────────────────────────────────────────────────
class _MascotaTile extends StatelessWidget {
  final MascotaModelo mascota;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  const _MascotaTile(
      {required this.mascota,
      required this.onEditar,
      required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    final clientes = context.watch<ProveedorClientes>();
    final cliente = clientes.obtenerPorId(mascota.clienteId);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0x33DDA15E),
          child: Icon(Icons.pets_rounded, color: AppColors.primario, size: 22),
        ),
        title: Text(mascota.nombre,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(
          '${cliente?.nombreCompleto ?? 'Sin dueño'} · ${mascota.sexo} · ${mascota.edadAnios} años',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!mascota.activo)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: ChipEstado(estado: 'inactivo'),
              ),
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

// ── Formulario mascota ────────────────────────────────────────────────────
class _FormMascota extends StatefulWidget {
  final MascotaModelo? mascota;
  const _FormMascota({this.mascota});
  @override
  State<_FormMascota> createState() => _FormMascotaState();
}

class _FormMascotaState extends State<_FormMascota> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _peso;
  late final TextEditingController _color;
  late final TextEditingController _obs;
  String _sexo = 'macho';
  String? _clienteId;
  String? _especieId;
  String? _razaId;
  DateTime _fechaNac = DateTime.now().subtract(const Duration(days: 365));
  bool _guardando = false;

  bool get _esEdicion => widget.mascota != null;

  @override
  void initState() {
    super.initState();
    final m = widget.mascota;
    _nombre = TextEditingController(text: m?.nombre ?? '');
    _peso = TextEditingController(text: m?.peso.toString() ?? '');
    _color = TextEditingController(text: m?.color ?? '');
    _obs = TextEditingController(text: m?.observaciones ?? '');
    if (m != null) {
      _sexo = m.sexo;
      _clienteId = m.clienteId;
      _especieId = m.especieId;
      _razaId = m.razaId;
      _fechaNac = m.fechaNacimiento;
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _peso.dispose();
    _color.dispose();
    _obs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogos = context.watch<ProveedorCatalogos>();
    final clientes = context.watch<ProveedorClientes>();
    final razasFiltradas = _especieId != null
        ? catalogos.razasPorEspecie(_especieId!)
        : catalogos.razas;

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
              Row(
                children: [
                  Text(_esEdicion ? 'Editar mascota' : 'Nueva mascota',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre *'),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _clienteId,
                decoration: const InputDecoration(labelText: 'Dueño *'),
                items: clientes.clientesActivos
                    .map((c) => DropdownMenuItem(
                        value: c.id, child: Text(c.nombreCompleto)))
                    .toList(),
                onChanged: (v) => setState(() => _clienteId = v),
                validator: (v) => v == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _especieId,
                decoration: const InputDecoration(labelText: 'Especie'),
                items: catalogos.especies
                    .map((e) =>
                        DropdownMenuItem(value: e.id, child: Text(e.nombre)))
                    .toList(),
                onChanged: (v) => setState(() {
                  _especieId = v;
                  _razaId = null;
                }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _razaId,
                decoration: const InputDecoration(labelText: 'Raza'),
                items: razasFiltradas
                    .map((r) =>
                        DropdownMenuItem(value: r.id, child: Text(r.nombre)))
                    .toList(),
                onChanged: (v) => setState(() => _razaId = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _sexo,
                decoration: const InputDecoration(labelText: 'Sexo'),
                items: ['macho', 'hembra']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _sexo = v ?? 'macho'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _peso,
                      decoration: const InputDecoration(labelText: 'Peso (kg)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _color,
                      decoration: const InputDecoration(labelText: 'Color'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final fecha = await showDatePicker(
                    context: context,
                    initialDate: _fechaNac,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (fecha != null) setState(() => _fechaNac = fecha);
                },
                child: InputDecorator(
                  decoration:
                      const InputDecoration(labelText: 'Fecha de nacimiento'),
                  child: Text(
                      '${_fechaNac.day}/${_fechaNac.month}/${_fechaNac.year}'),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _obs,
                decoration: const InputDecoration(labelText: 'Observaciones'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  child: _guardando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(_esEdicion ? 'Guardar cambios' : 'Crear mascota'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);
    final prov = context.read<ProveedorMascotas>();
    bool exito;
    if (_esEdicion) {
      final actualizada = widget.mascota!.copyWith(
        nombre: _nombre.text.trim(),
        clienteId: _clienteId ?? '',
        especieId: _especieId ?? '',
        razaId: _razaId ?? '',
        sexo: _sexo,
        peso: double.tryParse(_peso.text) ?? 0,
        color: _color.text.trim(),
        observaciones: _obs.text.trim(),
        fechaNacimiento: _fechaNac,
      );
      exito = await prov.actualizarMascota(actualizada);
    } else {
      final nueva = MascotaModelo(
        id: '',
        nombre: _nombre.text.trim(),
        clienteId: _clienteId ?? '',
        especieId: _especieId ?? '',
        razaId: _razaId ?? '',
        sexo: _sexo,
        fechaNacimiento: _fechaNac,
        peso: double.tryParse(_peso.text) ?? 0,
        color: _color.text.trim(),
        observaciones: _obs.text.trim(),
        activo: true,
        fechaRegistro: DateTime.now(),
      );
      exito = await prov.crearMascota(nueva);
    }
    if (mounted) {
      Navigator.of(context).pop();
      exito
          ? mostrarExito(
              context, _esEdicion ? 'Mascota actualizada' : 'Mascota creada')
          : mostrarError(context, prov.error ?? 'Error al guardar');
    }
  }
}
