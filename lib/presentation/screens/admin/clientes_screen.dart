import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/modelos/cliente_modelo.dart';
import '../../providers/clientes_mascotas_provider.dart';
import '../../widgets/widgets_comunes.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final _busqueda = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProveedorClientes>().cargarClientes();
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
    final prov = context.watch<ProveedorClientes>();
    final lista = _query.isEmpty ? prov.clientes : prov.buscar(_query);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: BarraBusqueda(
            controller: _busqueda,
            hint: 'Buscar cliente...',
          ),
        ),
        Expanded(
          child: prov.cargando
              ? const CargandoIndicador()
              : lista.isEmpty
                  ? EstadoVacio(
                      mensaje: 'No hay clientes registrados',
                      icono: Icons.people_rounded,
                      labelBoton: 'Agregar cliente',
                      onBoton: () => _abrirFormulario(context),
                    )
                  : RefreshIndicator(
                      color: AppColors.primario,
                      onRefresh: () => prov.cargarClientes(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: lista.length,
                        itemBuilder: (_, i) => _ClienteTile(
                          cliente: lista[i],
                          onEditar: () =>
                              _abrirFormulario(context, cliente: lista[i]),
                          onEliminar: () => _eliminar(context, lista[i]),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }

  void _abrirFormulario(BuildContext context, {ClienteModelo? cliente}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.fondo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FormCliente(cliente: cliente),
    );
  }

  Future<void> _eliminar(BuildContext context, ClienteModelo cliente) async {
    final ok = await confirmarEliminacion(
      context,
      titulo: 'Eliminar cliente',
      descripcion:
          '¿Deseas desactivar a ${cliente.nombreCompleto}? Sus datos se conservarán.',
    );
    if (ok == true && mounted) {
      final exito =
          await context.read<ProveedorClientes>().eliminarCliente(cliente.id);
      if (mounted) {
        exito
            ? mostrarExito(context, 'Cliente desactivado')
            : mostrarError(
                context, context.read<ProveedorClientes>().error ?? 'Error');
      }
    }
  }
}

// ── FloatingActionButton externo ──────────────────────────────────────────
// Se agrega en el AdminShell; aquí sólo hay un FAB local que se puede ver
// si quieres activar el botón directamente en la screen.
// Descomenta si lo prefieres aquí:
// floatingActionButton: FloatingActionButton(...)

// ── Tile de cliente ───────────────────────────────────────────────────────
class _ClienteTile extends StatelessWidget {
  final ClienteModelo cliente;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _ClienteTile({
    required this.cliente,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.secundario.withOpacity(0.2),
          child: Text(
            '${cliente.nombre[0]}${cliente.apellido.isNotEmpty ? cliente.apellido[0] : ''}'
                .toUpperCase(),
            style: const TextStyle(
              color: AppColors.primario,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          cliente.nombreCompleto,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          cliente.email.isNotEmpty ? cliente.email : cliente.telefono,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!cliente.activo)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: ChipEstado(estado: 'inactivo'),
              ),
            IconButton(
              icon: const Icon(Icons.edit_rounded,
                  color: AppColors.primario, size: 20),
              onPressed: onEditar,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 20),
              onPressed: onEliminar,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Formulario de cliente ─────────────────────────────────────────────────
class _FormCliente extends StatefulWidget {
  final ClienteModelo? cliente;
  const _FormCliente({this.cliente});

  @override
  State<_FormCliente> createState() => _FormClienteState();
}

class _FormClienteState extends State<_FormCliente> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _apellido;
  late final TextEditingController _email;
  late final TextEditingController _telefono;
  late final TextEditingController _direccion;
  bool _guardando = false;

  bool get _esEdicion => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;
    _nombre = TextEditingController(text: c?.nombre ?? '');
    _apellido = TextEditingController(text: c?.apellido ?? '');
    _email = TextEditingController(text: c?.email ?? '');
    _telefono = TextEditingController(text: c?.telefono ?? '');
    _direccion = TextEditingController(text: c?.direccion ?? '');
  }

  @override
  void dispose() {
    _nombre.dispose();
    _apellido.dispose();
    _email.dispose();
    _telefono.dispose();
    _direccion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                Text(
                  _esEdicion ? 'Editar cliente' : 'Nuevo cliente',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nombre,
                    decoration: const InputDecoration(labelText: 'Nombre *'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _apellido,
                    decoration: const InputDecoration(labelText: 'Apellido *'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_rounded),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telefono,
              decoration: const InputDecoration(
                labelText: 'Teléfono *',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _direccion,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                prefixIcon: Icon(Icons.location_on_rounded),
              ),
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
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_esEdicion ? 'Guardar cambios' : 'Crear cliente'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);

    final prov = context.read<ProveedorClientes>();
    bool exito;

    if (_esEdicion) {
      final actualizado = widget.cliente!.copyWith(
        nombre: _nombre.text.trim(),
        apellido: _apellido.text.trim(),
        email: _email.text.trim(),
        telefono: _telefono.text.trim(),
        direccion: _direccion.text.trim(),
      );
      exito = await prov.actualizarCliente(actualizado);
    } else {
      final nuevo = ClienteModelo(
        id: '',
        nombre: _nombre.text.trim(),
        apellido: _apellido.text.trim(),
        email: _email.text.trim(),
        telefono: _telefono.text.trim(),
        direccion: _direccion.text.trim(),
        activo: true,
        fechaRegistro: DateTime.now(),
      );
      exito = await prov.crearCliente(nuevo);
    }

    if (mounted) {
      Navigator.of(context).pop();
      exito
          ? mostrarExito(
              context, _esEdicion ? 'Cliente actualizado' : 'Cliente creado')
          : mostrarError(context, prov.error ?? 'Error al guardar');
    }
  }
}
