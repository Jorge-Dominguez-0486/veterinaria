import 'package:cloud_firestore/cloud_firestore.dart';

class ClienteModelo {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String direccion;
  final bool activo;
  final DateTime fechaRegistro;

  const ClienteModelo({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.direccion,
    required this.activo,
    required this.fechaRegistro,
  });

  String get nombreCompleto => '$nombre $apellido';

  factory ClienteModelo.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ClienteModelo(
      id: doc.id,
      nombre: d['nombre'] ?? '',
      apellido: d['apellido'] ?? '',
      email: d['email'] ?? '',
      telefono: d['telefono'] ?? '',
      direccion: d['direccion'] ?? '',
      activo: d['activo'] ?? true,
      fechaRegistro:
          (d['fechaRegistro'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'telefono': telefono,
        'direccion': direccion,
        'activo': activo,
        'fechaRegistro': Timestamp.fromDate(fechaRegistro),
      };

  ClienteModelo copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    String? direccion,
    bool? activo,
    DateTime? fechaRegistro,
  }) =>
      ClienteModelo(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        apellido: apellido ?? this.apellido,
        email: email ?? this.email,
        telefono: telefono ?? this.telefono,
        direccion: direccion ?? this.direccion,
        activo: activo ?? this.activo,
        fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      );
}
