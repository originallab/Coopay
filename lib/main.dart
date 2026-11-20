import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories/ajustes_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/comercios_repository.dart';
import 'repositories/cuentas_repository.dart';
import 'repositories/dispositivos_repository.dart';
import 'repositories/notificaciones_repository.dart';
import 'repositories/vinculacion_repository.dart';
import 'routing/route_observer.dart';
import 'screens/auth/landing_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const CooPayApp());
}

class CooPayApp extends StatelessWidget {
  const CooPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Repositorios mock mientras no existe el backend real — ver
    // config/app_config.dart y el README de este proyecto para el plan de
    // cómo se cambia a las implementaciones HTTP cuando el Swagger esté listo.
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => MockAuthRepository()),
        Provider<CuentasRepository>(create: (_) => MockCuentasRepository()),
        Provider<ComerciosRepository>(create: (_) => MockComerciosRepository()),
        Provider<NotificacionesRepository>(create: (_) => MockNotificacionesRepository()),
        Provider<VinculacionRepository>(create: (_) => MockVinculacionRepository()),
        Provider<AjustesRepository>(create: (_) => MockAjustesRepository()),
        Provider<DispositivosRepository>(create: (_) => MockDispositivosRepository()),
      ],
      child: MaterialApp(
        title: 'CooPay',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        navigatorObservers: [routeObserver],
        home: const LandingScreen(),
      ),
    );
  }
}
