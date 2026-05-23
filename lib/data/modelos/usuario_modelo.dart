import 'package:cloud_firestore/cloud_firestore.dart';

enum RolUsuario { admin, empleado, cliente }

class UsuarioModelo {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final RolUsuario rol;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime? ultimoAcceso;

  const UsuarioModelo({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.rol,
    required this.activo,
    required this.fechaCreacion,
    this.ultimoAcceso,
  });

  String get nombreCompleto => '$nombre $apellido';

  String get rolTexto {
    switch (rol) {
      case RolUsuario.admin:
        return 'Administrador';
      case RolUsuario.empleado:
        return 'Empleado';
      case RolUsuario.cliente:
        return 'Cliente';
    }
  }

  factory UsuarioModelo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UsuarioModelo(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'] ?? '',
      email: data['email'] ?? '',
      telefono: data['telefono'] ?? '',
      rol: RolUsuario.values.firstWhere(
        (r) => r.name == (data['rol'] ?? 'cliente'),
        orElse: () => RolUsuario.cliente,
      ),
      activo: data['activo'] ?? true,
      fechaCreacion:
          (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ultimoAcceso: (data['ultimoAcceso'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
      'rol': rol.name,
      'activo': activo,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'ultimoAcceso':
          ultimoAcceso != null ? Timestamp.fromDate(ultimoAcceso!) : null,
    };
  }

  UsuarioModelo copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    RolUsuario? rol,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? ultimoAcceso,
  }) {
    return UsuarioModelo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      ultimoAcceso: ultimoAcceso ?? this.ultimoAcceso,
    );
  }
}
