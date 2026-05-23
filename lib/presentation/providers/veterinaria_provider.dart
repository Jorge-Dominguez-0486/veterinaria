import 'package:flutter/material.dart';
import '../../data/modelos/veterinaria_modelo.dart';
import '../../data/repositorios/firestore_repositorio.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  PROVEEDOR VETERINARIA
//  Maneja: Citas, Consultas y Tratamientos
// ═══════════════════════════════════════════════════════════════════════════

class ProveedorVeterinaria extends ChangeNotifier {
  final FirestoreRepositorio<CitaModelo> _repoCitas = FirestoreRepositorio(
    coleccion: Colecciones.citas,
    fromFirestore: CitaModelo.fromFirestore,
    toFirestore: (c) => c.toFirestore(),
  );

  final FirestoreRepositorio<ConsultaModelo> _repoConsultas =
      FirestoreRepositorio(
    coleccion: Colecciones.consultas,
    fromFirestore: ConsultaModelo.fromFirestore,
    toFirestore: (c) => c.toFirestore(),
  );

  final FirestoreRepositorio<TratamientoModelo> _repoTratamientos =
      FirestoreRepositorio(
    coleccion: Colecciones.tratamientos,
    fromFirestore: TratamientoModelo.fromFirestore,
    toFirestore: (t) => t.toFirestore(),
  );

  List<CitaModelo> _citas = [];
  List<ConsultaModelo> _consultas = [];
  List<TratamientoModelo> _tratamientos = [];
  bool _cargando = false;
  String? _error;

  List<CitaModelo> get citas => _citas;
  List<ConsultaModelo> get consultas => _consultas;
  List<TratamientoModelo> get tratamientos => _tratamientos;
  bool get cargando => _cargando;
  String? get error => _error;

  // Filtros rápidos de citas
  List<CitaModelo> get citasProgramadas =>
      _citas.where((c) => c.estado == 'programada').toList();
  List<CitaModelo> get citasHoy {
    final hoy = DateTime.now();
    return _citas.where((c) {
      final f = c.fechaHora;
      return f.year == hoy.year && f.month == hoy.month && f.day == hoy.day;
    }).toList();
  }

  List<TratamientoModelo> get tratamientosActivos =>
      _tratamientos.where((t) => t.estado == 'activo').toList();

  // ── Cargar todo ────────────────────────────────────────────────────
  Future<void> cargarTodo() async {
    _setCargando(true);
    try {
      final resultados = await Future.wait([
        _repoCitas.obtenerTodos(),
        _repoConsultas.obtenerTodos(),
        _repoTratamientos.obtenerTodos(),
      ]);
      _citas = resultados[0] as List<CitaModelo>;
      _consultas = resultados[1] as List<ConsultaModelo>;
      _tratamientos = resultados[2] as List<TratamientoModelo>;
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setCargando(false);
    }
  }

  // ── Escuchar citas en tiempo real ─────────────────────────────────
  void escucharCitas() {
    _repoCitas.escucharTodos().listen((lista) {
      _citas = lista;
      notifyListeners();
    });
  }

  // ────────────────────────────────────────────────────────────────────
  //  CITAS
  // ────────────────────────────────────────────────────────────────────
  Future<bool> crearCita(CitaModelo cita) async {
    _setCargando(true);
    try {
      await _repoCitas.crear(cita);
      _citas = await _repoCitas.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setCargando(false);
    }
  }

  Future<bool> actualizarCita(CitaModelo cita) async {
    _setCargando(true);
    try {
      await _repoCitas.actualizar(cita.id, cita);
      _citas = await _repoCitas.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setCargando(false);
    }
  }

  Future<bool> cambiarEstadoCita(String id, String nuevoEstado) async {
    try {
      await _repoCitas.actualizarCampos(id, {'estado': nuevoEstado});
      _citas = await _repoCitas.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarCita(String id) async {
    _setCargando(true);
    try {
      await _repoCitas.eliminar(id);
      _citas = await _repoCitas.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setCargando(false);
    }
  }

  List<CitaModelo> citasPorMascota(String mascotaId) =>
      _citas.where((c) => c.mascotaId == mascotaId).toList();

  List<CitaModelo> citasPorEmpleado(String empleadoId) =>
      _citas.where((c) => c.empleadoId == empleadoId).toList();

  CitaModelo? obtenerCitaPorId(String id) {
    try {
      return _citas.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ────────────────────────────────────────────────────────────────────
  //  CONSULTAS
  // ────────────────────────────────────────────────────────────────────
  Future<bool> crearConsulta(ConsultaModelo consulta) async {
    _setCargando(true);
    try {
      await _repoConsultas.crear(consulta);
      _consultas = await _repoConsultas.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setCargando(false);
    }
  }

  Future<bool> actualizarConsulta(ConsultaModelo consulta) async {
    _setCargando(true);
    try {
      await _repoConsultas.actualizar(consulta.id, consulta);
      _consultas = await _repoConsultas.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setCargando(false);
    }
  }

  Future<bool> eliminarConsulta(String id) async {
    _setCargando(true);
    try {
      await _repoConsultas.eliminar(id);
      _consultas = await _repoConsultas.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setCargando(false);
    }
  }

  List<ConsultaModelo> consultasPorMascota(String mascotaId) =>
      _consultas.where((c) => c.mascotaId == mascotaId).toList();

  ConsultaModelo? obtenerConsultaPorId(String id) {
    try {
      return _consultas.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ────────────────────────────────────────────────────────────────────
  //  TRATAMIENTOS
  // ────────────────────────────────────────────────────────────────────
  Future<bool> crearTratamiento(TratamientoModelo tratamiento) async {
    _setCargando(true);
    try {
      await _repoTratamientos.crear(tratamiento);
      _tratamientos = await _repoTratamientos.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setCargando(false);
    }
  }

  Future<bool> actualizarTratamiento(TratamientoModelo tratamiento) async {
    _setCargando(true);
    try {
      await _repoTratamientos.actualizar(tratamiento.id, tratamiento);
      _tratamientos = await _repoTratamientos.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setCargando(false);
    }
  }

  Future<bool> cambiarEstadoTratamiento(String id, String nuevoEstado) async {
    try {
      await _repoTratamientos.actualizarCampos(id, {'estado': nuevoEstado});
      _tratamientos = await _repoTratamientos.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarTratamiento(String id) async {
    _setCargando(true);
    try {
      await _repoTratamientos.eliminar(id);
      _tratamientos = await _repoTratamientos.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setCargando(false);
    }
  }

  List<TratamientoModelo> tratamientosPorMascota(String mascotaId) =>
      _tratamientos.where((t) => t.mascotaId == mascotaId).toList();

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  void _setCargando(bool v) {
    _cargando = v;
    notifyListeners();
  }
}
