import 'package:cloud_firestore/cloud_firestore.dart';

class EspecieModelo {
  final String id;
  final String nombre;
  final String descripcion;
  final bool activo;

  const EspecieModelo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.activo,
  });

  factory EspecieModelo.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return EspecieModelo(
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

  EspecieModelo copyWith(
          {String? id, String? nombre, String? descripcion, bool? activo}) =>
      EspecieModelo(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        descripcion: descripcion ?? this.descripcion,
        activo: activo ?? this.activo,
      );
}
