import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/dispositivo.dart';
import '../../repositories/dispositivos_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class DispositivosSesionesScreen extends StatefulWidget {
  const DispositivosSesionesScreen({super.key});

  @override
  State<DispositivosSesionesScreen> createState() => _DispositivosSesionesScreenState();
}

class _DispositivosSesionesScreenState extends State<DispositivosSesionesScreen> {
  late Future<List<Dispositivo>> _dispositivosFuture;

  void _cargar() {
    _dispositivosFuture = context.read<DispositivosRepository>().listarOtros();
  }

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cerrarUno(String id) async {
    await context.read<DispositivosRepository>().cerrarSesion(id);
    if (!mounted) return;
    setState(_cargar);
  }

  Future<void> _cerrarTodas() async {
    await context.read<DispositivosRepository>().cerrarTodas();
    if (!mounted) return;
    setState(_cargar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                  Expanded(child: Text('Dispositivos y sesiones', style: AppTheme.display(size: 18))),
                ],
              ),
              const SizedBox(height: 16),
              Text('Estos son los dispositivos donde has iniciado sesión con tu cuenta CooPay.',
                  style: AppTheme.body(size: 13, color: AppColors.textDim)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.greenLight, width: 1.5), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(999)),
                      child: const Icon(Icons.smartphone_rounded, size: 17, color: AppColors.navy),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('iPhone 15 · Ciudad de México', style: AppTheme.body(size: 13.5, weight: FontWeight.w700)),
                          Text('Activo ahora', style: AppTheme.body(size: 11.5, color: AppColors.textDim)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(999)),
                      child: Text('Este dispositivo', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.greenDark)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text('OTRAS SESIONES ACTIVAS', style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
              const SizedBox(height: 10),
              FutureBuilder<List<Dispositivo>>(
                future: _dispositivosFuture,
                builder: (context, snap) {
                  if (!snap.hasData) return const SizedBox(height: 60, child: Center(child: CircularProgressIndicator()));
                  final dispositivos = snap.data!;
                  if (dispositivos.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text('No hay otras sesiones activas.', style: AppTheme.body(size: 12.5, color: AppColors.textDim)),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      ...dispositivos.map((d) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(999)),
                                  child: const Icon(Icons.laptop_mac_rounded, size: 17, color: AppColors.navy),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(d.nombre, style: AppTheme.body(size: 13.5, weight: FontWeight.w700)),
                                      Text(d.actividad, style: AppTheme.body(size: 11.5, color: AppColors.textDim)),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _cerrarUno(d.id),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.danger,
                                    backgroundColor: AppColors.danger.withValues(alpha: 0.1),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                  ),
                                  child: Text('Cerrar', style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.danger)),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _cerrarTodas,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: BorderSide(color: AppColors.danger.withValues(alpha: 0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            textStyle: AppTheme.body(size: 13.5, weight: FontWeight.w700),
                          ),
                          child: const Text('Cerrar todas las demás sesiones'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
