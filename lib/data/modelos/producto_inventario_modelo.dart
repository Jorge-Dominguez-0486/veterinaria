import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Producto ──────────────────────────────────────────────────────────────
class ProductoModelo {
  final String id;
  final String nombre;
  final String descripcion;
  final String categoriaId;
  final String proveedorId;
  final double precioCompra;
  final double precioVenta;
  final String unidadMedida;
  final bool activo;

  const ProductoModelo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoriaId,
    required this.proveedorId,
    required this.precioCompra,
    required this.precioVenta,
    required this.unidadMedida,
    required this.activo,
  });

  double get margenGanancia => precioCompra > 0
      ? ((precioVenta - precioCompra) / precioCompra) * 100
      : 0;

  factory ProductoModelo.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ProductoModelo(
      id: doc.id,
      nombre: d['nombre'] ?? '',
      descripcion: d['descripcion'] ?? '',
      categoriaId: d['categoriaId'] ?? '',
      proveedorId: d['proveedorId'] ?? '',
      precioCompra: (d['precioCompra'] ?? 0).toDouble(),
      precioVenta: (d['precioVenta'] ?? 0).toDouble(),
      unidadMedida: d['unidadMedida'] ?? 'pieza',
      activo: d['activo'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'categoriaId': categoriaId,
        'proveedorId': proveedorId,
        'precioCompra': precioCompra,
        'precioVenta': precioVenta,
        'unidadMedida': unidadMedida,
        'activo': activo,
      };

  ProductoModelo copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? categoriaId,
    String? proveedorId,
    double? precioCompra,
    double? precioVenta,
    String? unidadMedida,
    bool? activo,
  }) =>
      ProductoModelo(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        descripcion: descripcion ?? this.descripcion,
        categoriaId: categoriaId ?? this.categoriaId,
        proveedorId: proveedorId ?? this.proveedorId,
        precioCompra: precioCompra ?? this.precioCompra,
        precioVenta: precioVenta ?? this.precioVenta,
        unidadMedida: unidadMedida ?? this.unidadMedida,
        activo: activo ?? this.activo,
      );
}

// ─── Inventario ────────────────────────────────────────────────────────────
class InventarioModelo {
  final String id;
  final String productoId;
  final int cantidadActual;
  final int cantidadMinima;
  final int cantidadMaxima;
  final DateTime ultimaActualizacion;

  const InventarioModelo({
    required this.id,
    required this.productoId,
    required this.cantidadActual,
    required this.cantidadMinima,
    required this.cantidadMaxima,
    required this.ultimaActualizacion,
  });

  bool get stockBajo => cantidadActual <= cantidadMinima;
  bool get sinStock => cantidadActual == 0;

  factory InventarioModelo.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return InventarioModelo(
      id: doc.id,
      productoId: d['productoId'] ?? '',
      cantidadActual: d['cantidadActual'] ?? 0,
      cantidadMinima: d['cantidadMinima'] ?? 5,
      cantidadMaxima: d['cantidadMaxima'] ?? 100,
      ultimaActualizacion:
          (d['ultimaActualizacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'productoId': productoId,
        'cantidadActual': cantidadActual,
        'cantidadMinima': cantidadMinima,
        'cantidadMaxima': cantidadMaxima,
        'ultimaActualizacion': Timestamp.fromDate(ultimaActualizacion),
      };

  InventarioModelo copyWith({
    String? id,
    String? productoId,
    int? cantidadActual,
    int? cantidadMinima,
    int? cantidadMaxima,
    DateTime? ultimaActualizacion,
  }) =>
      InventarioModelo(
        id: id ?? this.id,
        productoId: productoId ?? this.productoId,
        cantidadActual: cantidadActual ?? this.cantidadActual,
        cantidadMinima: cantidadMinima ?? this.cantidadMinima,
        cantidadMaxima: cantidadMaxima ?? this.cantidadMaxima,
        ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
      );
}
