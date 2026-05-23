import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Cita ──────────────────────────────────────────────────────────────────
class CitaModelo {
  final String id;
  final String mascotaId;
  final String clienteId;
  final String empleadoId; // veterinario
  final DateTime fechaHora;
  final String motivo;
  final String estado; // programada | completada | cancelada
  final String notas;

  const CitaModelo({
    required this.id,
    required this.mascotaId,
    required this.clienteId,
    required this.empleadoId,
    required this.fechaHora,
    required this.motivo,
    required this.estado,
    required this.notas,
  });

  factory CitaModelo.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CitaModelo(
      id: doc.id,
      mascotaId: d['mascotaId'] ?? '',
      clienteId: d['clienteId'] ?? '',
      empleadoId: d['empleadoId'] ?? '',
      fechaHora: (d['fechaHora'] as Timestamp?)?.toDate() ?? DateTime.now(),
      motivo: d['motivo'] ?? '',
      estado: d['estado'] ?? 'programada',
      notas: d['notas'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'mascotaId': mascotaId,
        'clienteId': clienteId,
        'empleadoId': empleadoId,
        'fechaHora': Timestamp.fromDate(fechaHora),
        'motivo': motivo,
        'estado': estado,
        'notas': notas,
      };

  CitaModelo copyWith({
    String? id,
    String? mascotaId,
    String? clienteId,
    String? empleadoId,
    DateTime? fechaHora,
    String? motivo,
    String? estado,
    String? notas,
  }) =>
      CitaModelo(
        id: id ?? this.id,
        mascotaId: mascotaId ?? this.mascotaId,
        clienteId: clienteId ?? this.clienteId,
        empleadoId: empleadoId ?? this.empleadoId,
        fechaHora: fechaHora ?? this.fechaHora,
        motivo: motivo ?? this.motivo,
        estado: estado ?? this.estado,
        notas: notas ?? this.notas,
      );
}

// ─── Consulta ──────────────────────────────────────────────────────────────
class ConsultaModelo {
  final String id;
  final String citaId;
  final String mascotaId;
  final String empleadoId;
  final double peso;
  final double temperatura;
  final String sintomas;
  final String diagnostico;
  final String tratamiento;
  final double costo;
  final DateTime fecha;

  const ConsultaModelo({
    required this.id,
    required this.citaId,
    required this.mascotaId,
    required this.empleadoId,
    required this.peso,
    required this.temperatura,
    required this.sintomas,
    required this.diagnostico,
    required this.tratamiento,
    required this.costo,
    required this.fecha,
  });

  factory ConsultaModelo.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ConsultaModelo(
      id: doc.id,
      citaId: d['citaId'] ?? '',
      mascotaId: d['mascotaId'] ?? '',
      empleadoId: d['empleadoId'] ?? '',
      peso: (d['peso'] ?? 0).toDouble(),
      temperatura: (d['temperatura'] ?? 38.5).toDouble(),
      sintomas: d['sintomas'] ?? '',
      diagnostico: d['diagnostico'] ?? '',
      tratamiento: d['tratamiento'] ?? '',
      costo: (d['costo'] ?? 0).toDouble(),
      fecha: (d['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'citaId': citaId,
        'mascotaId': mascotaId,
        'empleadoId': empleadoId,
        'peso': peso,
        'temperatura': temperatura,
        'sintomas': sintomas,
        'diagnostico': diagnostico,
        'tratamiento': tratamiento,
        'costo': costo,
        'fecha': Timestamp.fromDate(fecha),
      };

  ConsultaModelo copyWith({
    String? id,
    String? citaId,
    String? mascotaId,
    String? empleadoId,
    double? peso,
    double? temperatura,
    String? sintomas,
    String? diagnostico,
    String? tratamiento,
    double? costo,
    DateTime? fecha,
  }) =>
      ConsultaModelo(
        id: id ?? this.id,
        citaId: citaId ?? this.citaId,
        mascotaId: mascotaId ?? this.mascotaId,
        empleadoId: empleadoId ?? this.empleadoId,
        peso: peso ?? this.peso,
        temperatura: temperatura ?? this.temperatura,
        sintomas: sintomas ?? this.sintomas,
        diagnostico: diagnostico ?? this.diagnostico,
        tratamiento: tratamiento ?? this.tratamiento,
        costo: costo ?? this.costo,
        fecha: fecha ?? this.fecha,
      );
}

// ─── Tratamiento ───────────────────────────────────────────────────────────
class TratamientoModelo {
  final String id;
  final String consultaId;
  final String mascotaId;
  final String nombre;
  final String descripcion;
  final String medicamentos;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String estado; // activo | completado | suspendido
  final double costo;

  const TratamientoModelo({
    required this.id,
    required this.consultaId,
    required this.mascotaId,
    required this.nombre,
    required this.descripcion,
    required this.medicamentos,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    required this.costo,
  });

  factory TratamientoModelo.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TratamientoModelo(
      id: doc.id,
      consultaId: d['consultaId'] ?? '',
      mascotaId: d['mascotaId'] ?? '',
      nombre: d['nombre'] ?? '',
      descripcion: d['descripcion'] ?? '',
      medicamentos: d['medicamentos'] ?? '',
      fechaInicio: (d['fechaInicio'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaFin: (d['fechaFin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estado: d['estado'] ?? 'activo',
      costo: (d['costo'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'consultaId': consultaId,
        'mascotaId': mascotaId,
        'nombre': nombre,
        'descripcion': descripcion,
        'medicamentos': medicamentos,
        'fechaInicio': Timestamp.fromDate(fechaInicio),
        'fechaFin': Timestamp.fromDate(fechaFin),
        'estado': estado,
        'costo': costo,
      };

  TratamientoModelo copyWith({
    String? id,
    String? consultaId,
    String? mascotaId,
    String? nombre,
    String? descripcion,
    String? medicamentos,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? estado,
    double? costo,
  }) =>
      TratamientoModelo(
        id: id ?? this.id,
        consultaId: consultaId ?? this.consultaId,
        mascotaId: mascotaId ?? this.mascotaId,
        nombre: nombre ?? this.nombre,
        descripcion: descripcion ?? this.descripcion,
        medicamentos: medicamentos ?? this.medicamentos,
        fechaInicio: fechaInicio ?? this.fechaInicio,
        fechaFin: fechaFin ?? this.fechaFin,
        estado: estado ?? this.estado,
        costo: costo ?? this.costo,
      );
}
