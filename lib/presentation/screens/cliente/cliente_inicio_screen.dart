// ═══════════════════════════════════════════════════════════════════════════
//  cliente_inicio_screen.dart  —  Pantalla de inicio del cliente
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/modelos/mascota_modelo.dart';
import '../../../data/modelos/veterinaria_modelo.dart';
import '../../providers/auth_provider.dart';
import '../../providers/clientes_mascotas_provider.dart';
import '../../providers/veterinaria_provider.dart';

class ClienteInicioScreen extends StatefulWidget {
  const ClienteInicioScreen({super.key});

  @override
  State<ClienteInicioScreen> createState() => _ClienteInicioScreenState();
}

class _ClienteInicioScreenState extends State<ClienteInicioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<ProveedorAuth>().usuario?.id ?? '';
      context.read<ProveedorMascotas>().cargarMascotasPorCliente(uid);
      context.read<ProveedorVeterinaria>().cargarCitasPorCliente(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ProveedorAuth>();
    final mascotas = context.watch<ProveedorMascotas>();
    final vet = context.watch<ProveedorVeterinaria>();

    final proximas = vet.citas
        .where((c) =>
            c.estado == 'programada' && c.fechaHora.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

    return RefreshIndicator(
      color: AppColors.primario,
      onRefresh: () async {
        final uid = auth.usuario?.id ?? '';
        await Future.wait([
          context.read<ProveedorMascotas>().cargarMascotasPorCliente(uid),
          context.read<ProveedorVeterinaria>().cargarCitasPorCliente(uid),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Banner bienvenida ──────────────────────────────────────
          _BannerBienvenida(nombre: auth.usuario?.nombre ?? ''),
          const SizedBox(height: 20),

          // ── Resumen tarjetas ────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _TarjetaResumen(
                  icono: Icons.pets_rounded,
                  valor: mascotas.mascotas.length.toString(),
                  label: 'Mascotas',
                  color: AppColors.primario,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TarjetaResumen(
                  icono: Icons.calendar_month_rounded,
                  valor: proximas.length.toString(),
                  label: 'Citas\npendientes',
                  color: const Color(0xFF4A90D9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Próximas citas ──────────────────────────────────────────
          const _SeccionTitulo('Próximas citas'),
          const SizedBox(height: 10),
          if (vet.cargando)
            const Center(
                child: CircularProgressIndicator(color: AppColors.primario))
          else if (proximas.isEmpty)
            _MensajeVacio(
              icono: Icons.event_available_rounded,
              texto: 'No tienes citas próximas',
            )
          else
            ...proximas.take(3).map((c) => _TarjetaCitaProxima(
                  cita: c,
                  mascotas: mascotas.mascotas,
                )),

          const SizedBox(height: 24),

          // ── Mis mascotas ────────────────────────────────────────────
          const _SeccionTitulo('Mis mascotas'),
          const SizedBox(height: 10),
          if (mascotas.cargando)
            const Center(
                child: CircularProgressIndicator(color: AppColors.primario))
          else if (mascotas.mascotas.isEmpty)
            _MensajeVacio(
              icono: Icons.pets_rounded,
              texto: 'Aún no tienes mascotas registradas',
            )
          else
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: mascotas.mascotas.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) =>
                    _TarjetaMascotaHorizontal(mascota: mascotas.mascotas[i]),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Widgets locales ────────────────────────────────────────────────────────

class _BannerBienvenida extends StatelessWidget {
  final String nombre;
  const _BannerBienvenida({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primario, AppColors.secundario],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¡Bienvenido, $nombre!',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text('Cuida a tus mascotas con Polivet Pro',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.pets_rounded, color: Colors.white, size: 48),
        ],
      ),
    );
  }
}

class _TarjetaResumen extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String label;
  final Color color;

  const _TarjetaResumen(
      {required this.icono,
      required this.valor,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fondoTarjeta,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borde),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 28),
          const SizedBox(height: 8),
          Text(valor,
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textoMedio)),
        ],
      ),
    );
  }
}

class _SeccionTitulo extends StatelessWidget {
  final String titulo;
  const _SeccionTitulo(this.titulo);

  @override
  Widget build(BuildContext context) {
    return Text(titulo,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textoOscuro));
  }
}

class _TarjetaCitaProxima extends StatelessWidget {
  final CitaModelo cita;
  final List<MascotaModelo> mascotas;
  const _TarjetaCitaProxima({required this.cita, required this.mascotas});

  @override
  Widget build(BuildContext context) {
    final mascota = mascotas.where((m) => m.id == cita.mascotaId).firstOrNull;
    final fmt = DateFormat('EEE d MMM · HH:mm', 'es_ES');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.fondoTarjeta,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF4A90D9).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.calendar_month_rounded,
              color: Color(0xFF4A90D9)),
        ),
        title: Text(cita.motivo,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mascota != null)
              Text('🐾 ${mascota.nombre}',
                  style: const TextStyle(fontSize: 12)),
            Text(fmt.format(cita.fechaHora),
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textoMedio)),
          ],
        ),
        trailing: _ChipEstadoCita(estado: cita.estado),
        isThreeLine: true,
      ),
    );
  }
}

class _TarjetaMascotaHorizontal extends StatelessWidget {
  final MascotaModelo mascota;
  const _TarjetaMascotaHorizontal({required this.mascota});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.fondoTarjeta,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borde),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.secundario.withOpacity(0.2),
            child: const Icon(Icons.pets_rounded,
                color: AppColors.primario, size: 28),
          ),
          const SizedBox(height: 8),
          Text(mascota.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text('${mascota.edadAnios} años',
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textoMedio)),
        ],
      ),
    );
  }
}

class _MensajeVacio extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _MensajeVacio({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.fondoTarjeta,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borde),
      ),
      child: Row(
        children: [
          Icon(icono, color: AppColors.textoClaro, size: 32),
          const SizedBox(width: 12),
          Text(texto,
              style:
                  const TextStyle(color: AppColors.textoMedio, fontSize: 14)),
        ],
      ),
    );
  }
}

class _ChipEstadoCita extends StatelessWidget {
  final String estado;
  const _ChipEstadoCita({required this.estado});

  @override
  Widget build(BuildContext context) {
    final colores = {
      'programada': const Color(0xFF4A90D9),
      'completada': AppColors.exito,
      'cancelada': AppColors.error,
    };
    final color = colores[estado] ?? AppColors.textoMedio;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(estado,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
