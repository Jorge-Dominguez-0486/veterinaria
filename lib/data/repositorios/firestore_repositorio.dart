import 'package:cloud_firestore/cloud_firestore.dart';

/// Repositorio genérico — maneja cualquier colección de Firestore
/// con operaciones CRUD completas.
class FirestoreRepositorio<T> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String coleccion;
  final T Function(DocumentSnapshot) fromFirestore;
  final Map<String, dynamic> Function(T) toFirestore;

  FirestoreRepositorio({
    required this.coleccion,
    required this.fromFirestore,
    required this.toFirestore,
  });

  // ── Referencia a la colección ──────────────────────────────────────
  CollectionReference get _ref => _db.collection(coleccion);

  // ── CREAR ──────────────────────────────────────────────────────────
  Future<String> crear(T item) async {
    try {
      final docRef = await _ref.add(toFirestore(item));
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear en $coleccion: $e');
    }
  }

  // ── CREAR CON ID ESPECÍFICO ────────────────────────────────────────
  Future<void> crearConId(String id, T item) async {
    try {
      await _ref.doc(id).set(toFirestore(item));
    } catch (e) {
      throw Exception('Error al crear con ID en $coleccion: $e');
    }
  }

  // ── LEER UNO ───────────────────────────────────────────────────────
  Future<T?> obtenerPorId(String id) async {
    try {
      final doc = await _ref.doc(id).get();
      if (!doc.exists) return null;
      return fromFirestore(doc);
    } catch (e) {
      throw Exception('Error al obtener de $coleccion: $e');
    }
  }

  // ── LEER TODOS ─────────────────────────────────────────────────────
  Future<List<T>> obtenerTodos() async {
    try {
      final snap = await _ref.orderBy('nombre').get();
      return snap.docs.map(fromFirestore).toList();
    } catch (e) {
      // Si no tiene campo 'nombre', obtener sin ordenar
      try {
        final snap = await _ref.get();
        return snap.docs.map(fromFirestore).toList();
      } catch (e2) {
        throw Exception('Error al obtener todos de $coleccion: $e2');
      }
    }
  }

  // ── LEER TODOS — STREAM EN TIEMPO REAL ────────────────────────────
  Stream<List<T>> escucharTodos() {
    return _ref.snapshots().map(
          (snap) => snap.docs.map(fromFirestore).toList(),
        );
  }

  // ── LEER CON FILTRO ────────────────────────────────────────────────
  Future<List<T>> obtenerPorCampo(String campo, dynamic valor) async {
    try {
      final snap = await _ref.where(campo, isEqualTo: valor).get();
      return snap.docs.map(fromFirestore).toList();
    } catch (e) {
      throw Exception('Error al filtrar $coleccion por $campo: $e');
    }
  }

  // ── STREAM CON FILTRO ──────────────────────────────────────────────
  Stream<List<T>> escucharPorCampo(String campo, dynamic valor) {
    return _ref
        .where(campo, isEqualTo: valor)
        .snapshots()
        .map((snap) => snap.docs.map(fromFirestore).toList());
  }

  // ── ACTUALIZAR ─────────────────────────────────────────────────────
  Future<void> actualizar(String id, T item) async {
    try {
      await _ref.doc(id).update(toFirestore(item));
    } catch (e) {
      throw Exception('Error al actualizar en $coleccion: $e');
    }
  }

  // ── ACTUALIZAR CAMPOS ESPECÍFICOS ─────────────────────────────────
  Future<void> actualizarCampos(String id, Map<String, dynamic> campos) async {
    try {
      await _ref.doc(id).update(campos);
    } catch (e) {
      throw Exception('Error al actualizar campos en $coleccion: $e');
    }
  }

  // ── ELIMINAR ───────────────────────────────────────────────────────
  Future<void> eliminar(String id) async {
    try {
      await _ref.doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar de $coleccion: $e');
    }
  }

  // ── DESACTIVAR (soft delete) ───────────────────────────────────────
  Future<void> desactivar(String id) async {
    try {
      await _ref.doc(id).update({'activo': false});
    } catch (e) {
      throw Exception('Error al desactivar en $coleccion: $e');
    }
  }

  // ── CONTAR ─────────────────────────────────────────────────────────
  Future<int> contar() async {
    try {
      final snap = await _ref.count().get();
      return snap.count ?? 0;
    } catch (e) {
      throw Exception('Error al contar en $coleccion: $e');
    }
  }

  // ── PAGINACIÓN ─────────────────────────────────────────────────────
  Future<List<T>> obtenerPaginado({
    int limite = 20,
    DocumentSnapshot? ultimoDocumento,
  }) async {
    try {
      Query query = _ref.limit(limite);
      if (ultimoDocumento != null) {
        query = query.startAfterDocument(ultimoDocumento);
      }
      final snap = await query.get();
      return snap.docs.map(fromFirestore).toList();
    } catch (e) {
      throw Exception('Error al paginar $coleccion: $e');
    }
  }
}

// ─── Nombres de colecciones ────────────────────────────────────────────────
class Colecciones {
  Colecciones._();
  static const String usuarios = 'usuarios';
  static const String clientes = 'clientes';
  static const String mascotas = 'mascotas';
  static const String especies = 'especies';
  static const String razas = 'razas';
  static const String productos = 'productos';
  static const String categorias = 'categorias';
  static const String proveedores = 'proveedores';
  static const String inventario = 'inventario';
  static const String ventas = 'ventas';
  static const String compras = 'compras';
  static const String gastos = 'gastos';
  static const String pagos = 'pagos';
  static const String citas = 'citas';
  static const String consultas = 'consultas';
  static const String tratamientos = 'tratamientos';
  static const String empleados = 'empleados';
  static const String horarios = 'horarios';
  static const String configuracion = 'configuracion';
}
