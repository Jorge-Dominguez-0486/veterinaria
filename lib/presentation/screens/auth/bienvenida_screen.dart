import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';

class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo / Ilustración
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: AppColors.primario.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pets,
                  size: 72,
                  color: AppColors.primario,
                ),
              ),

              const SizedBox(height: 24),

              // Nombre de la app
              Text(
                'Polivet Pro',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 32,
                      color: AppColors.primario,
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 10),

              Text(
                'Tu tienda y clínica veterinaria\nen un solo lugar',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textoMedio,
                      height: 1.5,
                    ),
              ),

              const Spacer(flex: 3),

              // Botones
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRutas.login),
                  child: const Text('Iniciar Sesión'),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go(AppRutas.registro),
                  child: const Text('Crear Cuenta'),
                ),
              ),

              const Spacer(),

              Text(
                'Polivet Pro © 2025',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textoClaro,
                      fontSize: 12,
                    ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
