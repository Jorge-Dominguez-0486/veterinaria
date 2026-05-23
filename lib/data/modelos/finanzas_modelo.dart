import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Item de venta/compra ──────────────────────────────────────────────────
class ItemTransaccion {
  final String productoId;
  final String nombreProducto;
  final int cantidad;
  final double precioUnitario;

  const ItemTransaccion({
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
  });

  double get subtotal => cantidad * precioUnitario;

  factory ItemTransaccion.fromMap(Map<String, dynamic> m) => ItemTransaccion(
        productoId: m['productoId'] ?? '',
        nombreProducto: m['nombreProducto'] ?? '',
        cantidad: m['cantidad'] ?? 0,
        precioUnitario: (m['precioUnitario'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'productoId': productoId,
        'nombreProducto': nombreProducto,
        'cantidad': cantidad,
        'precioUnitario': precioUnitario,
      };
}

// ─── Venta ─────────────────────────────────────────────────────────────────
class VentaModelo {
  final String id;
  final String clienteId;
  final String empleadoId;
  final List<ItemTransaccion> items;
  final double total;
  final double descuento;
  final String metodoPago; // efectivo | tarjeta | transferencia
  final String estado; // pendiente | pagada | cancelada
  final DateTime fecha;
  final String notas;

  const VentaModelo({
    required this.id,
    required this.clienteId,
    required this.empleadoId,
    required this.items,
    required this.total,
    required this.descuento,
    required this.metodoPago,
    required this.estado,
    required this.fecha,
    required this.notas,
  });

  double get totalConDescuento => total - descuento;

  factory VentaModelo.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return VentaModelo(
      id: doc.id,
      clienteId: d['clienteId'] ?? '',
      empleadoId: d['empleadoId'] ?? '',
      items: (d['items'] as List<dynamic>? ?? [])
          .map((i) => ItemTransaccion.fromMap(i as Map<String, dynamic>))
          .toList(),
      total: (d['total'] ?? 0).toDouble(),
      descuento: (d['descuento'] ?? 0).toDouble(),
      metodoPago: d['metodoPago'] ?? 'efectivo',
      estado: d['estado'] ?? 'pendiente',
      fecha: (d['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notas: d['notas'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'clienteId': clienteId,
        'empleadoId': empleadoId,
        'items': items.map((i) => i.toMap()).toList(),
        'total': total,
        'descuento': descuento,
        'metodoPago': metodoPago,
        'estado': estado,
        'fecha': Timestamp.fromDate(fecha),
        'notas': notas,
      };

  VentaModelo copyWith({
    String? id,
    String? clienteId,
    String? empleadoId,
    List<ItemTransaccion>? items,
    double? total,
    double? descuento,
    String? metodoPago,
    String? estado,
    DateTime? fecha,
    String? notas,
  }) =>
      VentaModelo(
        id: id ?? this.id,
        clienteId: clienteId ?? this.clienteId,
        empleadoId: empleadoId ?? this.empleadoId,
        items: items ?? this.items,
        total: total ?? this.total,
        descuento: descuento ?? this.descuento,
        metodoPago: metodoPago ?? this.metodoPago,
        estado: estado ?? this.estado,
        fecha: fecha ?? this.fecha,
        notas: notas ?? this.notas,
      );
}

// ─── Compra ────────────────────────────────────────────────────────────────
class CompraModelo {
  final String id;
  final String proveedorId;
  final String empleadoId;
  final List<ItemTransaccion> items;
  final double total;
  final String estado; // pendiente | recibida | cancelada
  final DateTime fecha;
  final String notas;

  const CompraModelo({
    required this.id,
    required this.proveedorId,
    required this.empleadoId,
    required this.items,
    required this.total,
    required this.estado,
    required this.fecha,
    required this.notas,
  });

  factory CompraModelo.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CompraModelo(
      id: doc.id,
      proveedorId: d['proveedorId'] ?? '',
      empleadoId: d['empleadoId'] ?? '',
      items: (d['items'] as List<dynamic>? ?? [])
          .map((i) => ItemTransaccion.fromMap(i as Map<String, dynamic>))
          .toList(),
      total: (d['total'] ?? 0).toDouble(),
      estado: d['estado'] ?? 'pendiente',
      fecha: (d['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notas: d['notas'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'proveedorId': proveedorId,
        'empleadoId': empleadoId,
        'items': items.map((i) => i.toMap()).toList(),
        'total': total,
        'estado': estado,
        'fecha': Timestamp.fromDate(fecha),
        'notas': notas,
      };

  CompraModelo copyWith({
    String? id,
    String? proveedorId,
    String? empleadoId,
    List<ItemTransaccion>? items,
    double? total,
    String? estado,
    DateTime? fecha,
    String? notas,
  }) =>
      CompraModelo(
        id: id ?? this.id,
        proveedorId: proveedorId ?? this.proveedorId,
        empleadoId: empleadoId ?? this.empleadoId,
        items: items ?? this.items,
        total: total ?? this.total,
        estado: estado ?? this.estado,
        fecha: fecha ?? this.fecha,
        notas: notas ?? this.notas,
      );
}

// ─── Gasto ─────────────────────────────────────────────────────────────────
class GastoModelo {
  final String id;
  final String concepto;
  final String categoria; // servicios | nomina | mantenimiento | otros
  final double monto;
  final DateTime fecha;
  final String empleadoId;
  final String notas;

  const GastoModelo({
    required this.id,
    required this.concepto,
    required this.categoria,
    required this.monto,
    required this.fecha,
    required this.empleadoId,
    required this.notas,
  });

  factory GastoModelo.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return GastoModelo(
      id: doc.id,
      concepto: d['concepto'] ?? '',
      categoria: d['categoria'] ?? 'otros',
      monto: (d['monto'] ?? 0).toDouble(),
      fecha: (d['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      empleadoId: d['empleadoId'] ?? '',
      notas: d['notas'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'concepto': concepto,
        'categoria': categoria,
        'monto': monto,
        'fecha': Timestamp.fromDate(fecha),
        'empleadoId': empleadoId,
        'notas': notas,
      };

  GastoModelo copyWith({
    String? id,
    String? concepto,
    String? categoria,
    double? monto,
    DateTime? fecha,
    String? empleadoId,
    String? notas,
  }) =>
      GastoModelo(
        id: id ?? this.id,
        concepto: concepto ?? this.concepto,
        categoria: categoria ?? this.categoria,
        monto: monto ?? this.monto,
        fecha: fecha ?? this.fecha,
        empleadoId: empleadoId ?? this.empleadoId,
        notas: notas ?? this.notas,
      );
}

// ─── Pago ──────────────────────────────────────────────────────────────────
class PagoModelo {
  final String id;
  final String referenciaId; // id de venta o compra
  final String tipo; // venta | compra
  final double monto;
  final String metodoPago;
  final DateTime fecha;
  final String notas;

  const PagoModelo({
    required this.id,
    required this.referenciaId,
    required this.tipo,
    required this.monto,
    required this.metodoPago,
    required this.fecha,
    required this.notas,
  });

  factory PagoModelo.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PagoModelo(
      id: doc.id,
      referenciaId: d['referenciaId'] ?? '',
      tipo: d['tipo'] ?? 'venta',
      monto: (d['monto'] ?? 0).toDouble(),
      metodoPago: d['metodoPago'] ?? 'efectivo',
      fecha: (d['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notas: d['notas'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'referenciaId': referenciaId,
        'tipo': tipo,
        'monto': monto,
        'metodoPago': metodoPago,
        'fecha': Timestamp.fromDate(fecha),
        'notas': notas,
      };

  PagoModelo copyWith({
    String? id,
    String? referenciaId,
    String? tipo,
    double? monto,
    String? metodoPago,
    DateTime? fecha,
    String? notas,
  }) =>
      PagoModelo(
        id: id ?? this.id,
        referenciaId: referenciaId ?? this.referenciaId,
        tipo: tipo ?? this.tipo,
        monto: monto ?? this.monto,
        metodoPago: metodoPago ?? this.metodoPago,
        fecha: fecha ?? this.fecha,
        notas: notas ?? this.notas,
      );
}
