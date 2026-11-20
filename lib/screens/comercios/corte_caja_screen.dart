import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/comercio.dart';
import '../../models/corte_caja.dart';
import '../../repositories/comercios_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/fecha.dart';

/// Corte de caja diario del comercio completo — no por Cajero/turno
/// individual, porque este modelo no tiene ese rol. "Cerrar caja" solo
/// marca el día como reconciliado; las ventas en vivo no se detienen.
class CorteCajaScreen extends StatefulWidget {
  final ComercioDetalle comercio;
  const CorteCajaScreen({super.key, required this.comercio});

  @override
  State<CorteCajaScreen> createState() => _CorteCajaScreenState();
}

class _CorteCajaScreenState extends State<CorteCajaScreen> {
  late Future<EstadoCorteCaja> _estadoFuture;
  bool _exportando = false;
  bool _exportado = false;

  void _cargar() {
    _estadoFuture = context.read<ComerciosRepository>().estadoCorteCaja(widget.comercio.id);
  }

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _exportar() {
    setState(() => _exportando = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _exportando = false;
        _exportado = true;
      });
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (mounted) setState(() => _exportado = false);
      });
    });
  }

  Future<void> _confirmarCierre(EstadoCorteCaja estado) async {
    final confirmado = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Cerrar caja del día?', style: AppTheme.display(size: 18)),
            const SizedBox(height: 8),
            Text(
              'Quedará un registro con ${estado.ventas} cobros por \$${estado.total.toStringAsFixed(2)}. Los cobros nuevos de hoy seguirán llegando con normalidad.',
              style: AppTheme.body(size: 12.5, color: AppColors.textDim),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Cerrar caja'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.navy,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
    if (confirmado == true && mounted) {
      final repo = context.read<ComerciosRepository>();
      await repo.cerrarCaja(widget.comercio.id);
      if (!mounted) return;
      setState(_cargar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: AppColors.navy),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Corte de caja', style: AppTheme.display(size: 20)),
                      Text(widget.comercio.nombreComercial, style: AppTheme.body(size: 11, color: AppColors.textDim)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<EstadoCorteCaja>(
                future: _estadoFuture,
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final estado = snap.data!;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: (estado.abierto ? AppColors.green : AppColors.navy).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: estado.abierto ? AppColors.greenDark : AppColors.navy,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                estado.abierto ? 'Caja abierta · hoy' : 'Caja cerrada · ${formatoHora(estado.cerradoA!)}',
                                style: AppTheme.body(
                                  size: 11.5,
                                  weight: FontWeight.w700,
                                  color: estado.abierto ? AppColors.greenDark : AppColors.navy,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(22)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total cobrado hoy',
                                  style: AppTheme.body(size: 11.5, weight: FontWeight.w600, color: AppColors.surface.withValues(alpha: 0.55))),
                              const SizedBox(height: 4),
                              Text('\$${estado.total.toStringAsFixed(2)}', style: AppTheme.display(size: 30, color: AppColors.surface)),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(child: _StatTile(label: 'Cobros', value: '${estado.ventas}')),
                                  const SizedBox(width: 10),
                                  Expanded(child: _StatTile(label: 'Ticket promedio', value: '\$${estado.promedio.toStringAsFixed(2)}')),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _exportando ? null : _exportar,
                            icon: Icon(_exportado ? Icons.check_rounded : Icons.file_download_outlined, size: 17),
                            label: Text(_exportado ? '¡Reporte exportado!' : 'Exportar reporte (PDF)'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.navy,
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: estado.abierto ? () => _confirmarCierre(estado) : () => Navigator.of(context).pop(),
                            child: Text(estado.abierto ? 'Cerrar caja' : 'Volver al perfil'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.body(size: 10, weight: FontWeight.w600, color: AppColors.surface.withValues(alpha: 0.55))),
          const SizedBox(height: 2),
          Text(value, style: AppTheme.display(size: 17, color: AppColors.surface)),
        ],
      ),
    );
  }
}
