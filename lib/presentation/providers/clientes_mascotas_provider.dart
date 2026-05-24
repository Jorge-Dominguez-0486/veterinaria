import 'package:flutter/material.dart';
import '../../data/modelos/cliente_modelo.dart';
import '../../data/modelos/mascota_modelo.dart';
import '../../data/repositorios/firestore_repositorio.dart';

class ProveedorClientes extends ChangeNotifier {
  final FirestoreRepositorio<ClienteModelo> _repo = FirestoreRepositorio(
    coleccion: Colecciones.clientes,
    fromFirestore: ClienteModelo.fromFirestore,
    toFirestore: (c) => c.toFirestore(),
  );

  List<ClienteModelo> _clientes = [];
  bool _cargando = false;
  String? _error;

  List<ClienteModelo> get clientes => _clientes;
  List<ClienteModelo> get clientesActivos =>
      _clientes.where((c) => c.activo).toList();
  bool get cargando => _cargando;
  String? get error => _error;

  // ── Cargar todos ──────────────────────────────────────────────────
  Future<void> cargarClientes() async {
    _setCargando(true);
    try {
      _clientes = await _repo.obtenerTodos();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setCargando(false);
    }
  }

  // ── Escuchar en tiempo real ───────────────────────────────────────
  void escucharClientes() {
    _repo.escucharTodos().listen((lista) {
      _clientes = lista;
      notifyListeners();
    });
  }

  // ── Crear ─────────────────────────────────────────────────────────
  Future<bool> crearCliente(ClienteModelo cliente) async {
    _setCargando(true);
    try {
      await _repo.crear(cliente);
      await cargarClientes();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setCargando(false);
    }
  }

  // ── Actualizar ────────────────────────────────────────────────────
  Future<bool> actualizarCliente(ClienteModelo cliente) async {
    _setCargando(true);
    try {
      await _repo.actualizar(cliente.id, cliente);
      await cargarClientes();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setCargando(false);
    }
  }

  // ── Eliminar (soft delete) ────────────────────────────────────────
  Future<bool> eliminarCliente(String id) async {
    _setCargando(true);
    try {
      await _repo.eliminar(id);
      await cargarClientes();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setCargando(false);
    }
  }

  // ── Eliminar permanente ───────────────────────────────────────────
  Future<bool> eliminarClientePermanente(String id) async {
    _setCargando(true);
    try {
      await _repo.eliminar(id);
      await cargarClientes();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setCargando(false);
    }
  }

  // ── Buscar ────────────────────────────────────────────────────────
  List<ClienteModelo> buscar(String query) {
    final q = query.toLowerCase();
    return _clientes
        .where((c) =>
            c.nombre.toLowerCase().contains(q) ||
            c.apellido.toLowerCase().contains(q) ||
            c.email.toLowerCase().contains(q) ||
            c.telefono.contains(q))
        .toList();
  }

  ClienteModelo? obtenerPorId(String id) {
    try {
      return _clientes.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  void _setCargando(bool v) {
    _cargando = v;
    notifyListeners();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PROVEEDOR MASCOTAS
// ═══════════════════════════════════════════════════════════════════════════

class ProveedorMascotas extends ChangeNotifier {
  final FirestoreRepositorio<MascotaModelo> _repo = FirestoreRepositorio(
    coleccion: Colecciones.mascotas,
    fromFirestore: MascotaModelo.fromFirestore,
    toFirestore: (m) => m.toFirestore(),
  );

  List<MascotaModelo> _mascotas = [];
  bool _cargando = false;
  String? _error;

  List<MascotaModelo> get mascotas => _mascotas;
  List<MascotaModelo> get mascotasActivas =>
      _mascotas.where((m) => m.activo).toList();
  bool get cargando => _cargando;
  String? get error => _error;

  // ── Cargar todas ──────────────────────────────────────────────────
  Future<void> cargarMascotas() async {
    _setCargando(true);
    try {
      _mascotas = await _repo.obtenerTodos();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setCargando(false);
    }
  }

  // ── Mascotas de un cliente (admin: consulta general) ─────────────
  Future<List<MascotaModelo>> mascotasDeCliente(String clienteId) async {
    return await _repo.obtenerPorCampo('clienteId', clienteId);
  }

  List<MascotaModelo> mascotasDeClienteLocal(String clienteId) =>
      _mascotas.where((m) => m.clienteId == clienteId && m.activo).toList();

  // ── Cargar solo las mascotas del cliente autenticado ──────────────
  // Usado por las pantallas del área de cliente (no del panel admin).
  Future<void> cargarMascotasPorCliente(String clienteId) async {
    _setCargando(true);
    try {
      _mascotas = await _repo.obtenerPorCampo('clienteId', clienteId);
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setCargando(false);
    }
  }

  // ── Crear ─────────────────────────────────────────────────────────
  Future<bool> crearMascota(MascotaModelo mascota) async {
    _setCargando(true);
    try {
      await _repo.crear(mascota);
      await cargarMascotas();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setCargando(false);
    }
  }

  // ── Actualizar ────────────────────────────────────────────────────
  Future<bool> actualizarMascota(MascotaModelo mascota) async {
    _setCargando(true);
    try {
      await _repo.actualizar(mascota.id, mascota);
      await cargarMascotas();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setCargando(false);
    }
  }

  // ── Eliminar (soft delete) ────────────────────────────────────────
  Future<bool> eliminarMascota(String id) async {
    _setCargando(true);
    try {
      await _repo.eliminar(id);
      await cargarMascotas();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setCargando(false);
    }
  }

  // ── Buscar ────────────────────────────────────────────────────────
  List<MascotaModelo> buscar(String query) {
    final q = query.toLowerCase();
    return _mascotas.where((m) => m.nombre.toLowerCase().contains(q)).toList();
  }

  MascotaModelo? obtenerPorId(String id) {
    try {
      return _mascotas.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  void _setCargando(bool v) {
    _cargando = v;
    notifyListeners();
  }
}
