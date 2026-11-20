import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repositories/ajustes_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../auth/landing_screen.dart';
import 'cambiar_pin_screen.dart';
import 'dispositivos_sesiones_screen.dart';
import 'terminos_privacidad_screen.dart';

class AjustesSeguridadScreen extends StatefulWidget {
  const AjustesSeguridadScreen({super.key});

  @override
  State<AjustesSeguridadScreen> createState() => _AjustesSeguridadScreenState();
}

class _AjustesSeguridadScreenState extends State<AjustesSeguridadScreen> {
  late Future<AjustesSeguridad> _ajustesFuture;
  bool? _bioOverride;
  bool? _ocultarOverride;

  @override
  void initState() {
    super.initState();
    _ajustesFuture = context.read<AjustesRepository>().obtener();
  }

  Future<void> _toggleBio(bool actual) async {
    setState(() => _bioOverride = !actual);
    await context.read<AjustesRepository>().actualizar(biometriaActiva: !actual);
  }

  Future<void> _toggleOcultar(bool actual) async {
    setState(() => _ocultarOverride = !actual);
    await context.read<AjustesRepository>().actualizar(ocultarSaldos: !actual);
  }

  Future<void> _cerrarSesion() async {
    await context.read<AuthRepository>().cerrarSesion();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LandingScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<AjustesSeguridad>(
          future: _ajustesFuture,
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final bio = _bioOverride ?? snap.data!.biometriaActiva;
            final ocultar = _ocultarOverride ?? snap.data!.ocultarSaldos;
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
                      Text('Ajustes y Seguridad', style: AppTheme.display(size: 20)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(18)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: AppColors.cream.withValues(alpha: 0.16), shape: BoxShape.circle),
                          child: const Icon(Icons.shield_outlined, color: AppColors.greenLight, size: 17),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cuenta protegida', style: AppTheme.body(size: 14, weight: FontWeight.w700, color: AppColors.surface)),
                              const SizedBox(height: 2),
                              Text('Tu identidad está verificada y tus datos cifrados.',
                                  style: AppTheme.body(size: 12, color: AppColors.cream.withValues(alpha: 0.6))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('ACCESO Y PRIVACIDAD', style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      children: [
                        _FilaToggle(
                          icon: Icons.fingerprint_rounded,
                          titulo: 'Autenticación biométrica',
                          subtitulo: 'FaceID / Huella digital',
                          activo: bio,
                          onTap: () => _toggleBio(bio),
                        ),
                        _FilaToggle(
                          icon: Icons.visibility_off_outlined,
                          titulo: 'Ocultar saldos al abrir la app',
                          subtitulo: 'Muestra ••••• hasta que lo destapes',
                          activo: ocultar,
                          onTap: () => _toggleOcultar(ocultar),
                          esUltima: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('SEGURIDAD Y LEGAL', style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      children: [
                        _FilaNav(
                          icon: Icons.lock_outline_rounded,
                          titulo: 'Cambiar PIN transaccional de 4 dígitos',
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CambiarPinScreen())),
                        ),
                        _FilaNav(
                          icon: Icons.phone_iphone_rounded,
                          titulo: 'Dispositivos vinculados y sesiones activas',
                          subtitulo: '2 dispositivos de confianza',
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DispositivosSesionesScreen())),
                        ),
                        _FilaNav(
                          icon: Icons.description_outlined,
                          titulo: 'Términos, condiciones y aviso de privacidad',
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TerminosPrivacidadScreen())),
                          esUltima: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _cerrarSesion,
                      icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.danger),
                      label: const Text('Cerrar sesión'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        backgroundColor: AppColors.danger.withValues(alpha: 0.1),
                        side: BorderSide(color: AppColors.danger.withValues(alpha: 0.35)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        textStyle: AppTheme.body(size: 14, weight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text('CooPay · Original Auth', style: AppTheme.body(size: 11, color: AppColors.textDim)),
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

class _FilaToggle extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final bool activo;
  final VoidCallback onTap;
  final bool esUltima;
  const _FilaToggle({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.activo,
    required this.onTap,
    this.esUltima = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(border: esUltima ? null : const Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(999)),
            child: Icon(icon, size: 16, color: AppColors.navy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: AppTheme.body(size: 13.5, weight: FontWeight.w600)),
                Text(subtitulo, style: AppTheme.body(size: 11, color: AppColors.textDim)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 42,
              height: 24,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(color: activo ? AppColors.green : AppColors.border, borderRadius: BorderRadius.circular(999)),
              alignment: activo ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(width: 18, height: 18, decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaNav extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String? subtitulo;
  final VoidCallback onTap;
  final bool esUltima;
  const _FilaNav({required this.icon, required this.titulo, this.subtitulo, required this.onTap, this.esUltima = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(border: esUltima ? null : const Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(999)),
              child: Icon(icon, size: 16, color: AppColors.navy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: subtitulo == null
                  ? Text(titulo, style: AppTheme.body(size: 13.5, weight: FontWeight.w600))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(titulo, style: AppTheme.body(size: 13.5, weight: FontWeight.w600)),
                        Text(subtitulo!, style: AppTheme.body(size: 11, color: AppColors.textDim)),
                      ],
                    ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textDim),
          ],
        ),
      ),
    );
  }
}
