import 'package:cloud_firestore/cloud_firestore.dart';

class RazaModelo {
  final String id;
  final String nombre;
  final String especieId;
  final String descripcion;
  final bool activo;

  const RazaModelo({
    required this.id,
    required this.nombre,
    required this.especieId,
    required this.descripcion,
    required this.activo,
  });

  factory RazaModelo.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return RazaModelo(
      id: doc.id,
      nombre: d['nombre'] ?? '',
      especieId: d['especieId'] ?? '',
      descripcion: d['descripcion'] ?? '',
      activo: d['activo'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nombre': nombre,
        'especieId': especieId,
        'descripcion': descripcion,
        'activo': activo,
      };

  RazaModelo copyWith(
          {String? id,
          String? nombre,
          String? especieId,
          String? descripcion,
          bool? activo}) =>
      RazaModelo(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        especieId: especieId ?? this.especieId,
        descripcion: descripcion ?? this.descripcion,
        activo: activo ?? this.activo,
      );
}
