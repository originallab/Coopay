import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/comercio.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/comercios_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../auth/landing_screen.dart';
import '../perfil/ayuda_soporte_comercio_screen.dart';
import '../perfil/cambiar_pin_screen.dart';
import 'corte_caja_screen.dart';
import 'datos_fiscales_screen.dart';
import 'gestion_sucursales_screen.dart';
import 'supervisores_screen.dart';

/// Hub de administración del comercio. A diferencia del prototipo original
/// (3 vistas intercambiables Administrador/Cajero/Supervisor), aquí solo hay
/// una vista — el rol Cajero no existe en este modelo — y "Cerrar sesión"
/// cierra la ÚNICA sesión de la app (socio + comercio comparten sesión).
class PerfilComercioScreen extends StatefulWidget {
  final String comercioId;
  const PerfilComercioScreen({super.key, required this.comercioId});

  @override
  State<PerfilComercioScreen> createState() => _PerfilComercioScreenState();
}

class _PerfilComercioScreenState extends State<PerfilComercioScreen> {
  late Future<ComercioDetalle> _comercioFuture;

  @override
  void initState() {
    super.initState();
    _comercioFuture = context.read<ComerciosRepository>().obtenerComercio(widget.comercioId);
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
        child: FutureBuilder<ComercioDetalle>(
          future: _comercioFuture,
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final comercio = snap.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.navy),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text('Perfil del comercio', style: AppTheme.display(size: 19)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text(
                          comercio.nombreComercial.isEmpty ? '?' : comercio.nombreComercial[0].toUpperCase(),
                          style: AppTheme.display(size: 22, color: AppColors.cream),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(comercio.nombreComercial, style: AppTheme.body(size: 15, weight: FontWeight.w700)),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text('Administrador',
                                  style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.greenDark)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                    decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(13)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.greenDark),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Cuenta receptora: ${comercio.institucionReceptora}. Los retiros de este dinero se hacen como una Transferencia normal desde esa cuenta, en la pestaña Cuentas.',
                            style: AppTheme.body(size: 11, color: AppColors.greenDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text('NEGOCIO', style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
                  const SizedBox(height: 8),
                  _Opcion(
                    icon: Icons.receipt_long_rounded,
                    label: 'Datos del comercio',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DatosFiscalesScreen(comercioId: comercio.id))),
                  ),
                  _Opcion(
                    icon: Icons.storefront_outlined,
                    label: 'Sucursales',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GestionSucursalesScreen(comercio: comercio))),
                  ),
                  _Opcion(
                    icon: Icons.point_of_sale_rounded,
                    label: 'Corte de caja',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CorteCajaScreen(comercio: comercio))),
                  ),
                  _Opcion(
                    icon: Icons.people_alt_rounded,
                    label: 'Supervisores',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => SupervisoresScreen(comercioId: comercio.id, comercioNombre: comercio.nombreComercial),
                    )),
                  ),
                  const SizedBox(height: 18),
                  Text('CUENTA', style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
                  const SizedBox(height: 8),
                  _Opcion(
                    icon: Icons.password_rounded,
                    label: 'PIN de seguridad',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CambiarPinScreen())),
                  ),
                  _Opcion(
                    icon: Icons.help_outline_rounded,
                    label: 'Ayuda y soporte',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AyudaSoporteComercioScreen())),
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
            );
          },
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
