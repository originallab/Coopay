import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/comercio.dart';
import '../../models/venta_comercio.dart';
import '../../repositories/comercios_repository.dart';
import '../../routing/route_observer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/fecha.dart';
import 'detalle_transaccion_comercio_screen.dart';

enum _Rango { hoy, d7, mes }

enum _Estado { todas, aprobadas, reembolsadas }

class HistorialVentasScreen extends StatefulWidget {
  final ComercioDetalle comercio;
  const HistorialVentasScreen({super.key, required this.comercio});

  @override
  State<HistorialVentasScreen> createState() => _HistorialVentasScreenState();
}

class _HistorialVentasScreenState extends State<HistorialVentasScreen> with RouteAware {
  late Future<List<VentaComercio>> _ventasFuture;
  _Rango _rango = _Rango.hoy;
  _Estado _estado = _Estado.todas;

  void _cargarVentas() {
    _ventasFuture = context.read<ComerciosRepository>().ventasDe(widget.comercio.id);
  }

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() => setState(_cargarVentas);

  int get _maxDias => switch (_rango) { _Rango.hoy => 0, _Rango.d7 => 6, _Rango.mes => 14 };

  bool _enRango(DateTime d) {
    final ahora = DateTime.now();
    final diasAtras = DateTime(ahora.year, ahora.month, ahora.day).difference(DateTime(d.year, d.month, d.day)).inDays;
    return diasAtras <= _maxDias;
  }

  bool _cumpleEstado(VentaComercio v) {
    switch (_estado) {
      case _Estado.todas:
        return true;
      case _Estado.aprobadas:
        return !v.reembolsada;
      case _Estado.reembolsadas:
        return v.reembolsada;
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
                      Text('Historial de Ventas', style: AppTheme.display(size: 20)),
                      Text('${widget.comercio.nombreComercial} · Caja 1', style: AppTheme.body(size: 11, color: AppColors.textDim)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _ChipFiltro(
                      label: 'Hoy',
                      activo: _rango == _Rango.hoy,
                      oscuro: false,
                      onTap: () => setState(() => _rango = _Rango.hoy)),
                  const SizedBox(width: 8),
                  _ChipFiltro(
                      label: 'Últimos 7 días',
                      activo: _rango == _Rango.d7,
                      oscuro: false,
                      onTap: () => setState(() => _rango = _Rango.d7)),
                  const SizedBox(width: 8),
                  _ChipFiltro(
                      label: 'Este mes',
                      activo: _rango == _Rango.mes,
                      oscuro: false,
                      onTap: () => setState(() => _rango = _Rango.mes)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _ChipFiltro(
                      label: 'Todas',
                      activo: _estado == _Estado.todas,
                      oscuro: true,
                      onTap: () => setState(() => _estado = _Estado.todas)),
                  const SizedBox(width: 8),
                  _ChipFiltro(
                      label: 'Aprobadas',
                      activo: _estado == _Estado.aprobadas,
                      oscuro: true,
                      onTap: () => setState(() => _estado = _Estado.aprobadas)),
                  const SizedBox(width: 8),
                  _ChipFiltro(
                      label: 'Reembolsadas',
                      activo: _estado == _Estado.reembolsadas,
                      oscuro: true,
                      onTap: () => setState(() => _estado = _Estado.reembolsadas)),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<VentaComercio>>(
                future: _ventasFuture,
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final enRango = snap.data!.where((v) => _enRango(v.createdAt)).toList();
                  final visibles = enRango.where(_cumpleEstado).toList();
                  final totalCobrado = enRango.where((v) => !v.reembolsada).fold<double>(0, (a, v) => a + v.monto);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(14)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total cobrado', style: AppTheme.body(size: 10, weight: FontWeight.w600, color: AppColors.surface.withValues(alpha: 0.55))),
                                    Text('\$${totalCobrado.toStringAsFixed(2)} MXN', style: AppTheme.display(size: 17, color: AppColors.surface)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Transacciones', style: AppTheme.body(size: 10, weight: FontWeight.w600, color: AppColors.textDim)),
                                    Text('${visibles.length}', style: AppTheme.display(size: 17)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: visibles.isEmpty
                            ? Center(child: Text('Sin movimientos en este periodo.', style: AppTheme.body(size: 13, color: AppColors.textDim)))
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                                itemCount: visibles.length,
                                itemBuilder: (context, i) => _FilaVenta(
                                  venta: visibles[i],
                                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => DetalleTransaccionComercioScreen(comercioId: widget.comercio.id, venta: visibles[i]),
                                  )),
                                ),
                              ),
                      ),
                    ],
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

class _ChipFiltro extends StatelessWidget {
  final String label;
  final bool activo;
  final bool oscuro;
  final VoidCallback onTap;
  const _ChipFiltro({required this.label, required this.activo, required this.oscuro, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final activoColor = oscuro ? AppColors.navy : AppColors.green;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(color: activo ? activoColor : AppColors.cream, borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: AppTheme.body(size: 11.5, weight: FontWeight.w700, color: activo ? AppColors.surface : AppColors.navy)),
      ),
    );
  }
}

class _FilaVenta extends StatelessWidget {
  final VentaComercio venta;
  final VoidCallback onTap;
  const _FilaVenta({required this.venta, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(venta.iniciales, style: AppTheme.display(size: 12, color: AppColors.greenDark)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(venta.socioNombre, style: AppTheme.body(size: 13.5, weight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                  Text('Cobro QR · ${venta.folio} · ${formatoHora(venta.createdAt)}', style: AppTheme.body(size: 11, color: AppColors.textDim)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+\$${venta.monto.toStringAsFixed(2)}',
                  style: AppTheme.body(
                    size: 13,
                    weight: FontWeight.w700,
                    color: venta.reembolsada ? AppColors.textDim : AppColors.greenDark,
                  ).copyWith(decoration: venta.reembolsada ? TextDecoration.lineThrough : null),
                ),
                if (venta.reembolsada) ...[
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                    decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
                    child: Text('Reembolsada', style: AppTheme.body(size: 9.5, weight: FontWeight.w700, color: AppColors.danger)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
