import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Empleado ──────────────────────────────────────────────────────────────
class EmpleadoModelo {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String puesto; // veterinario | recepcionista | gerente | auxiliar
  final String especialidad;
  final double salario;
  final String horario;
  final bool activo;
  final DateTime fechaContratacion;

  const EmpleadoModelo({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.puesto,
    required this.especialidad,
    required this.salario,
    required this.horario,
    required this.activo,
    required this.fechaContratacion,
  });

  String get nombreCompleto => '$nombre $apellido';

  factory EmpleadoModelo.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return EmpleadoModelo(
      id: doc.id,
      nombre: d['nombre'] ?? '',
      apellido: d['apellido'] ?? '',
      email: d['email'] ?? '',
      telefono: d['telefono'] ?? '',
      puesto: d['puesto'] ?? 'auxiliar',
      especialidad: d['especialidad'] ?? '',
      salario: (d['salario'] ?? 0).toDouble(),
      horario: d['horario'] ?? '',
      activo: d['activo'] ?? true,
      fechaContratacion:
          (d['fechaContratacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'telefono': telefono,
        'puesto': puesto,
        'especialidad': especialidad,
        'salario': salario,
        'horario': horario,
        'activo': activo,
        'fechaContratacion': Timestamp.fromDate(fechaContratacion),
      };

  EmpleadoModelo copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    String? puesto,
    String? especialidad,
    double? salario,
    String? horario,
    bool? activo,
    DateTime? fechaContratacion,
  }) =>
      EmpleadoModelo(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        apellido: apellido ?? this.apellido,
        email: email ?? this.email,
        telefono: telefono ?? this.telefono,
        puesto: puesto ?? this.puesto,
        especialidad: especialidad ?? this.especialidad,
        salario: salario ?? this.salario,
        horario: horario ?? this.horario,
        activo: activo ?? this.activo,
        fechaContratacion: fechaContratacion ?? this.fechaContratacion,
      );
}

// ─── Horario ───────────────────────────────────────────────────────────────
class HorarioModelo {
  final String id;
  final String empleadoId;
  final String diaSemana; // lunes | martes | ... | domingo
  final String horaEntrada;
  final String horaSalida;
  final bool activo;

  const HorarioModelo({
    required this.id,
    required this.empleadoId,
    required this.diaSemana,
    required this.horaEntrada,
    required this.horaSalida,
    required this.activo,
  });

  factory HorarioModelo.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return HorarioModelo(
      id: doc.id,
      empleadoId: d['empleadoId'] ?? '',
      diaSemana: d['diaSemana'] ?? 'lunes',
      horaEntrada: d['horaEntrada'] ?? '08:00',
      horaSalida: d['horaSalida'] ?? '16:00',
      activo: d['activo'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'empleadoId': empleadoId,
        'diaSemana': diaSemana,
        'horaEntrada': horaEntrada,
        'horaSalida': horaSalida,
        'activo': activo,
      };

  HorarioModelo copyWith({
    String? id,
    String? empleadoId,
    String? diaSemana,
    String? horaEntrada,
    String? horaSalida,
    bool? activo,
  }) =>
      HorarioModelo(
        id: id ?? this.id,
        empleadoId: empleadoId ?? this.empleadoId,
        diaSemana: diaSemana ?? this.diaSemana,
        horaEntrada: horaEntrada ?? this.horaEntrada,
        horaSalida: horaSalida ?? this.horaSalida,
        activo: activo ?? this.activo,
      );
}
