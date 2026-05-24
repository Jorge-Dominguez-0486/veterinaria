import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

// Providers
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/clientes_mascotas_provider.dart';
import 'presentation/providers/catalogos_provider.dart';
import 'presentation/providers/inventario_provider.dart';
import 'presentation/providers/veterinaria_provider.dart';
import 'presentation/providers/finanzas_provider.dart';
import 'presentation/providers/rrhh_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PolivetApp());
}

class PolivetApp extends StatelessWidget {
  const PolivetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProveedorAuth()),
        ChangeNotifierProvider(create: (_) => ProveedorClientes()),
        ChangeNotifierProvider(create: (_) => ProveedorMascotas()),
        ChangeNotifierProvider(create: (_) => ProveedorCatalogos()),
        ChangeNotifierProvider(create: (_) => ProveedorInventario()),
        ChangeNotifierProvider(create: (_) => ProveedorVeterinaria()),
        ChangeNotifierProvider(create: (_) => ProveedorFinanzas()),
        ChangeNotifierProvider(create: (_) => ProveedorRRHH()),
      ],
      // Builder accede a los providers ya registrados para poder
      // pasarle ProveedorAuth al router como refreshListenable.
      child: Builder(
        builder: (context) {
          final auth = context.read<ProveedorAuth>();
          return MaterialApp.router(
            title: 'Polivet Pro',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.tema,
            locale: const Locale('es', 'ES'),
            supportedLocales: const [Locale('es', 'ES')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: AppRouter.crearRouter(auth),
          );
        },
      ),
    );
  }
}
