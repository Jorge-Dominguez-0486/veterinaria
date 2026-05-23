import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/modelos/usuario_modelo.dart';
import '../../data/repositorios/auth_repositorio.dart';

enum EstadoAuth { inicial, cargando, autenticado, noAutenticado, error }

class ProveedorAuth extends ChangeNotifier {
  final AuthRepositorio _repositorio = AuthRepositorio();

  EstadoAuth _estado = EstadoAuth.inicial;
  UsuarioModelo? _usuario;
  String? _mensajeError;

  EstadoAuth get estado => _estado;
  UsuarioModelo? get usuario => _usuario;
  String? get mensajeError => _mensajeError;
  bool get estaAutenticado => _estado == EstadoAuth.autenticado;
  bool get estaCargando => _estado == EstadoAuth.cargando;
  bool get esAdmin => _usuario?.rol == RolUsuario.admin;

  ProveedorAuth() {
    _escucharAuth();
  }

  // ── Escuchar cambios de autenticación ─────────────────────────────
  void _escucharAuth() {
    _repositorio.estadoAuth.listen((User? user) async {
      if (user == null) {
        _estado = EstadoAuth.noAutenticado;
        _usuario = null;
      } else {
        try {
          _usuario = await _repositorio.obtenerUsuario(user.uid);
          _estado = _usuario != null
              ? EstadoAuth.autenticado
              : EstadoAuth.noAutenticado;
        } catch (_) {
          _estado = EstadoAuth.noAutenticado;
        }
      }
      notifyListeners();
    });
  }

  // ── Iniciar sesión ─────────────────────────────────────────────────
  Future<bool> iniciarSesion({
    required String email,
    required String contrasena,
  }) async {
    _setEstado(EstadoAuth.cargando);
    try {
      _usuario = await _repositorio.iniciarSesion(
        email: email,
        contrasena: contrasena,
      );
      _setEstado(EstadoAuth.autenticado);
      return true;
    } catch (e) {
      _mensajeError = e.toString().replaceFirst('Exception: ', '');
      _setEstado(EstadoAuth.error);
      return false;
    }
  }

  // ── Registrar ──────────────────────────────────────────────────────
  Future<bool> registrar({
    required String nombre,
    required String apellido,
    required String email,
    required String telefono,
    required String contrasena,
  }) async {
    _setEstado(EstadoAuth.cargando);
    try {
      _usuario = await _repositorio.registrar(
        nombre: nombre,
        apellido: apellido,
        email: email,
        telefono: telefono,
        contrasena: contrasena,
      );
      _setEstado(EstadoAuth.autenticado);
      return true;
    } catch (e) {
      _mensajeError = e.toString().replaceFirst('Exception: ', '');
      _setEstado(EstadoAuth.error);
      return false;
    }
  }

  // ── Cerrar sesión ──────────────────────────────────────────────────
  Future<void> cerrarSesion() async {
    await _repositorio.cerrarSesion();
    _usuario = null;
    _setEstado(EstadoAuth.noAutenticado);
  }

  // ── Recuperar contraseña ───────────────────────────────────────────
  Future<bool> recuperarContrasena(String email) async {
    try {
      await _repositorio.recuperarContrasena(email);
      return true;
    } catch (e) {
      _mensajeError = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  void limpiarError() {
    _mensajeError = null;
    notifyListeners();
  }

  void _setEstado(EstadoAuth nuevoEstado) {
    _estado = nuevoEstado;
    notifyListeners();
  }
}
