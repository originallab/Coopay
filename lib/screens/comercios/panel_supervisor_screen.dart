import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/comercio.dart';
import '../../models/venta_comercio.dart';
import '../../repositories/comercios_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/fecha.dart';

/// Espejo de solo lectura de PanelComercioScreen — un supervisor no puede
/// cobrar, editar el comercio ni gestionar supervisores (playbook: roles
/// por comercio, no cuentas distintas).
class PanelSupervisorScreen extends StatefulWidget {
  final String comercioId;
  const PanelSupervisorScreen({super.key, required this.comercioId});

  @override
  State<PanelSupervisorScreen> createState() => _PanelSupervisorScreenState();
}

class _PanelSupervisorScreenState extends State<PanelSupervisorScreen> {
  late Future<ComercioDetalle> _comercioFuture;
  late Future<List<VentaComercio>> _ventasFuture;

  @override
  void initState() {
    super.initState();
    final repo = context.read<ComerciosRepository>();
    _comercioFuture = repo.obtenerComercio(widget.comercioId);
    _ventasFuture = repo.ventasDe(widget.comercioId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<ComercioDetalle>(
          future: _comercioFuture,
          builder: (context, comSnap) {
            if (!comSnap.hasData) return const Center(child: CircularProgressIndicator());
            final comercio = comSnap.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(comercio: comercio, ventasFuture: _ventasFuture),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.navy),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Vista de solo lectura: puedes consultar los cobros de este comercio, pero no cobrar, editar su configuración ni gestionar supervisores.',
                            style: AppTheme.body(size: 11, color: AppColors.navy.withValues(alpha: 0.65)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('COBROS AUTORIZADOS',
                            style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
                        const SizedBox(height: 6),
                        FutureBuilder<List<VentaComercio>>(
                          future: _ventasFuture,
                          builder: (context, snap) {
                            if (!snap.hasData) return const SizedBox(height: 60);
                            final ventas = snap.data!.take(6).toList();
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                children: ventas
                                    .map((v) => _FilaCobro(venta: v, esUltima: v == ventas.last))
                                    .toList(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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

class _Header extends StatelessWidget {
  final ComercioDetalle comercio;
  final Future<List<VentaComercio>> ventasFuture;
  const _Header({required this.comercio, required this.ventasFuture});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(26), bottomRight: Radius.circular(26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            customBorder: const CircleBorder(),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: AppColors.cream),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
            child: Text('Comercio: ${comercio.nombreComercial} · Supervisor (solo lectura)',
                style: AppTheme.body(size: 9.5, weight: FontWeight.w700, color: AppColors.surface)),
          ),
          const SizedBox(height: 8),
          Text(comercio.nombreComercial, style: AppTheme.display(size: 22, color: AppColors.surface)),
          const SizedBox(height: 14),
          FutureBuilder<List<VentaComercio>>(
            future: ventasFuture,
            builder: (context, snap) {
              final todas = snap.data ?? const [];
              final total = todas.fold<double>(0, (a, v) => a + v.monto);
              final promedio = todas.isEmpty ? 0.0 : total / todas.length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total cobrado hoy',
                      style: AppTheme.body(size: 11.5, weight: FontWeight.w600, color: AppColors.surface.withValues(alpha: 0.55))),
                  Text('\$${total.toStringAsFixed(2)} MXN', style: AppTheme.display(size: 28, color: AppColors.surface)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _StatTile(label: 'Cobros', value: '${todas.length}')),
                      const SizedBox(width: 10),
                      Expanded(child: _StatTile(label: 'Ticket promedio', value: '\$${promedio.toStringAsFixed(2)}')),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
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

/// A diferencia de PanelComercioScreen, aquí NO se muestra el nombre del
/// socio pagador — un supervisor solo ve folio/hora/estado/monto (ver
/// InvitarSupervisorScreen: "Qué podrá ver" nunca incluye identidad del
/// cliente).
class _FilaCobro extends StatelessWidget {
  final VentaComercio venta;
  final bool esUltima;
  const _FilaCobro({required this.venta, this.esUltima = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(border: esUltima ? null : const Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Text('·', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.greenDark)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(venta.folio, style: AppTheme.body(size: 13, weight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                Text(
                  '${formatoHora(venta.createdAt)} · ${venta.reembolsada ? 'Reembolsado' : 'Aprobado'}',
                  style: AppTheme.body(size: 11, color: AppColors.textDim),
                ),
              ],
            ),
          ),
          Text('+\$${venta.monto.toStringAsFixed(2)}', style: AppTheme.body(size: 13.5, weight: FontWeight.w700, color: AppColors.greenDark)),
        ],
      ),
    );
  }
}
