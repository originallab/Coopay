import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repositories/auth_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../auth/landing_screen.dart';
import '../comercios/comercios_screen.dart';
import '../cuentas/cuentas_screen.dart';
import '../inicio/inicio_screen.dart';
import '../notificaciones/notificaciones_screen.dart';
import '../pagos/escanear_qr_screen.dart';
import 'ajustes_seguridad_screen.dart';
import 'ayuda_soporte_screen.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  void _onTab(BuildContext context, AppTab tab) {
    if (tab == AppTab.perfil) return;
    Widget destino;
    switch (tab) {
      case AppTab.inicio:
        destino = const InicioScreen();
        break;
      case AppTab.cuentas:
        destino = const CuentasScreen();
        break;
      case AppTab.comercios:
        destino = const ComerciosScreen();
        break;
      default:
        return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => destino));
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    await context.read<AuthRepository>().cerrarSesion();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LandingScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Perfil', style: AppTheme.display(size: 22)),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text('N', style: AppTheme.display(size: 22, color: AppColors.cream)),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nicolás Ibarra', style: AppTheme.body(size: 15, weight: FontWeight.w700)),
                          Text('nicolas.ibarra@example.com', style: AppTheme.body(size: 12, color: AppColors.textDim)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _Opcion(
                    icon: Icons.shield_outlined,
                    label: 'Ajustes y seguridad',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AjustesSeguridadScreen())),
                  ),
                  _Opcion(
                    icon: Icons.help_outline_rounded,
                    label: 'Ayuda y soporte',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AyudaSoporteScreen())),
                  ),
                  _Opcion(
                    icon: Icons.notifications_none_rounded,
                    label: 'Notificaciones',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificacionesScreen())),
                  ),
                  const SizedBox(height: 10),
                  _Opcion(
                    icon: Icons.logout_rounded,
                    label: 'Cerrar sesión',
                    color: AppColors.danger,
                    onTap: () => _cerrarSesion(context),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 4,
              child: BottomNavBar(
                current: AppTab.perfil,
                onTabSelected: (t) => _onTab(context, t),
                onScanTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EscanearQrScreen())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _Opcion({required this.icon, required this.label, required this.onTap, this.color = AppColors.navy});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTheme.body(size: 13.5, weight: FontWeight.w600, color: color))),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textDim),
          ],
        ),
      ),
    );
  }
}
