// ═══════════════════════════════════════════════════════════════════════════
//  cliente_perfil_screen.dart  —  Mi perfil (vista cliente)
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class ClientePerfilScreen extends StatelessWidget {
  const ClientePerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<ProveedorAuth>().usuario;

    if (usuario == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primario));
    }

    final fmt = DateFormat('dd/MM/yyyy', 'es_ES');

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Avatar + nombre ────────────────────────────────────────────
        Center(
          child: CircleAvatar(
            radius: 46,
            backgroundColor: AppColors.secundario.withOpacity(0.25),
            child: Text(
              usuario.nombre.isNotEmpty ? usuario.nombre[0].toUpperCase() : '?',
              style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primario),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            usuario.nombreCompleto,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textoOscuro),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primario.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              usuario.rolTexto,
              style: const TextStyle(
                  color: AppColors.primario,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // ── Ficha de datos ─────────────────────────────────────────────
        _SeccionInfo(
          titulo: 'Información personal',
          filas: [
            _FilaDato(
              icono: Icons.person_rounded,
              etiqueta: 'Nombre',
              valor: usuario.nombreCompleto,
            ),
            _FilaDato(
              icono: Icons.email_rounded,
              etiqueta: 'Correo',
              valor: usuario.email,
            ),
            _FilaDato(
              icono: Icons.phone_rounded,
              etiqueta: 'Teléfono',
              valor: usuario.telefono.isNotEmpty
                  ? usuario.telefono
                  : 'No registrado',
            ),
            _FilaDato(
              icono: Icons.calendar_today_rounded,
              etiqueta: 'Miembro desde',
              valor: fmt.format(usuario.fechaCreacion),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Cambiar contraseña ─────────────────────────────────────────
        _SeccionInfo(
          titulo: 'Seguridad',
          filas: const [],
          extra: _BotonCambiarPassword(),
        ),

        const SizedBox(height: 28),

        // ── Cerrar sesión ──────────────────────────────────────────────
        OutlinedButton.icon(
          icon: const Icon(Icons.logout_rounded, color: AppColors.error),
          label: const Text('Cerrar sesión',
              style: TextStyle(color: AppColors.error)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.error),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () => _confirmarSalida(context),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  void _confirmarSalida(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.fondo,
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas salir de tu cuenta?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<ProveedorAuth>().cerrarSesion();
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}

// ── Sección agrupada ──────────────────────────────────────────────────────
class _SeccionInfo extends StatelessWidget {
  final String titulo;
  final List<_FilaDato> filas;
  final Widget? extra;

  const _SeccionInfo({
    required this.titulo,
    required this.filas,
    this.extra,
  });

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
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(titulo,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primario)),
          ),
          const Divider(height: 1, color: AppColors.borde),
          ...filas.map((f) => _buildFila(f)),
          if (extra != null)
            Padding(
              padding: const EdgeInsets.all(14),
              child: extra!,
            ),
        ],
      ),
    );
  }

  Widget _buildFila(_FilaDato f) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(f.icono, size: 18, color: AppColors.primario),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(f.etiqueta,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.textoMedio)),
          ),
          Expanded(
            child: Text(f.valor,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textoOscuro,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _FilaDato {
  final IconData icono;
  final String etiqueta;
  final String valor;
  const _FilaDato(
      {required this.icono, required this.etiqueta, required this.valor});
}

// ── Botón cambiar contraseña ──────────────────────────────────────────────
class _BotonCambiarPassword extends StatelessWidget {
  const _BotonCambiarPassword();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.lock_outline_rounded, color: AppColors.primario),
        label: const Text('Cambiar contraseña',
            style: TextStyle(color: AppColors.primario)),
        style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primario),
            padding: const EdgeInsets.symmetric(vertical: 12)),
        onPressed: () => _mostrarFormPassword(context),
      ),
    );
  }

  void _mostrarFormPassword(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.fondo,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _FormCambiarPassword(),
    );
  }
}

class _FormCambiarPassword extends StatefulWidget {
  const _FormCambiarPassword();

  @override
  State<_FormCambiarPassword> createState() => _FormCambiarPasswordState();
}

class _FormCambiarPasswordState extends State<_FormCambiarPassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _enviando = false;
  bool _enviado = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current user's email
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final email = context.read<ProveedorAuth>().usuario?.email ?? '';
      _emailCtrl.text = email;
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('Cambiar contraseña',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          const SizedBox(height: 12),
          if (_enviado) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.exito.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.exito),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.exito),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Revisa tu correo. Te enviamos un enlace para restablecer tu contraseña.',
                      style: TextStyle(color: AppColors.exito, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primario,
                  foregroundColor: AppColors.blanco),
              child: const Text('Listo'),
            ),
          ] else ...[
            const Text(
              'Te enviaremos un enlace a tu correo para restablecer tu contraseña.',
              style: TextStyle(fontSize: 13, color: AppColors.textoMedio),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email_rounded),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _enviando ? null : _enviarEnlace,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primario,
                  foregroundColor: AppColors.blanco,
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              child: _enviando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Enviar enlace'),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _enviarEnlace() async {
    setState(() => _enviando = true);
    final ok = await context
        .read<ProveedorAuth>()
        .recuperarContrasena(_emailCtrl.text.trim());
    setState(() {
      _enviando = false;
      _enviado = ok;
    });
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error al enviar el correo'),
            backgroundColor: AppColors.error),
      );
    }
  }
}
