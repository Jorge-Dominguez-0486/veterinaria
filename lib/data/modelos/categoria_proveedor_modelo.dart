import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Categoría de productos ────────────────────────────────────────────────
class CategoriaModelo {
  final String id;
  final String nombre;
  final String descripcion;
  final bool activo;

  const CategoriaModelo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.activo,
  });

  factory CategoriaModelo.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CategoriaModelo(
      id: doc.id,
      nombre: d['nombre'] ?? '',
      descripcion: d['descripcion'] ?? '',
      activo: d['activo'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'activo': activo,
      };

  CategoriaModelo copyWith(
          {String? id, String? nombre, String? descripcion, bool? activo}) =>
      CategoriaModelo(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        descripcion: descripcion ?? this.descripcion,
        activo: activo ?? this.activo,
      );
}

// ─── Proveedor ─────────────────────────────────────────────────────────────
class ProveedorModelo {
  final String id;
  final String nombre;
  final String contacto;
  final String telefono;
  final String email;
  final String direccion;
  final bool activo;

  const ProveedorModelo({
    required this.id,
    required this.nombre,
    required this.contacto,
    required this.telefono,
    required this.email,
    required this.direccion,
    required this.activo,
  });

  factory ProveedorModelo.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ProveedorModelo(
      id: doc.id,
      nombre: d['nombre'] ?? '',
      contacto: d['contacto'] ?? '',
      telefono: d['telefono'] ?? '',
      email: d['email'] ?? '',
      direccion: d['direccion'] ?? '',
      activo: d['activo'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nombre': nombre,
        'contacto': contacto,
        'telefono': telefono,
        'email': email,
        'direccion': direccion,
        'activo': activo,
      };

  ProveedorModelo copyWith({
    String? id,
    String? nombre,
    String? contacto,
    String? telefono,
    String? email,
    String? direccion,
    bool? activo,
  }) =>
      ProveedorModelo(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        contacto: contacto ?? this.contacto,
        telefono: telefono ?? this.telefono,
        email: email ?? this.email,
        direccion: direccion ?? this.direccion,
        activo: activo ?? this.activo,
      );
}
