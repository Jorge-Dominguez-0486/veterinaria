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
      // Verificar que el documento tenga campos esenciales
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null || !data.containsKey('nombre')) return null;
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
      final firebaseUser = credencial.user!;

      // Verificar si existe un documento completo en Firestore
      UsuarioModelo? usuario = await obtenerUsuario(uid);

      if (usuario == null) {
        // El usuario existe en Auth pero no tiene documento completo.
        // Crear documento con datos disponibles de Firebase Auth.
        final nombreParts = (firebaseUser.displayName ?? '').split(' ');
        usuario = UsuarioModelo(
          id: uid,
          nombre: nombreParts.isNotEmpty && nombreParts.first.isNotEmpty
              ? nombreParts.first
              : 'Usuario',
          apellido:
              nombreParts.length > 1 ? nombreParts.sublist(1).join(' ') : '',
          email: firebaseUser.email ?? email.trim(),
          telefono: firebaseUser.phoneNumber ?? '',
          rol: RolUsuario.cliente,
          activo: true,
          fechaCreacion: DateTime.now(),
          ultimoAcceso: DateTime.now(),
        );
        await _db.collection(_coleccion).doc(uid).set(usuario.toFirestore());
      } else {
        // Documento completo existe: solo actualizar último acceso
        await _db.collection(_coleccion).doc(uid).update({
          'ultimoAcceso': Timestamp.fromDate(DateTime.now()),
        });
      }

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

      // Si el rol es cliente, crear también documento en la colección 'clientes'
      // para que aparezca en el panel de administración
      if (rol == RolUsuario.cliente) {
        await _db.collection('clientes').doc(uid).set({
          'nombre': nombre.trim(),
          'apellido': apellido.trim(),
          'email': email.trim(),
          'telefono': telefono.trim(),
          'direccion': '',
          'activo': true,
          'fechaRegistro': Timestamp.fromDate(DateTime.now()),
          'usuarioId': uid,
        });
      }

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
