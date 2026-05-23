// ═══════════════════════════════════════════════════════════════════════════
//  widgets_comunes.dart  —  Widgets reutilizables del Panel Admin
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

// ── Barra de búsqueda ─────────────────────────────────────────────────────
class BarraBusqueda extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback? onClear;

  const BarraBusqueda({
    super.key,
    required this.controller,
    required this.hint,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, value, __) => value.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    controller.clear();
                    onClear?.call();
                  },
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

// ── Estado vacío ──────────────────────────────────────────────────────────
class EstadoVacio extends StatelessWidget {
  final String mensaje;
  final IconData icono;
  final String? labelBoton;
  final VoidCallback? onBoton;

  const EstadoVacio({
    super.key,
    required this.mensaje,
    this.icono = Icons.inbox_rounded,
    this.labelBoton,
    this.onBoton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 64, color: AppColors.textoClaro),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textoMedio, fontSize: 15),
            ),
            if (labelBoton != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onBoton, child: Text(labelBoton!)),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Indicador de carga ────────────────────────────────────────────────────
class CargandoIndicador extends StatelessWidget {
  const CargandoIndicador({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primario),
    );
  }
}

// ── Chip de estado ────────────────────────────────────────────────────────
class ChipEstado extends StatelessWidget {
  final String estado;
  final Map<String, Color>? colores;

  const ChipEstado({super.key, required this.estado, this.colores});

  @override
  Widget build(BuildContext context) {
    final colorMap = colores ??
        {
          'activo': AppColors.exito,
          'inactivo': AppColors.textoClaro,
          'programada': AppColors.informacion,
          'completada': AppColors.exito,
          'cancelada': AppColors.error,
          'pendiente': AppColors.advertencia,
          'pagada': AppColors.exito,
          'recibida': AppColors.exito,
        };
    final color = colorMap[estado.toLowerCase()] ?? AppColors.textoMedio;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        estado,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Fila de campo de detalle ──────────────────────────────────────────────
class FilaDetalle extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final IconData? icono;

  const FilaDetalle({
    super.key,
    required this.etiqueta,
    required this.valor,
    this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 16, color: AppColors.secundario),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 110,
            child: Text(etiqueta,
                style:
                    const TextStyle(color: AppColors.textoClaro, fontSize: 13)),
          ),
          Expanded(
            child: Text(valor,
                style: const TextStyle(
                    color: AppColors.textoOscuro,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ── Encabezado de formulario modal ────────────────────────────────────────
class _EncabezadoForm extends StatelessWidget {
  final String titulo;
  final VoidCallback onCerrar;

  const _EncabezadoForm({required this.titulo, required this.onCerrar});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(titulo, style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        IconButton(icon: const Icon(Icons.close), onPressed: onCerrar),
      ],
    );
  }
}

// ── Botón guardar ─────────────────────────────────────────────────────────
class _BotonGuardar extends StatelessWidget {
  final bool guardando;
  final bool esEdicion;
  final VoidCallback onGuardar;

  const _BotonGuardar({
    required this.guardando,
    required this.esEdicion,
    required this.onGuardar,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: guardando ? null : onGuardar,
        child: guardando
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(esEdicion ? 'Guardar cambios' : 'Crear'),
      ),
    );
  }
}

// ── Diálogo de confirmación ───────────────────────────────────────────────
Future<bool?> confirmarEliminacion(
  BuildContext context, {
  required String titulo,
  required String descripcion,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.fondo,
      title: Text(titulo,
          style: const TextStyle(
              color: AppColors.textoOscuro, fontWeight: FontWeight.w700)),
      content: Text(descripcion),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
}

// ── SnackBar helpers ──────────────────────────────────────────────────────
void mostrarExito(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(
      children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(mensaje)),
      ],
    ),
    backgroundColor: AppColors.exito,
  ));
}

void mostrarError(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(
      children: [
        const Icon(Icons.error_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(mensaje)),
      ],
    ),
    backgroundColor: AppColors.error,
  ));
}
