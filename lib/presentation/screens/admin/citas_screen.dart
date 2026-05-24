// ═══════════════════════════════════════════════════════════════════════════
//  citas_screen.dart
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/modelos/veterinaria_modelo.dart';
import '../../providers/veterinaria_provider.dart';
import '../../providers/clientes_mascotas_provider.dart';
import '../../providers/rrhh_provider.dart';
import '../../widgets/widgets_comunes.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  static void abrirFormulario(BuildContext context, {CitaModelo? cita}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.fondo,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FormCita(cita: cita),
    );
  }

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _busqueda = TextEditingController();
  String _query = '';
  // null = todos los estados; solo aplica al tab "Todas"
  String? _filtroEstado;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProveedorVeterinaria>().cargarTodo();
      context.read<ProveedorMascotas>().cargarMascotas();
      context.read<ProveedorClientes>().cargarClientes();
      context.read<ProveedorRRHH>().cargarTodo();
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
    final prov = context.watch<ProveedorVeterinaria>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: BarraBusqueda(controller: _busqueda, hint: 'Buscar cita...'),
        ),
        // Chips de estado (visibles solo cuando el tab "Todas" está activo)
        AnimatedBuilder(
          animation: _tabs,
          builder: (_, __) => _tabs.index == 2
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child: SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _ChipEstadoCita(
                            label: 'Todas',
                            valor: null,
                            actual: _filtroEstado,
                            onTap: () => setState(() => _filtroEstado = null)),
                        const SizedBox(width: 8),
                        _ChipEstadoCita(
                            label: 'Programadas',
                            valor: 'programada',
                            actual: _filtroEstado,
                            onTap: () =>
                                setState(() => _filtroEstado = 'programada')),
                        const SizedBox(width: 8),
                        _ChipEstadoCita(
                            label: 'Completadas',
                            valor: 'completada',
                            actual: _filtroEstado,
                            onTap: () =>
                                setState(() => _filtroEstado = 'completada')),
                        const SizedBox(width: 8),
                        _ChipEstadoCita(
                            label: 'Canceladas',
                            valor: 'cancelada',
                            actual: _filtroEstado,
                            onTap: () =>
                                setState(() => _filtroEstado = 'cancelada')),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        TabBar(
          controller: _tabs,
          labelColor: AppColors.primario,
          unselectedLabelColor: AppColors.textoMedio,
          indicatorColor: AppColors.primario,
          tabs: const [
            Tab(text: 'Programadas'),
            Tab(text: 'Hoy'),
            Tab(text: 'Todas'),
          ],
        ),
        Expanded(
          child: prov.cargando
              ? const CargandoIndicador()
              : TabBarView(
                  controller: _tabs,
                  children: [
                    _ListaCitas(citas: prov.citasProgramadas, query: _query),
                    _ListaCitas(citas: prov.citasHoy, query: _query),
                    _ListaCitas(
                      citas: prov.citas,
                      query: _query,
                      filtroEstado: _filtroEstado,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ListaCitas extends StatelessWidget {
  final List<CitaModelo> citas;
  final String query;
  final String? filtroEstado;
  const _ListaCitas(
      {required this.citas, required this.query, this.filtroEstado});

  @override
  Widget build(BuildContext context) {
    List<CitaModelo> filtradas = citas;
    if (filtroEstado != null) {
      filtradas = filtradas.where((c) => c.estado == filtroEstado).toList();
    }
    if (query.isNotEmpty) {
      filtradas = filtradas
          .where((c) => c.motivo.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    if (filtradas.isEmpty) {
      return EstadoVacio(
        mensaje: 'No hay citas',
        icono: Icons.calendar_month_rounded,
        labelBoton: 'Nueva cita',
        onBoton: () => CitasScreen.abrirFormulario(context),
      );
    }

    return RefreshIndicator(
      color: AppColors.primario,
      onRefresh: () => context.read<ProveedorVeterinaria>().cargarTodo(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtradas.length,
        itemBuilder: (_, i) => _CitaTile(
          cita: filtradas[i],
          onEditar: () =>
              CitasScreen.abrirFormulario(context, cita: filtradas[i]),
          onEliminar: () => _eliminar(context, filtradas[i]),
        ),
      ),
    );
  }

  Future<void> _eliminar(BuildContext context, CitaModelo c) async {
    final ok = await confirmarEliminacion(context,
        titulo: 'Cancelar cita', descripcion: '¿Deseas eliminar esta cita?');
    if (ok == true) {
      final exito =
          await context.read<ProveedorVeterinaria>().eliminarCita(c.id);
      if (context.mounted) {
        exito
            ? mostrarExito(context, 'Cita eliminada')
            : mostrarError(context, 'Error al eliminar');
      }
    }
  }
}

// ── Chip de filtro de estado para citas ──────────────────────────────────
class _ChipEstadoCita extends StatelessWidget {
  final String label;
  final String? valor;
  final String? actual;
  final VoidCallback onTap;
  const _ChipEstadoCita(
      {required this.label,
      required this.valor,
      required this.actual,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sel = actual == valor;
    return FilterChip(
      label: Text(label),
      selected: sel,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.informacion.withOpacity(0.15),
      checkmarkColor: AppColors.informacion,
      labelStyle: TextStyle(
        fontSize: 12,
        color: sel ? AppColors.informacion : AppColors.textoMedio,
        fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
      ),
      side: BorderSide(color: sel ? AppColors.informacion : AppColors.borde),
      backgroundColor: AppColors.fondoTarjeta,
    );
  }
}

class _CitaTile extends StatelessWidget {
  final CitaModelo cita;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  const _CitaTile(
      {required this.cita, required this.onEditar, required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    final mascotas = context.watch<ProveedorMascotas>();
    final clientes = context.watch<ProveedorClientes>();
    final mascota =
        mascotas.mascotas.where((m) => m.id == cita.mascotaId).firstOrNull;
    final cliente =
        mascota != null ? clientes.obtenerPorId(mascota.clienteId) : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0x331976D2),
          child: Icon(Icons.calendar_month_rounded,
              color: AppColors.informacion, size: 22),
        ),
        title: Text(
          '${mascota?.nombre ?? cita.mascotaId} · ${cita.motivo}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          '${cliente?.nombreCompleto ?? ''} · ${_formatFecha(cita.fechaHora)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChipEstado(estado: cita.estado),
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

  String _formatFecha(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ── Formulario cita ───────────────────────────────────────────────────────
class _FormCita extends StatefulWidget {
  final CitaModelo? cita;
  const _FormCita({this.cita});

  @override
  State<_FormCita> createState() => _FormCitaState();
}

class _FormCitaState extends State<_FormCita> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _motivo;
  late final TextEditingController _notas;
  String? _mascotaId;
  String? _clienteId;
  String? _empleadoId;
  String _estado = 'programada';
  DateTime _fechaHora = DateTime.now().add(const Duration(hours: 1));
  bool _guardando = false;

  bool get _esEdicion => widget.cita != null;

  @override
  void initState() {
    super.initState();
    final c = widget.cita;
    _motivo = TextEditingController(text: c?.motivo ?? '');
    _notas = TextEditingController(text: c?.notas ?? '');
    if (c != null) {
      _mascotaId = c.mascotaId;
      _clienteId = c.clienteId;
      _empleadoId = c.empleadoId;
      _estado = c.estado;
      _fechaHora = c.fechaHora;
    }
  }

  @override
  void dispose() {
    _motivo.dispose();
    _notas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mascotas = context.watch<ProveedorMascotas>();
    final clientes = context.watch<ProveedorClientes>();
    final rrhh = context.watch<ProveedorRRHH>();
    final vets = rrhh.empleados
        .where((e) => e.puesto == 'veterinario' && e.activo)
        .toList();

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
                titulo: _esEdicion ? 'Editar cita' : 'Nueva cita',
                onCerrar: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
              // Mascota
              DropdownButtonFormField<String>(
                value: _mascotaId,
                decoration: const InputDecoration(labelText: 'Mascota *'),
                items: mascotas.mascotas
                    .map((m) =>
                        DropdownMenuItem(value: m.id, child: Text(m.nombre)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _mascotaId = v;
                    final m =
                        mascotas.mascotas.where((x) => x.id == v).firstOrNull;
                    _clienteId = m?.clienteId;
                  });
                },
                validator: (v) => v == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              // Veterinario
              DropdownButtonFormField<String>(
                value: _empleadoId,
                decoration: const InputDecoration(labelText: 'Veterinario *'),
                items: vets.isEmpty
                    ? [
                        const DropdownMenuItem(
                            value: 'sin_vet',
                            child: Text('Sin veterinarios registrados'))
                      ]
                    : vets
                        .map((e) => DropdownMenuItem(
                            value: e.id,
                            child: Text('${e.nombre} ${e.apellido}')))
                        .toList(),
                onChanged: (v) => setState(() => _empleadoId = v),
                validator: (v) => v == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _motivo,
                decoration: const InputDecoration(labelText: 'Motivo *'),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _estado,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: ['programada', 'completada', 'cancelada']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _estado = v ?? 'programada'),
              ),
              const SizedBox(height: 12),
              // Fecha y hora
              InkWell(
                onTap: _seleccionarFechaHora,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha y hora *',
                    prefixIcon: Icon(Icons.access_time_rounded),
                  ),
                  child: Text(_formatFecha(_fechaHora)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notas,
                decoration: const InputDecoration(labelText: 'Notas'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              BotonGuardar(
                  guardando: _guardando,
                  esEdicion: _esEdicion,
                  onGuardar: _guardar),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFecha(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Future<void> _seleccionarFechaHora() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaHora,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha == null || !mounted) return;
    final hora = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(_fechaHora));
    if (hora == null) return;
    setState(() => _fechaHora =
        DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute));
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);
    final prov = context.read<ProveedorVeterinaria>();
    bool exito;
    if (_esEdicion) {
      exito = await prov.actualizarCita(widget.cita!.copyWith(
        mascotaId: _mascotaId,
        clienteId: _clienteId ?? '',
        empleadoId: _empleadoId ?? '',
        motivo: _motivo.text.trim(),
        estado: _estado,
        fechaHora: _fechaHora,
        notas: _notas.text.trim(),
      ));
    } else {
      exito = await prov.crearCita(CitaModelo(
        id: '',
        mascotaId: _mascotaId ?? '',
        clienteId: _clienteId ?? '',
        empleadoId: _empleadoId ?? '',
        fechaHora: _fechaHora,
        motivo: _motivo.text.trim(),
        estado: _estado,
        notas: _notas.text.trim(),
      ));
    }
    if (mounted) {
      Navigator.of(context).pop();
      exito
          ? mostrarExito(
              context, _esEdicion ? 'Cita actualizada' : 'Cita creada')
          : mostrarError(context, prov.error ?? 'Error');
    }
  }
}
