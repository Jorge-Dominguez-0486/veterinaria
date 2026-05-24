// ═══════════════════════════════════════════════════════════════════════════
//  usuarios_roles_screen.dart  —  Gestión de roles de usuarios (Admin)
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/modelos/usuario_modelo.dart';

class UsuariosRolesScreen extends StatelessWidget {
  const UsuariosRolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primario));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay usuarios registrados.'));
        }

        final usuarios = snapshot.data!.docs
            .map((doc) {
              try {
                return UsuarioModelo.fromFirestore(doc);
              } catch (_) {
                return null;
              }
            })
            .whereType<UsuarioModelo>()
            .toList()
          ..sort((a, b) => a.nombre.compareTo(b.nombre));

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: usuarios.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _TarjetaUsuario(usuario: usuarios[i]),
        );
      },
    );
  }
}

// ── Tarjeta de usuario con selector de rol ───────────────────────────────
class _TarjetaUsuario extends StatelessWidget {
  final UsuarioModelo usuario;
  const _TarjetaUsuario({required this.usuario});

  static const _coloresRol = {
    RolUsuario.admin: Color(0xFFBC6C25),
    RolUsuario.empleado: Color(0xFF4A90D9),
    RolUsuario.cliente: Color(0xFF5C9E6B),
  };

  static const _iconosRol = {
    RolUsuario.admin: Icons.admin_panel_settings_rounded,
    RolUsuario.empleado: Icons.badge_rounded,
    RolUsuario.cliente: Icons.person_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final color = _coloresRol[usuario.rol] ?? AppColors.textoMedio;

    return Card(
      color: AppColors.fondoTarjeta,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Text(
            usuario.nombre.isNotEmpty ? usuario.nombre[0].toUpperCase() : '?',
            style: TextStyle(
                color: color, fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ),
        title: Text(usuario.nombreCompleto,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(usuario.email,
            style: const TextStyle(fontSize: 12, color: AppColors.textoMedio)),
        trailing: _SelectorRol(usuario: usuario),
      ),
    );
  }
}

class _SelectorRol extends StatefulWidget {
  final UsuarioModelo usuario;
  const _SelectorRol({required this.usuario});

  @override
  State<_SelectorRol> createState() => _SelectorRolState();
}

class _SelectorRolState extends State<_SelectorRol> {
  bool _guardando = false;

  static const _coloresRol = {
    RolUsuario.admin: Color(0xFFBC6C25),
    RolUsuario.empleado: Color(0xFF4A90D9),
    RolUsuario.cliente: Color(0xFF5C9E6B),
  };
  static const _iconosRol = {
    RolUsuario.admin: Icons.admin_panel_settings_rounded,
    RolUsuario.empleado: Icons.badge_rounded,
    RolUsuario.cliente: Icons.person_rounded,
  };

  @override
  Widget build(BuildContext context) {
    if (_guardando) {
      return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primario));
    }

    final color = _coloresRol[widget.usuario.rol] ?? AppColors.textoMedio;

    return PopupMenuButton<RolUsuario>(
      tooltip: 'Cambiar rol',
      color: AppColors.fondoTarjeta,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (nuevoRol) => _cambiarRol(context, nuevoRol),
      itemBuilder: (_) => RolUsuario.values
          .map(
            (r) => PopupMenuItem<RolUsuario>(
              value: r,
              child: Row(
                children: [
                  Icon(_iconosRol[r], color: _coloresRol[r], size: 18),
                  const SizedBox(width: 10),
                  Text(
                    _textoRol(r),
                    style: TextStyle(
                      color: _coloresRol[r],
                      fontWeight: r == widget.usuario.rol
                          ? FontWeight.w800
                          : FontWeight.normal,
                    ),
                  ),
                  if (r == widget.usuario.rol) ...[
                    const Spacer(),
                    Icon(Icons.check_rounded, color: _coloresRol[r], size: 16),
                  ]
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_iconosRol[widget.usuario.rol], color: color, size: 14),
            const SizedBox(width: 5),
            Text(_textoRol(widget.usuario.rol),
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  String _textoRol(RolUsuario r) {
    switch (r) {
      case RolUsuario.admin:
        return 'Admin';
      case RolUsuario.empleado:
        return 'Empleado';
      case RolUsuario.cliente:
        return 'Cliente';
    }
  }

  Future<void> _cambiarRol(BuildContext context, RolUsuario nuevoRol) async {
    if (nuevoRol == widget.usuario.rol) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.fondo,
        title: const Text('Cambiar rol'),
        content: Text(
            '¿Cambiar el rol de ${widget.usuario.nombre} a "${_textoRol(nuevoRol)}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primario,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    setState(() => _guardando = true);
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.usuario.id)
          .update({'rol': nuevoRol.name});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rol actualizado a ${_textoRol(nuevoRol)}'),
            backgroundColor: AppColors.exito,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar el rol'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }
}
