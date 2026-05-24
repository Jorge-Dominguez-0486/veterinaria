// ═══════════════════════════════════════════════════════════════════════════
//  cliente_citas_screen.dart  —  Mis citas (vista cliente)
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/modelos/veterinaria_modelo.dart';
import '../../../data/modelos/mascota_modelo.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalogos_provider.dart';
import '../../providers/clientes_mascotas_provider.dart';
import '../../providers/veterinaria_provider.dart';
import '../../widgets/widgets_comunes.dart';

class ClienteCitasScreen extends StatefulWidget {
  const ClienteCitasScreen({super.key});

  @override
  State<ClienteCitasScreen> createState() => _ClienteCitasScreenState();
}

class _ClienteCitasScreenState extends State<ClienteCitasScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<ProveedorAuth>().usuario?.id ?? '';
      context.read<ProveedorVeterinaria>().cargarCitasPorCliente(uid);
      context.read<ProveedorMascotas>().cargarMascotasPorCliente(uid);
      context
          .read<ProveedorCatalogos>()
          .cargarTodo(); // ← necesario para el form de nueva cita
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primario,
        foregroundColor: AppColors.blanco,
        icon: const Icon(Icons.event_available_rounded),
        label: const Text('Solicitar cita'),
        onPressed: () => _solicitarCita(context),
      ),
      body: Column(
        children: [
          Material(
            color: AppColors.fondoTarjeta,
            child: TabBar(
              controller: _tabs,
              labelColor: AppColors.primario,
              unselectedLabelColor: AppColors.textoMedio,
              indicatorColor: AppColors.primario,
              tabs: const [
                Tab(text: 'Próximas'),
                Tab(text: 'Historial'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _TabCitasProximas(),
                _TabCitasHistorial(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _solicitarCita(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.fondo,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _FormSolicitarCita(),
    );
  }
}

// ── Tab: Próximas citas ───────────────────────────────────────────────────
class _TabCitasProximas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vet = context.watch<ProveedorVeterinaria>();
    final mascotas = context.watch<ProveedorMascotas>();

    final proximas = vet.citasCliente
        .where((c) =>
            c.estado == 'programada' && c.fechaHora.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

    if (vet.cargando) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primario));
    }

    if (proximas.isEmpty) {
      return const EstadoVacio(
        mensaje: 'No tienes citas próximas.\nUsa el botón para solicitar una.',
        icono: Icons.event_available_rounded,
      );
    }

    return RefreshIndicator(
      color: AppColors.primario,
      onRefresh: () async {
        final uid = context.read<ProveedorAuth>().usuario?.id ?? '';
        await context.read<ProveedorVeterinaria>().cargarCitasPorCliente(uid);
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: proximas.length,
        itemBuilder: (_, i) => _TarjetaCita(
          cita: proximas[i],
          mascotas: mascotas.mascotas,
          mostrarCancelar: true,
        ),
      ),
    );
  }
}

// ── Tab: Historial ────────────────────────────────────────────────────────
class _TabCitasHistorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vet = context.watch<ProveedorVeterinaria>();
    final mascotas = context.watch<ProveedorMascotas>();

    final historial = vet.citasCliente
        .where((c) =>
            c.estado != 'programada' || c.fechaHora.isBefore(DateTime.now()))
        .toList()
      ..sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

    if (historial.isEmpty) {
      return const EstadoVacio(
        mensaje: 'No tienes citas anteriores.',
        icono: Icons.history_rounded,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: historial.length,
      itemBuilder: (_, i) => _TarjetaCita(
        cita: historial[i],
        mascotas: mascotas.mascotas,
        mostrarCancelar: false,
      ),
    );
  }
}

// ── Tarjeta de cita ───────────────────────────────────────────────────────
class _TarjetaCita extends StatelessWidget {
  final CitaModelo cita;
  final List<MascotaModelo> mascotas;
  final bool mostrarCancelar;

  const _TarjetaCita(
      {required this.cita,
      required this.mascotas,
      required this.mostrarCancelar});

  @override
  Widget build(BuildContext context) {
    final mascota = mascotas.where((m) => m.id == cita.mascotaId).firstOrNull;
    final fmt = DateFormat('EEEE d \'de\' MMMM · HH:mm', 'es_ES');

    final coloresEstado = {
      'programada': const Color(0xFF4A90D9),
      'completada': AppColors.exito,
      'cancelada': AppColors.error,
    };
    final colorEstado = coloresEstado[cita.estado] ?? AppColors.textoMedio;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.fondoTarjeta,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorEstado.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.event_rounded, color: colorEstado),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cita.motivo,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      Text(fmt.format(cita.fechaHora),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textoMedio)),
                    ],
                  ),
                ),
                _ChipEstado(estado: cita.estado, color: colorEstado),
              ],
            ),
            if (mascota != null) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.borde),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.pets_rounded,
                      size: 16, color: AppColors.textoMedio),
                  const SizedBox(width: 6),
                  Text(mascota.nombre,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textoOscuro)),
                ],
              ),
            ],
            if (cita.notas.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded,
                      size: 16, color: AppColors.textoMedio),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(cita.notas,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textoMedio)),
                  ),
                ],
              ),
            ],
            // Botón cancelar
            if (mostrarCancelar && cita.estado == 'programada') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel_rounded,
                      size: 16, color: AppColors.error),
                  label: const Text('Cancelar cita',
                      style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error)),
                  onPressed: () => _confirmarCancelar(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmarCancelar(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.fondo,
        title: const Text('Cancelar cita'),
        content: const Text(
            '¿Seguro que deseas cancelar esta cita? No podrás deshacerlo.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('No, mantener')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final ok = await context
                  .read<ProveedorVeterinaria>()
                  .cancelarCita(cita.id, clienteId: cita.clienteId);
              if (context.mounted) {
                ok
                    ? mostrarExito(context, 'Cita cancelada')
                    : mostrarError(context, 'Error al cancelar');
              }
            },
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }
}

class _ChipEstado extends StatelessWidget {
  final String estado;
  final Color color;
  const _ChipEstado({required this.estado, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(estado,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

// ── Formulario: Solicitar cita ────────────────────────────────────────────
class _FormSolicitarCita extends StatefulWidget {
  const _FormSolicitarCita();

  @override
  State<_FormSolicitarCita> createState() => _FormSolicitarCitaState();
}

class _FormSolicitarCitaState extends State<_FormSolicitarCita> {
  final _formKey = GlobalKey<FormState>();
  final _motivo = TextEditingController();
  final _notas = TextEditingController();
  String? _mascotaId;
  DateTime? _fecha;
  bool _guardando = false;

  @override
  void dispose() {
    _motivo.dispose();
    _notas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mascotas = context.watch<ProveedorMascotas>().mascotas;
    final fmtFecha =
        _fecha != null ? DateFormat('dd/MM/yyyy HH:mm').format(_fecha!) : null;

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
              Row(
                children: [
                  const Text('Solicitar cita',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Mascota
              DropdownButtonFormField<String>(
                value: _mascotaId,
                decoration: const InputDecoration(
                  labelText: 'Mascota *',
                  prefixIcon: Icon(Icons.pets_rounded),
                ),
                items: mascotas
                    .map((m) =>
                        DropdownMenuItem(value: m.id, child: Text(m.nombre)))
                    .toList(),
                onChanged: (v) => setState(() => _mascotaId = v),
                validator: (v) => v == null ? 'Selecciona una mascota' : null,
              ),
              const SizedBox(height: 12),

              // Motivo
              TextFormField(
                controller: _motivo,
                decoration: const InputDecoration(
                  labelText: 'Motivo de la consulta *',
                  prefixIcon: Icon(Icons.medical_services_rounded),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),

              // Fecha y hora
              InkWell(
                onTap: _seleccionarFecha,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha y hora deseada *',
                    prefixIcon: Icon(Icons.calendar_month_rounded),
                  ),
                  child: Text(
                    fmtFecha ?? 'Seleccionar fecha...',
                    style: TextStyle(
                        color: _fecha != null
                            ? AppColors.textoOscuro
                            : AppColors.textoClaro),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Notas
              TextFormField(
                controller: _notas,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notas adicionales',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _guardando ? null : _enviar,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primario,
                    foregroundColor: AppColors.blanco,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Enviar solicitud'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('es', 'ES'),
    );
    if (fecha == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (hora == null || !mounted) return;

    setState(() {
      _fecha =
          DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
    });
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fecha == null) {
      mostrarError(context, 'Selecciona una fecha y hora');
      return;
    }

    setState(() => _guardando = true);

    final auth = context.read<ProveedorAuth>();
    final uid = auth.usuario?.id ?? '';

    final nuevaCita = CitaModelo(
      id: '',
      mascotaId: _mascotaId!,
      clienteId: uid,
      empleadoId: '',
      fechaHora: _fecha!,
      motivo: _motivo.text.trim(),
      estado: 'programada',
      notas: _notas.text.trim(),
    );

    final ok = await context.read<ProveedorVeterinaria>().crearCita(nuevaCita);

    if (!mounted) return;
    setState(() => _guardando = false);

    if (ok) {
      Navigator.of(context).pop();
      mostrarExito(
          context, 'Solicitud enviada. Te confirmaremos la cita pronto.');
    } else {
      mostrarError(context, 'Error al enviar la solicitud');
    }
  }
}
