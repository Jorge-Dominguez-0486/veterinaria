import 'package:flutter/material.dart';
import '../../data/modelos/especie_modelo.dart';
import '../../data/modelos/raza_modelo.dart';
import '../../data/modelos/categoria_proveedor_modelo.dart';
import '../../data/repositorios/firestore_repositorio.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  PROVEEDOR CATÁLOGOS
//  Maneja: Especies, Razas, Categorías y Proveedores
// ═══════════════════════════════════════════════════════════════════════════

class ProveedorCatalogos extends ChangeNotifier {
  // Repositorios
  final FirestoreRepositorio<EspecieModelo> _repoEspecies =
      FirestoreRepositorio(
    coleccion: Colecciones.especies,
    fromFirestore: EspecieModelo.fromFirestore,
    toFirestore: (e) => e.toFirestore(),
  );

  final FirestoreRepositorio<RazaModelo> _repoRazas = FirestoreRepositorio(
    coleccion: Colecciones.razas,
    fromFirestore: RazaModelo.fromFirestore,
    toFirestore: (r) => r.toFirestore(),
  );

  final FirestoreRepositorio<CategoriaModelo> _repoCategorias =
      FirestoreRepositorio(
    coleccion: Colecciones.categorias,
    fromFirestore: CategoriaModelo.fromFirestore,
    toFirestore: (c) => c.toFirestore(),
  );

  final FirestoreRepositorio<ProveedorModelo> _repoProveedores =
      FirestoreRepositorio(
    coleccion: Colecciones.proveedores,
    fromFirestore: ProveedorModelo.fromFirestore,
    toFirestore: (p) => p.toFirestore(),
  );

  // Estado
  List<EspecieModelo> _especies = [];
  List<RazaModelo> _razas = [];
  List<CategoriaModelo> _categorias = [];
  List<ProveedorModelo> _proveedores = [];
  bool _cargando = false;
  String? _error;

  // Getters
  List<EspecieModelo> get especies => _especies;
  List<RazaModelo> get razas => _razas;
  List<CategoriaModelo> get categorias => _categorias;
  List<ProveedorModelo> get proveedores => _proveedores;
  bool get cargando => _cargando;
  String? get error => _error;

  List<RazaModelo> razasPorEspecie(String especieId) =>
      _razas.where((r) => r.especieId == especieId).toList();

  List<ProveedorModelo> get proveedoresActivos =>
      _proveedores.where((p) => p.activo).toList();

  // ── Cargar todo de una vez ─────────────────────────────────────────
  Future<void> cargarTodo() async {
    _setCargando(true);
    try {
      final resultados = await Future.wait([
        _repoEspecies.obtenerTodos(),
        _repoRazas.obtenerTodos(),
        _repoCategorias.obtenerTodos(),
        _repoProveedores.obtenerTodos(),
      ]);
      _especies = resultados[0] as List<EspecieModelo>;
      _razas = resultados[1] as List<RazaModelo>;
      _categorias = resultados[2] as List<CategoriaModelo>;
      _proveedores = resultados[3] as List<ProveedorModelo>;
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setCargando(false);
    }
  }

  // ────────────────────────────────────────────────────────────────────
  //  ESPECIES
  // ────────────────────────────────────────────────────────────────────
  Future<bool> crearEspecie(EspecieModelo especie) async {
    try {
      await _repoEspecies.crear(especie);
      _especies = await _repoEspecies.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarEspecie(EspecieModelo especie) async {
    try {
      await _repoEspecies.actualizar(especie.id, especie);
      _especies = await _repoEspecies.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarEspecie(String id) async {
    try {
      await _repoEspecies.eliminar(id);
      _especies = await _repoEspecies.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  EspecieModelo? obtenerEspeciePorId(String id) {
    try {
      return _especies.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  // ────────────────────────────────────────────────────────────────────
  //  RAZAS
  // ────────────────────────────────────────────────────────────────────
  Future<bool> crearRaza(RazaModelo raza) async {
    try {
      await _repoRazas.crear(raza);
      _razas = await _repoRazas.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarRaza(RazaModelo raza) async {
    try {
      await _repoRazas.actualizar(raza.id, raza);
      _razas = await _repoRazas.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarRaza(String id) async {
    try {
      await _repoRazas.eliminar(id);
      _razas = await _repoRazas.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  RazaModelo? obtenerRazaPorId(String id) {
    try {
      return _razas.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // ────────────────────────────────────────────────────────────────────
  //  CATEGORÍAS
  // ────────────────────────────────────────────────────────────────────
  Future<bool> crearCategoria(CategoriaModelo categoria) async {
    try {
      await _repoCategorias.crear(categoria);
      _categorias = await _repoCategorias.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarCategoria(CategoriaModelo categoria) async {
    try {
      await _repoCategorias.actualizar(categoria.id, categoria);
      _categorias = await _repoCategorias.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarCategoria(String id) async {
    try {
      await _repoCategorias.eliminar(id);
      _categorias = await _repoCategorias.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  CategoriaModelo? obtenerCategoriaPorId(String id) {
    try {
      return _categorias.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ────────────────────────────────────────────────────────────────────
  //  PROVEEDORES
  // ────────────────────────────────────────────────────────────────────
  Future<bool> crearProveedor(ProveedorModelo proveedor) async {
    try {
      await _repoProveedores.crear(proveedor);
      _proveedores = await _repoProveedores.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarProveedor(ProveedorModelo proveedor) async {
    try {
      await _repoProveedores.actualizar(proveedor.id, proveedor);
      _proveedores = await _repoProveedores.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarProveedor(String id) async {
    try {
      await _repoProveedores.desactivar(id);
      _proveedores = await _repoProveedores.obtenerTodos();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  ProveedorModelo? obtenerProveedorPorId(String id) {
    try {
      return _proveedores.firstWhere((p) => p.id == id);
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
