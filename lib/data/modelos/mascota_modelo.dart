import 'package:cloud_firestore/cloud_firestore.dart';

class MascotaModelo {
  final String id;
  final String nombre;
  final String clienteId;
  final String especieId;
  final String razaId;
  final String sexo; // 'macho' | 'hembra'
  final DateTime fechaNacimiento;
  final double peso;
  final String color;
  final String observaciones;
  final bool activo;
  final DateTime fechaRegistro;

  const MascotaModelo({
    required this.id,
    required this.nombre,
    required this.clienteId,
    required this.especieId,
    required this.razaId,
    required this.sexo,
    required this.fechaNacimiento,
    required this.peso,
    required this.color,
    required this.observaciones,
    required this.activo,
    required this.fechaRegistro,
  });

  int get edadAnios {
    final hoy = DateTime.now();
    int anios = hoy.year - fechaNacimiento.year;
    if (hoy.month < fechaNacimiento.month ||
        (hoy.month == fechaNacimiento.month && hoy.day < fechaNacimiento.day)) {
      anios--;
    }
    return anios;
  }

  factory MascotaModelo.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MascotaModelo(
      id: doc.id,
      nombre: d['nombre'] ?? '',
      clienteId: d['clienteId'] ?? '',
      especieId: d['especieId'] ?? '',
      razaId: d['razaId'] ?? '',
      sexo: d['sexo'] ?? 'macho',
      fechaNacimiento:
          (d['fechaNacimiento'] as Timestamp?)?.toDate() ?? DateTime.now(),
      peso: (d['peso'] ?? 0).toDouble(),
      color: d['color'] ?? '',
      observaciones: d['observaciones'] ?? '',
      activo: d['activo'] ?? true,
      fechaRegistro:
          (d['fechaRegistro'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nombre': nombre,
        'clienteId': clienteId,
        'especieId': especieId,
        'razaId': razaId,
        'sexo': sexo,
        'fechaNacimiento': Timestamp.fromDate(fechaNacimiento),
        'peso': peso,
        'color': color,
        'observaciones': observaciones,
        'activo': activo,
        'fechaRegistro': Timestamp.fromDate(fechaRegistro),
      };

  MascotaModelo copyWith({
    String? id,
    String? nombre,
    String? clienteId,
    String? especieId,
    String? razaId,
    String? sexo,
    DateTime? fechaNacimiento,
    double? peso,
    String? color,
    String? observaciones,
    bool? activo,
    DateTime? fechaRegistro,
  }) =>
      MascotaModelo(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        clienteId: clienteId ?? this.clienteId,
        especieId: especieId ?? this.especieId,
        razaId: razaId ?? this.razaId,
        sexo: sexo ?? this.sexo,
        fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
        peso: peso ?? this.peso,
        color: color ?? this.color,
        observaciones: observaciones ?? this.observaciones,
        activo: activo ?? this.activo,
        fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      );
}
