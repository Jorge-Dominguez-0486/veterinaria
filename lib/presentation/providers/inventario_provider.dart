import 'package:flutter/material.dart';
import '../../data/modelos/producto_inventario_modelo.dart';
import '../../data/repositorios/firestore_repositorio.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  PROVEEDOR INVENTARIO
//  Maneja: Productos e Inventario
// ═══════════════════════════════════════════════════════════════════════════

class ProveedorInventario extends ChangeNotifier {
  final FirestoreRepositorio<ProductoModelo> _repoProductos =
      FirestoreRepositorio(
    coleccion: Colecciones.productos,
    fromFirestore: ProductoModelo.fromFirestore,
    toFirestore: (p) => p.toFirestore(),
  );

  final FirestoreRepositorio<InventarioModelo> _repoInventario =
      FirestoreRepositorio(
    coleccion: Colecciones.inventario,
    fromFirestore: InventarioModelo.fromFirestore,
    toFirestore: (i) => i.toFirestore(),
  );

  List<ProductoModelo> _productos = [];
  List<InventarioModelo> _inventario = [];
  bool _cargando = false;
  String? _error;

  List<ProductoModelo> get productos => _productos;
  List<ProductoModelo> get productosActivos =>
      _productos.where((p) => p.activo).toList();
  List<InventarioModelo> get inventario => _inventario;
  bool get cargando => _cargando;
  String? get error => _error;

  // Productos con stock bajo — usa cantidadActual y cantidadMinima
  List<InventarioModelo> get stockBajo =>
      _inventario.where((i) => i.cantidadActual <= i.cantidadMinima).toList();

  // Valor total del inventario
  double get valorTotalInventario {
    double total = 0;
    for (final item in _inventario) {
      final producto = obtenerProductoPorId(item.productoId);
      if (producto != null) {
        total += item.cantidadActual * producto.precioCompra;
      }
    }
    return total;
  }

  // ── Cargar todo ────────────────────────────────────────────────────
  Future<void> cargarTodo() async {
    _setCargando(true);
    try {
      final resultados = await Future.wait([
        _repoProductos.obtenerTodos(),
        _repoInventario.obtenerTodos(),
      ]);
      _productos = resultados[0] as List<ProductoModelo>;
      _inventario = resultados[1] as List<InventarioModelo>;
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setCargando(false);
    }
  }

  // ── Escuchar inventario en tiempo real ────────────────────────────
  void escucharInventario() {
    _repoInventario.escucharTodos().listen((lista) {
      _inventario = lista;
      notifyListeners();
    });
  }

  // ────────────────────────────────────────────────────────────────────
  //  PRODUCTOS
  // ────────────────────────────────────────────────────────────────────
  Future<bool> crearProducto(ProductoModelo producto) async {
    _setCargando(true);
    try {
      await _repoProductos.crear(producto);
      _productos = await _repoProductos.obtenerTodos();
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

  Future<bool> actualizarProducto(ProductoModelo producto) async {
    _setCargando(true);
    try {
      await _repoProductos.actualizar(producto.id, producto);
      _productos = await _repoProductos.obtenerTodos();
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

  Future<bool> eliminarProducto(String id) async {
    _setCargando(true);
    try {
      await _repoProductos.eliminar(id);
      _productos = await _repoProductos.obtenerTodos();
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

  ProductoModelo? obtenerProductoPorId(String id) {
    try {
      return _productos.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ProductoModelo> buscarProductos(String query) {
    final q = query.toLowerCase();
    return _productos
        .where((p) =>
            p.nombre.toLowerCase().contains(q) ||
            p.descripcion.toLowerCase().contains(q))
        .toList();
  }

  List<ProductoModelo> productosPorCategoria(String categoriaId) =>
      _productos.where((p) => p.categoriaId == categoriaId).toList();

  // ────────────────────────────────────────────────────────────────────
  //  INVENTARIO
  // ────────────────────────────────────────────────────────────────────
  Future<bool> crearInventario(InventarioModelo item) async {
    _setCargando(true);
    try {
      await _repoInventario.crear(item);
      _inventario = await _repoInventario.obtenerTodos();
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

  Future<bool> actualizarInventario(InventarioModelo item) async {
    _setCargando(true);
    try {
      await _repoInventario.actualizar(item.id, item);
      _inventario = await _repoInventario.obtenerTodos();
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

  // Ajustar stock (suma o resta) — usa cantidadActual
  Future<bool> ajustarStock(String productoId, int cantidad) async {
    try {
      final items =
          await _repoInventario.obtenerPorCampo('productoId', productoId);
      if (items.isEmpty) return false;
      final item = items.first;
      final nuevoStock = item.cantidadActual + cantidad;
      if (nuevoStock < 0) {
        _error = 'Stock insuficiente';
        notifyListeners();
        return false;
      }
      await _repoInventario.actualizarCampos(
        item.id,
        {
          'cantidadActual': nuevoStock,
          'ultimaActualizacion': DateTime.now().toIso8601String(),
        },
      );
      _inventario = await _repoInventario.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  InventarioModelo? inventarioPorProducto(String productoId) {
    try {
      return _inventario.firstWhere((i) => i.productoId == productoId);
    } catch (_) {
      return null;
    }
  }

  // Devuelve cantidadActual del producto, 0 si no existe
  int stockActual(String productoId) {
    final item = inventarioPorProducto(productoId);
    return item?.cantidadActual ?? 0;
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  void _setCargando(bool v) {
    _cargando = v;
    notifyListeners();
  }
  // ────────────────────────────────────────────────────────────────────
  //  MÉTODOS ALIAS Y COMPATIBILIDAD CON PANTALLAS
  // ────────────────────────────────────────────────────────────────────

  // Devuelve la lista de productos que tienen stock bajo
  List<ProductoModelo> get productosStockBajo {
    return stockBajo
        .map((inv) => obtenerProductoPorId(inv.productoId))
        .whereType<ProductoModelo>()
        .toList();
  }

  // Devuelve el stock actual
  int stockDe(String productoId) => stockActual(productoId);

  // Devuelve el stock mínimo configurado
  int stockMinimoDe(String productoId) {
    final item = inventarioPorProducto(productoId);
    return item?.cantidadMinima ?? 0;
  }

  // Crea producto con sus parámetros de stock inicial
  Future<bool> crearProductoConStock(
    ProductoModelo producto, {
    required int stockInicial,
    required int stockMinimo,
    required int stockMaximo,
  }) async {
    _setCargando(true);
    try {
      // 1. Guardar producto
      await _repoProductos.crear(producto);

      // 2. Obtener el producto creado para saber su ID real
      _productos = await _repoProductos.obtenerTodos();
      final productoCreado =
          _productos.lastWhere((p) => p.nombre == producto.nombre);

      // 3. Crear su inventario vinculado
      final nuevoInventario = InventarioModelo(
        id: '',
        productoId: productoCreado.id,
        cantidadActual: stockInicial,
        cantidadMinima: stockMinimo,
        cantidadMaxima: stockMaximo,
        ultimaActualizacion: DateTime.now(),
      );

      await _repoInventario.crear(nuevoInventario);
      await cargarTodo();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setCargando(false);
    }
  }
}
