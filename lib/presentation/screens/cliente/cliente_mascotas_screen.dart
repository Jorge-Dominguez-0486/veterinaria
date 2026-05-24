// ═══════════════════════════════════════════════════════════════════════════
//  cliente_mascotas_screen.dart  —  Mis mascotas (vista cliente)
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/modelos/mascota_modelo.dart';
import '../../../data/modelos/veterinaria_modelo.dart';
import '../../providers/auth_provider.dart';
import '../../providers/clientes_mascotas_provider.dart';
import '../../providers/veterinaria_provider.dart';
import '../../providers/catalogos_provider.dart';
import '../../widgets/widgets_comunes.dart';

class ClienteMascotasScreen extends StatefulWidget {
  const ClienteMascotasScreen({super.key});

  @override
  State<ClienteMascotasScreen> createState() => _ClienteMascotasScreenState();
}

class _ClienteMascotasScreenState extends State<ClienteMascotasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uid = context.read<ProveedorAuth>().usuario?.id ?? '';
      await context.read<ProveedorCatalogos>().cargarTodo();
      if (context.mounted) {
        context.read<ProveedorMascotas>().cargarMascotasPorCliente(uid);
      }
    });
  }

  void _abrirFormularioMascota(BuildContext context, String clienteId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.fondo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FormMascotaCliente(clienteId: clienteId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mascotas = context.watch<ProveedorMascotas>();
    final uid = context.read<ProveedorAuth>().usuario?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: Builder(
        builder: (context) {
          if (mascotas.cargando) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primario));
          }

          if (mascotas.mascotas.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets_rounded,
                      size: 72, color: AppColors.textoClaro),
                  SizedBox(height: 16),
                  Text('No tienes mascotas registradas',
                      style:
                          TextStyle(color: AppColors.textoMedio, fontSize: 16)),
                  SizedBox(height: 8),
                  Text(
                      'Toca el botón inferior para registrar\na tu primer compañero.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: AppColors.textoClaro, fontSize: 13)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mascotas.mascotas.length,
            itemBuilder: (_, i) =>
                _TarjetaMascota(mascota: mascotas.mascotas[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primario,
        foregroundColor: AppColors.blanco,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva Mascota'),
        onPressed: () => _abrirFormularioMascota(context, uid),
      ),
    );
  }
}

// ── Tarjeta expandible de mascota ─────────────────────────────────────────
class _TarjetaMascota extends StatelessWidget {
  final MascotaModelo mascota;
  const _TarjetaMascota({required this.mascota});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: AppColors.fondoTarjeta,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _verDetalle(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.secundario.withOpacity(0.2),
                child: const Icon(Icons.pets_rounded,
                    color: AppColors.primario, size: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mascota.nombre,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                        '${mascota.edadAnios} años · ${mascota.sexo} · ${mascota.peso} kg',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textoMedio)),
                    if (mascota.color.isNotEmpty)
                      Text('Color: ${mascota.color}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textoClaro)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textoClaro),
            ],
          ),
        ),
      ),
    );
  }

  void _verDetalle(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _DetalleMascotaScreen(mascota: mascota),
    ));
  }
}

// ── Detalle de mascota ────────────────────────────────────────────────────
class _DetalleMascotaScreen extends StatefulWidget {
  final MascotaModelo mascota;
  const _DetalleMascotaScreen({required this.mascota});

  @override
  State<_DetalleMascotaScreen> createState() => _DetalleMascotaScreenState();
}

class _DetalleMascotaScreenState extends State<_DetalleMascotaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ProveedorVeterinaria>()
          .cargarConsultasPorMascota(widget.mascota.id);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.mascota;

    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: AppColors.primario,
        foregroundColor: AppColors.blanco,
        title: Text(m.nombre),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.info_rounded), text: 'Info'),
            Tab(icon: Icon(Icons.history_rounded), text: 'Historial'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _TabInfoMascota(mascota: m),
          _TabHistorialMascota(mascotaId: m.id),
        ],
      ),
    );
  }
}

class _TabInfoMascota extends StatelessWidget {
  final MascotaModelo mascota;
  const _TabInfoMascota({required this.mascota});

  @override
  Widget build(BuildContext context) {
    final fmtFecha = DateFormat('dd/MM/yyyy');

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.secundario.withOpacity(0.2),
            child: const Icon(Icons.pets_rounded,
                color: AppColors.primario, size: 52),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(mascota.nombre,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 24),
        _FichaTarjeta(
          titulo: 'Información general',
          filas: [
            _FilaInfo('Sexo', mascota.sexo),
            _FilaInfo('Edad', '${mascota.edadAnios} años'),
            _FilaInfo('Peso', '${mascota.peso} kg'),
            _FilaInfo('Color', mascota.color),
            _FilaInfo('Nacimiento', fmtFecha.format(mascota.fechaNacimiento)),
            _FilaInfo('Registro', fmtFecha.format(mascota.fechaRegistro)),
          ],
        ),
        if (mascota.observaciones.isNotEmpty) ...[
          const SizedBox(height: 16),
          _FichaTarjeta(
            titulo: 'Observaciones',
            filas: [_FilaInfo('', mascota.observaciones)],
          ),
        ],
      ],
    );
  }
}

class _TabHistorialMascota extends StatelessWidget {
  final String mascotaId;
  const _TabHistorialMascota({required this.mascotaId});

  @override
  Widget build(BuildContext context) {
    final vet = context.watch<ProveedorVeterinaria>();
    final consultas = vet.consultas
        .where((c) => c.mascotaId == mascotaId)
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    if (vet.cargando) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primario));
    }

    if (consultas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 60, color: AppColors.textoClaro),
            SizedBox(height: 12),
            Text('Sin historial médico aún',
                style: TextStyle(color: AppColors.textoMedio)),
          ],
        ),
      );
    }

    final fmt = DateFormat('dd MMM yyyy', 'es_ES');

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: consultas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final c = consultas[i];
        return Card(
          color: AppColors.fondoTarjeta,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.secundario.withOpacity(0.2),
              child: const Icon(Icons.medical_services_rounded,
                  color: AppColors.primario, size: 20),
            ),
            title: Text(c.diagnostico,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text(fmt.format(c.fecha),
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textoMedio)),
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    if (c.sintomas.isNotEmpty)
                      _FilaHistorial('Síntomas', c.sintomas),
                    _FilaHistorial('Peso', '${c.peso} kg'),
                    _FilaHistorial('Temperatura', '${c.temperatura} °C'),
                    if (c.tratamiento.isNotEmpty)
                      _FilaHistorial('Tratamiento', c.tratamiento),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────────────────

class _FichaTarjeta extends StatelessWidget {
  final String titulo;
  final List<_FilaInfo> filas;
  const _FichaTarjeta({required this.titulo, required this.filas});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fondoTarjeta,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(titulo,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.primario)),
          ),
          const Divider(height: 1, color: AppColors.borde),
          ...filas.map((f) => _buildFila(f)),
        ],
      ),
    );
  }

  Widget _buildFila(_FilaInfo f) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: f.etiqueta.isEmpty
          ? Text(f.valor,
              style:
                  const TextStyle(color: AppColors.textoOscuro, fontSize: 14))
          : Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(f.etiqueta,
                      style: const TextStyle(
                          color: AppColors.textoMedio, fontSize: 13)),
                ),
                Expanded(
                  child: Text(f.valor,
                      style: const TextStyle(
                          color: AppColors.textoOscuro,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
    );
  }
}

class _FilaInfo {
  final String etiqueta;
  final String valor;
  const _FilaInfo(this.etiqueta, this.valor);
}

class _FilaHistorial extends StatelessWidget {
  final String label;
  final String valor;
  const _FilaHistorial(this.label, this.valor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style:
                    const TextStyle(color: AppColors.textoMedio, fontSize: 13)),
          ),
          Expanded(
            child: Text(valor,
                style: const TextStyle(
                    color: AppColors.textoOscuro,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ── Formulario de registro automático para el cliente ─────────────────────────
class _FormMascotaCliente extends StatefulWidget {
  final String clienteId;
  const _FormMascotaCliente({required this.clienteId});

  @override
  State<_FormMascotaCliente> createState() => _FormMascotaClienteState();
}

class _FormMascotaClienteState extends State<_FormMascotaCliente> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();

  String? _especieIdSeleccionada;
  String? _razaIdSeleccionada;
  String _sexoSeleccionado = 'macho';
  bool _guardando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _edadCtrl.dispose();
    _pesoCtrl.dispose();
    _colorCtrl.dispose();
    _notasCtrl.dispose();
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
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EncabezadoForm(
                titulo: 'Registrar mi mascota',
                onCerrar: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
              if (catalogos.cargando)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (catalogos.especies.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '⚠️ El catálogo está vacío. El Administrador debe registrar especies y razas primero.',
                    style: TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
              TextFormField(
                controller: _nombreCtrl,
                decoration:
                    const InputDecoration(labelText: 'Nombre de tu mascota *'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Escribe su nombre' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _especieIdSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Especie *',
                  hintText: 'Ej. Perro, Gato...',
                ),
                items: catalogos.especies
                    .map((e) =>
                        DropdownMenuItem(value: e.id, child: Text(e.nombre)))
                    .toList(),
                onChanged: catalogos.especies.isEmpty
                    ? null
                    : (v) {
                        setState(() {
                          _especieIdSeleccionada = v;
                          _razaIdSeleccionada = null;
                        });
                      },
                validator: (v) => v == null ? 'Selecciona una especie' : null,
              ),
              const SizedBox(height: 12),
              Builder(builder: (context) {
                final nombreEspecieSeleccionada = catalogos.especies
                    .where((e) => e.id == _especieIdSeleccionada)
                    .firstOrNull
                    ?.nombre;

                final razasFiltradas = catalogos.razas
                    .where((r) => r.especieId == _especieIdSeleccionada)
                    .toList();

                return DropdownButtonFormField<String>(
                  value: _razaIdSeleccionada,
                  decoration: InputDecoration(
                    labelText: 'Raza *',
                    hintText: _especieIdSeleccionada == null
                        ? 'Primero elige una especie'
                        : razasFiltradas.isEmpty
                            ? 'No hay razas para esta especie'
                            : 'Selecciona la raza',
                  ),
                  items: razasFiltradas
                      .map((r) =>
                          DropdownMenuItem(value: r.id, child: Text(r.nombre)))
                      .toList(),
                  onChanged:
                      (_especieIdSeleccionada == null || razasFiltradas.isEmpty)
                          ? null
                          : (v) => setState(() => _razaIdSeleccionada = v),
                  validator: (v) => v == null ? 'Selecciona una raza' : null,
                );
              }),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _sexoSeleccionado,
                decoration: const InputDecoration(labelText: 'Sexo *'),
                items: const [
                  DropdownMenuItem(value: 'macho', child: Text('Macho')),
                  DropdownMenuItem(value: 'hembra', child: Text('Hembra')),
                ],
                onChanged: (v) =>
                    setState(() => _sexoSeleccionado = v ?? 'macho'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _edadCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Edad (Años) *'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _pesoCtrl,
                      decoration: const InputDecoration(labelText: 'Peso (Kg)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _colorCtrl,
                decoration:
                    const InputDecoration(labelText: 'Color / Pelaje *'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Indica el color' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notasCtrl,
                decoration: const InputDecoration(
                    labelText: 'Notas médicas o cuidados especiales'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              BotonGuardar(
                guardando: _guardando,
                esEdicion: false,
                onGuardar:
                    catalogos.especies.isEmpty ? () {} : _procesarRegistro,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _procesarRegistro() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final provMascotas = context.read<ProveedorMascotas>();
    final edadAnios = int.tryParse(_edadCtrl.text) ?? 0;

    final nuevaMascota = MascotaModelo(
      id: '',
      nombre: _nombreCtrl.text.trim(),
      clienteId: widget.clienteId,
      especieId: _especieIdSeleccionada ?? '',
      razaId: _razaIdSeleccionada ?? '',
      sexo: _sexoSeleccionado,
      fechaNacimiento: DateTime.now().subtract(Duration(days: 365 * edadAnios)),
      peso: double.tryParse(_pesoCtrl.text) ?? 0.0,
      color: _colorCtrl.text.trim(),
      observaciones: _notasCtrl.text.trim(),
      activo: true,
      fechaRegistro: DateTime.now(),
    );

    final exito = await provMascotas.crearMascota(nuevaMascota);

    if (mounted) {
      Navigator.of(context).pop();
      if (exito) {
        mostrarExito(context, '¡Mascota registrada exitosamente!');
      } else {
        mostrarError(context, provMascotas.error ?? 'No se pudo guardar');
      }
    }
  }
}
