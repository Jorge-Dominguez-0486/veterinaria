import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/usuario_modelo.dart';

class AuthRepositorio {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _coleccion = 'usuarios';

  // ── Stream del usuario autenticado ─────────────────────────────────
  Stream<User?> get estadoAuth => _auth.authStateChanges();

  User? get usuarioActual => _auth.currentUser;

  // ── Obtener datos del usuario desde Firestore ──────────────────────
  Future<UsuarioModelo?> obtenerUsuario(String uid) async {
    try {
      final doc = await _db.collection(_coleccion).doc(uid).get();
      if (!doc.exists) return null;
      return UsuarioModelo.fromFirestore(doc);
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  // ── Iniciar sesión ─────────────────────────────────────────────────
  Future<UsuarioModelo> iniciarSesion({
    required String email,
    required String contrasena,
  }) async {
    try {
      final credencial = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: contrasena,
      );

      final uid = credencial.user!.uid;

      // Actualizar último acceso
      await _db.collection(_coleccion).doc(uid).update({
        'ultimoAcceso': Timestamp.fromDate(DateTime.now()),
      });

      final usuario = await obtenerUsuario(uid);
      if (usuario == null)
        throw Exception('Usuario no encontrado en Firestore');
      return usuario;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mensajeError(e.code));
    }
  }

  // ── Registrar nuevo usuario ────────────────────────────────────────
  Future<UsuarioModelo> registrar({
    required String nombre,
    required String apellido,
    required String email,
    required String telefono,
    required String contrasena,
    RolUsuario rol = RolUsuario.cliente,
  }) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: contrasena,
      );

      final uid = credencial.user!.uid;

      final nuevoUsuario = UsuarioModelo(
        id: uid,
        nombre: nombre.trim(),
        apellido: apellido.trim(),
        email: email.trim(),
        telefono: telefono.trim(),
        rol: rol,
        activo: true,
        fechaCreacion: DateTime.now(),
        ultimoAcceso: DateTime.now(),
      );

      await _db.collection(_coleccion).doc(uid).set(nuevoUsuario.toFirestore());

      // Actualizar displayName en Firebase Auth
      await credencial.user!.updateDisplayName('$nombre $apellido');

      return nuevoUsuario;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mensajeError(e.code));
    }
  }

  // ── Cerrar sesión ──────────────────────────────────────────────────
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  // ── Recuperar contraseña ───────────────────────────────────────────
  Future<void> recuperarContrasena(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_mensajeError(e.code));
    }
  }

  // ── Mensajes de error en español ──────────────────────────────────
  String _mensajeError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con ese correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'El correo ya está registrado.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'invalid-email':
        return 'El correo no tiene un formato válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde.';
      default:
        return 'Error de autenticación. Intenta de nuevo.';
    }
  }
}
