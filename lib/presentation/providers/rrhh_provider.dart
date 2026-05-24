import 'package:flutter/material.dart';
import '../../data/modelos/rrhh_modelo.dart';
import '../../data/repositorios/firestore_repositorio.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  PROVEEDOR RRHH
//  Maneja: Empleados y Horarios
// ═══════════════════════════════════════════════════════════════════════════

class ProveedorRRHH extends ChangeNotifier {
  final FirestoreRepositorio<EmpleadoModelo> _repoEmpleados =
      FirestoreRepositorio(
    coleccion: Colecciones.empleados,
    fromFirestore: EmpleadoModelo.fromFirestore,
    toFirestore: (e) => e.toFirestore(),
    // empleados sí tienen 'nombre', se deja el default
  );

  final FirestoreRepositorio<HorarioModelo> _repoHorarios =
      FirestoreRepositorio(
    coleccion: Colecciones.horarios,
    fromFirestore: HorarioModelo.fromFirestore,
    toFirestore: (h) => h.toFirestore(),
    ordenarPor: null, // horarios no tienen campo 'nombre'
  );

  List<EmpleadoModelo> _empleados = [];
  List<HorarioModelo> _horarios = [];
  bool _cargando = false;
  String? _error;

  List<EmpleadoModelo> get empleados => _empleados;
  List<HorarioModelo> get horarios => _horarios;
  bool get cargando => _cargando;
  String? get error => _error;

  List<EmpleadoModelo> get empleadosActivos =>
      _empleados.where((e) => e.activo).toList();

  List<EmpleadoModelo> get veterinarios =>
      _empleados.where((e) => e.puesto == 'veterinario' && e.activo).toList();

  double get nominaTotal =>
      _empleados.where((e) => e.activo).fold(0.0, (sum, e) => sum + e.salario);

  // ── Cargar todo ────────────────────────────────────────────────────
  Future<void> cargarTodo() async {
    _setCargando(true);
    try {
      final resultados = await Future.wait([
        _repoEmpleados.obtenerTodos(),
        _repoHorarios.obtenerTodos(),
      ]);
      _empleados = resultados[0] as List<EmpleadoModelo>;
      _horarios = resultados[1] as List<HorarioModelo>;
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setCargando(false);
    }
  }

  // ────────────────────────────────────────────────────────────────────
  //  EMPLEADOS
  // ────────────────────────────────────────────────────────────────────
  Future<bool> crearEmpleado(EmpleadoModelo empleado) async {
    _setCargando(true);
    try {
      await _repoEmpleados.crear(empleado);
      _empleados = await _repoEmpleados.obtenerTodos();
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

  Future<bool> actualizarEmpleado(EmpleadoModelo empleado) async {
    _setCargando(true);
    try {
      await _repoEmpleados.actualizar(empleado.id, empleado);
      _empleados = await _repoEmpleados.obtenerTodos();
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

  Future<bool> eliminarEmpleado(String id) async {
    _setCargando(true);
    try {
      await _repoEmpleados.eliminar(id);
      _empleados = await _repoEmpleados.obtenerTodos();
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

  Future<bool> eliminarEmpleadoPermanente(String id) async {
    _setCargando(true);
    try {
      await _repoEmpleados.eliminar(id);
      _empleados = await _repoEmpleados.obtenerTodos();
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

  EmpleadoModelo? obtenerEmpleadoPorId(String id) {
    try {
      return _empleados.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  List<EmpleadoModelo> buscarEmpleados(String query) {
    final q = query.toLowerCase();
    return _empleados
        .where((e) =>
            e.nombre.toLowerCase().contains(q) ||
            e.apellido.toLowerCase().contains(q) ||
            e.puesto.toLowerCase().contains(q))
        .toList();
  }

  List<EmpleadoModelo> empleadosPorPuesto(String puesto) =>
      _empleados.where((e) => e.puesto == puesto && e.activo).toList();

  // ────────────────────────────────────────────────────────────────────
  //  HORARIOS
  // ────────────────────────────────────────────────────────────────────
  Future<bool> crearHorario(HorarioModelo horario) async {
    _setCargando(true);
    try {
      await _repoHorarios.crear(horario);
      _horarios = await _repoHorarios.obtenerTodos();
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

  Future<bool> actualizarHorario(HorarioModelo horario) async {
    _setCargando(true);
    try {
      await _repoHorarios.actualizar(horario.id, horario);
      _horarios = await _repoHorarios.obtenerTodos();
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

  Future<bool> eliminarHorario(String id) async {
    _setCargando(true);
    try {
      await _repoHorarios.eliminar(id);
      _horarios = await _repoHorarios.obtenerTodos();
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

  List<HorarioModelo> horariosPorEmpleado(String empleadoId) =>
      _horarios.where((h) => h.empleadoId == empleadoId).toList();

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  void _setCargando(bool v) {
    _cargando = v;
    notifyListeners();
  }
}
