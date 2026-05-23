import 'package:flutter/material.dart';
import '../../data/modelos/finanzas_modelo.dart';
import '../../data/repositorios/firestore_repositorio.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  PROVEEDOR FINANZAS
//  Maneja: Ventas, Compras y Gastos
// ═══════════════════════════════════════════════════════════════════════════

class ProveedorFinanzas extends ChangeNotifier {
  final FirestoreRepositorio<VentaModelo> _repoVentas = FirestoreRepositorio(
    coleccion: Colecciones.ventas,
    fromFirestore: VentaModelo.fromFirestore,
    toFirestore: (v) => v.toFirestore(),
  );

  final FirestoreRepositorio<CompraModelo> _repoCompras = FirestoreRepositorio(
    coleccion: Colecciones.compras,
    fromFirestore: CompraModelo.fromFirestore,
    toFirestore: (c) => c.toFirestore(),
  );

  final FirestoreRepositorio<GastoModelo> _repoGastos = FirestoreRepositorio(
    coleccion: Colecciones.gastos,
    fromFirestore: GastoModelo.fromFirestore,
    toFirestore: (g) => g.toFirestore(),
  );

  List<VentaModelo> _ventas = [];
  List<CompraModelo> _compras = [];
  List<GastoModelo> _gastos = [];
  bool _cargando = false;
  String? _error;

  List<VentaModelo> get ventas => _ventas;
  List<CompraModelo> get compras => _compras;
  List<GastoModelo> get gastos => _gastos;
  bool get cargando => _cargando;
  String? get error => _error;

  // ── KPIs financieros ──────────────────────────────────────────────
  double get totalVentasMes {
    final ahora = DateTime.now();
    return _ventas
        .where((v) =>
            v.estado == 'pagada' &&
            v.fecha.year == ahora.year &&
            v.fecha.month == ahora.month)
        .fold(0.0, (sum, v) => sum + v.totalConDescuento);
  }

  double get totalComprasMes {
    final ahora = DateTime.now();
    return _compras
        .where(
            (c) => c.fecha.year == ahora.year && c.fecha.month == ahora.month)
        .fold(0.0, (sum, c) => sum + c.total);
  }

  double get totalGastosMes {
    final ahora = DateTime.now();
    return _gastos
        .where(
            (g) => g.fecha.year == ahora.year && g.fecha.month == ahora.month)
        .fold(0.0, (sum, g) => sum + g.monto);
  }

  double get utilidadMes => totalVentasMes - totalComprasMes - totalGastosMes;

  // ── Cargar todo ────────────────────────────────────────────────────
  Future<void> cargarTodo() async {
    _setCargando(true);
    try {
      final resultados = await Future.wait([
        _repoVentas.obtenerTodos(),
        _repoCompras.obtenerTodos(),
        _repoGastos.obtenerTodos(),
      ]);
      _ventas = resultados[0] as List<VentaModelo>;
      _compras = resultados[1] as List<CompraModelo>;
      _gastos = resultados[2] as List<GastoModelo>;
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setCargando(false);
    }
  }

  // ────────────────────────────────────────────────────────────────────
  //  VENTAS
  // ────────────────────────────────────────────────────────────────────
  Future<bool> crearVenta(VentaModelo venta) async {
    _setCargando(true);
    try {
      await _repoVentas.crear(venta);
      _ventas = await _repoVentas.obtenerTodos();
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

  Future<bool> actualizarVenta(VentaModelo venta) async {
    _setCargando(true);
    try {
      await _repoVentas.actualizar(venta.id, venta);
      _ventas = await _repoVentas.obtenerTodos();
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

  Future<bool> cambiarEstadoVenta(String id, String nuevoEstado) async {
    try {
      await _repoVentas.actualizarCampos(id, {'estado': nuevoEstado});
      _ventas = await _repoVentas.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarVenta(String id) async {
    _setCargando(true);
    try {
      await _repoVentas.eliminar(id);
      _ventas = await _repoVentas.obtenerTodos();
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

  List<VentaModelo> ventasPorCliente(String clienteId) =>
      _ventas.where((v) => v.clienteId == clienteId).toList();

  VentaModelo? obtenerVentaPorId(String id) {
    try {
      return _ventas.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  // ────────────────────────────────────────────────────────────────────
  //  COMPRAS
  // ────────────────────────────────────────────────────────────────────
  Future<bool> crearCompra(CompraModelo compra) async {
    _setCargando(true);
    try {
      await _repoCompras.crear(compra);
      _compras = await _repoCompras.obtenerTodos();
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

  Future<bool> actualizarCompra(CompraModelo compra) async {
    _setCargando(true);
    try {
      await _repoCompras.actualizar(compra.id, compra);
      _compras = await _repoCompras.obtenerTodos();
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

  Future<bool> eliminarCompra(String id) async {
    _setCargando(true);
    try {
      await _repoCompras.eliminar(id);
      _compras = await _repoCompras.obtenerTodos();
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

  // ────────────────────────────────────────────────────────────────────
  //  GASTOS
  // ────────────────────────────────────────────────────────────────────
  Future<bool> crearGasto(GastoModelo gasto) async {
    _setCargando(true);
    try {
      await _repoGastos.crear(gasto);
      _gastos = await _repoGastos.obtenerTodos();
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

  Future<bool> actualizarGasto(GastoModelo gasto) async {
    _setCargando(true);
    try {
      await _repoGastos.actualizar(gasto.id, gasto);
      _gastos = await _repoGastos.obtenerTodos();
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

  Future<bool> eliminarGasto(String id) async {
    _setCargando(true);
    try {
      await _repoGastos.eliminar(id);
      _gastos = await _repoGastos.obtenerTodos();
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

  // ── Reporte por rango de fechas ───────────────────────────────────
  List<VentaModelo> ventasEnRango(DateTime inicio, DateTime fin) => _ventas
      .where((v) =>
          v.fecha.isAfter(inicio.subtract(const Duration(days: 1))) &&
          v.fecha.isBefore(fin.add(const Duration(days: 1))))
      .toList();

  List<GastoModelo> gastosPorCategoria(String categoria) =>
      _gastos.where((g) => g.categoria == categoria).toList();

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  void _setCargando(bool v) {
    _cargando = v;
    notifyListeners();
  }
}
