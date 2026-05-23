// ═══════════════════════════════════════════════════════════════════════════
//  rrhh_screen.dart
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/modelos/rrhh_modelo.dart';
import '../../providers/rrhh_provider.dart';
import 'widgets/widgets_comunes.dart';

class RrhhScreen extends StatefulWidget {
  const RrhhScreen({super.key});

  static void abrirFormulario(BuildContext context,
      {EmpleadoModelo? empleado}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.fondo,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FormEmpleado(empleado: empleado),
    );
  }

  @override
  State<RrhhScreen> createState() => _RrhhScreenState();
}

class _RrhhScreenState extends State<RrhhScreen> {
  final _busqueda = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProveedorRRHH>().cargarTodo();
    });
    _busqueda.addListener(() => setState(() => _query = _busqueda.text));
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProveedorRRHH>();
    final lista = _query.isEmpty
        ? prov.empleados
        : prov.empleados
            .where((e) => '${e.nombre} ${e.apellido}'
                .toLowerCase()
                .contains(_query.toLowerCase()))
            .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child:
              BarraBusqueda(controller: _busqueda, hint: 'Buscar empleado...'),
        ),
        Expanded(
          child: prov.cargando
              ? const CargandoIndicador()
              : lista.isEmpty
                  ? EstadoVacio(
                      mensaje: 'No hay empleados registrados',
                      icono: Icons.badge_rounded,
                      labelBoton: 'Nuevo empleado',
                      onBoton: () => RrhhScreen.abrirFormulario(context),
                    )
                  : RefreshIndicator(
                      color: AppColors.primario,
                      onRefresh: () => prov.cargarTodo(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: lista.length,
                        itemBuilder: (_, i) => _EmpleadoTile(
                          empleado: lista[i],
                          onEditar: () => RrhhScreen.abrirFormulario(context,
                              empleado: lista[i]),
                          onEliminar: () => _eliminar(context, lista[i]),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }

  Future<void> _eliminar(BuildContext context, EmpleadoModelo e) async {
    final ok = await confirmarEliminacion(context,
        titulo: 'Desactivar empleado',
        descripcion: '¿Deseas desactivar a ${e.nombre} ${e.apellido}?');
    if (ok == true && mounted) {
      final exito = await context.read<ProveedorRRHH>().eliminarEmpleado(e.id);
      if (mounted) {
        exito
            ? mostrarExito(context, 'Empleado desactivado')
            : mostrarError(context, 'Error');
      }
    }
  }
}

class _EmpleadoTile extends StatelessWidget {
  final EmpleadoModelo empleado;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  const _EmpleadoTile(
      {required this.empleado,
      required this.onEditar,
      required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.secundario.withOpacity(0.2),
          child: Text(
            '${empleado.nombre[0]}${empleado.apellido.isNotEmpty ? empleado.apellido[0] : ''}'
                .toUpperCase(),
            style: const TextStyle(
                color: AppColors.primario, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text('${empleado.nombre} ${empleado.apellido}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(
          '${empleado.puesto} · \$${empleado.salario.toStringAsFixed(0)}/mes',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!empleado.activo) const ChipEstado(estado: 'inactivo'),
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

// ── Formulario empleado ───────────────────────────────────────────────────
class _FormEmpleado extends StatefulWidget {
  final EmpleadoModelo? empleado;
  const _FormEmpleado({this.empleado});
  @override
  State<_FormEmpleado> createState() => _FormEmpleadoState();
}

class _FormEmpleadoState extends State<_FormEmpleado> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _apellido;
  late final TextEditingController _email;
  late final TextEditingController _telefono;
  late final TextEditingController _especialidad;
  late final TextEditingController _salario;
  late final TextEditingController _horario;
  String _puesto = 'veterinario';
  bool _guardando = false;

  bool get _esEdicion => widget.empleado != null;

  static const _puestos = [
    'veterinario',
    'recepcionista',
    'gerente',
    'auxiliar'
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.empleado;
    _nombre = TextEditingController(text: e?.nombre ?? '');
    _apellido = TextEditingController(text: e?.apellido ?? '');
    _email = TextEditingController(text: e?.email ?? '');
    _telefono = TextEditingController(text: e?.telefono ?? '');
    _especialidad = TextEditingController(text: e?.especialidad ?? '');
    _salario = TextEditingController(text: e?.salario.toString() ?? '');
    _horario = TextEditingController(text: e?.horario ?? '');
    _puesto = e?.puesto ?? 'veterinario';
  }

  @override
  void dispose() {
    for (final c in [
      _nombre,
      _apellido,
      _email,
      _telefono,
      _especialidad,
      _salario,
      _horario
    ]) c.dispose();
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EncabezadoForm(
                  titulo: _esEdicion ? 'Editar empleado' : 'Nuevo empleado',
                  onCerrar: () => Navigator.of(context).pop()),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    controller: _nombre,
                    decoration: const InputDecoration(labelText: 'Nombre *'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  )),
                  const SizedBox(width: 12),
                  Expanded(
                      child: TextFormField(
                    controller: _apellido,
                    decoration: const InputDecoration(labelText: 'Apellido *'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  )),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _puesto,
                decoration: const InputDecoration(labelText: 'Puesto'),
                items: _puestos
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _puesto = v ?? 'veterinario'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _especialidad,
                decoration: const InputDecoration(labelText: 'Especialidad'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(
                    labelText: 'Email', prefixIcon: Icon(Icons.email_rounded)),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    controller: _telefono,
                    decoration: const InputDecoration(
                        labelText: 'Teléfono *',
                        prefixIcon: Icon(Icons.phone_rounded)),
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  )),
                  const SizedBox(width: 12),
                  Expanded(
                      child: TextFormField(
                    controller: _salario,
                    decoration: const InputDecoration(
                        labelText: 'Salario mensual', prefixText: '\$'),
                    keyboardType: TextInputType.number,
                  )),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _horario,
                decoration: const InputDecoration(
                    labelText: 'Horario (ej: Lun-Vie 9-18)'),
              ),
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
    final prov = context.read<ProveedorRRHH>();
    bool exito;
    if (_esEdicion) {
      exito = await prov.actualizarEmpleado(widget.empleado!.copyWith(
        nombre: _nombre.text.trim(),
        apellido: _apellido.text.trim(),
        email: _email.text.trim(),
        telefono: _telefono.text.trim(),
        puesto: _puesto,
        especialidad: _especialidad.text.trim(),
        salario: double.tryParse(_salario.text) ?? 0,
        horario: _horario.text.trim(),
      ));
    } else {
      exito = await prov.crearEmpleado(EmpleadoModelo(
        id: '',
        nombre: _nombre.text.trim(),
        apellido: _apellido.text.trim(),
        email: _email.text.trim(),
        telefono: _telefono.text.trim(),
        puesto: _puesto,
        especialidad: _especialidad.text.trim(),
        salario: double.tryParse(_salario.text) ?? 0,
        horario: _horario.text.trim(),
        activo: true,
        fechaContratacion: DateTime.now(),
      ));
    }
    if (mounted) {
      Navigator.of(context).pop();
      exito
          ? mostrarExito(
              context, _esEdicion ? 'Empleado actualizado' : 'Empleado creado')
          : mostrarError(context, prov.error ?? 'Error');
    }
  }
}
