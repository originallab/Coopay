import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/comercio.dart';
import '../../models/venta_comercio.dart';
import '../../repositories/comercios_repository.dart';
import '../../routing/route_observer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/fecha.dart';
import 'cobro_qr_screen.dart';
import 'datos_fiscales_screen.dart';
import 'detalle_transaccion_comercio_screen.dart';
import 'historial_ventas_screen.dart';
import 'mostrador_qr_screen.dart';
import 'notificaciones_comercio_screen.dart';
import 'perfil_comercio_screen.dart';
import 'supervisores_screen.dart';

class PanelComercioScreen extends StatefulWidget {
  final String comercioId;
  const PanelComercioScreen({super.key, required this.comercioId});

  @override
  State<PanelComercioScreen> createState() => _PanelComercioScreenState();
}

class _PanelComercioScreenState extends State<PanelComercioScreen> with RouteAware {
  late Future<ComercioDetalle> _comercioFuture;
  late Future<List<VentaComercio>> _ventasFuture;

  void _cargarDatos() {
    final repo = context.read<ComerciosRepository>();
    _comercioFuture = repo.obtenerComercio(widget.comercioId);
    _ventasFuture = repo.ventasDe(widget.comercioId);
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos();
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
  void didPopNext() => setState(_cargarDatos);

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
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) => CobroQrScreen(comercio: comercio))),
                            icon: const Icon(Icons.qr_code_scanner_rounded, size: 19),
                            label: const Text('Mostrar QR para cobrar'),
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 17)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _OutlineAction(
                                icon: Icons.grid_view_rounded,
                                label: 'Mi QR físico',
                                onTap: () => Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (_) => MostradorQrScreen(comercio: comercio))),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _OutlineAction(
                                icon: Icons.people_alt_rounded,
                                label: 'Supervisores',
                                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => SupervisoresScreen(
                                      comercioId: comercio.id, comercioNombre: comercio.nombreComercial),
                                )),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('COBROS DEL DÍA',
                                style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
                            GestureDetector(
                              onTap: () => Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) => HistorialVentasScreen(comercio: comercio))),
                              child: Text('Ver historial',
                                  style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.greenDark)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        FutureBuilder<List<VentaComercio>>(
                          future: _ventasFuture,
                          builder: (context, ventSnap) {
                            if (!ventSnap.hasData) return const SizedBox(height: 60);
                            final hoy = ventSnap.data!.where((v) => esHoy(v.createdAt)).take(6).toList();
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                children: hoy
                                    .map((v) => _FilaVenta(
                                          venta: v,
                                          esUltima: v == hoy.last,
                                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                            builder: (_) =>
                                                DetalleTransaccionComercioScreen(comercioId: comercio.id, venta: v),
                                          )),
                                        ))
                                    .toList(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('COMERCIO',
                            style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) => DatosFiscalesScreen(comercioId: comercio.id))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration:
                                        BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(999)),
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.receipt_long_rounded, size: 16, color: AppColors.navy),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Datos del comercio', style: AppTheme.body(size: 13.5, weight: FontWeight.w600)),
                                        Text('Nombre, giro y cuenta receptora',
                                            style: AppTheme.body(size: 11, color: AppColors.textDim)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textDim),
                                ],
                              ),
                            ),
                          ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => NotificacionesComercioScreen(comercio: comercio))),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.notifications_none_rounded, size: 16, color: AppColors.cream),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => PerfilComercioScreen(comercioId: comercio.id))),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.cream),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration:
                BoxDecoration(color: AppColors.greenLight.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(999)),
            child: Text('Comercio: ${comercio.nombreComercial} · Administrador',
                style: AppTheme.body(size: 9.5, weight: FontWeight.w700, color: AppColors.greenLight)),
          ),
          const SizedBox(height: 8),
          Text(comercio.nombreComercial, style: AppTheme.display(size: 22, color: AppColors.surface)),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration:
                    BoxDecoration(color: AppColors.green.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(999)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.greenLight, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text('Activo', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.greenLight)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Cuenta receptora: ${comercio.institucionReceptora}',
                    style: AppTheme.body(size: 10.5, color: AppColors.surface.withValues(alpha: 0.5)),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FutureBuilder<List<VentaComercio>>(
            future: ventasFuture,
            builder: (context, snap) {
              final hoy = (snap.data ?? const []).where((v) => esHoy(v.createdAt) && !v.reembolsada).toList();
              final total = hoy.fold<double>(0, (a, v) => a + v.monto);
              final promedio = hoy.isEmpty ? 0.0 : total / hoy.length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ventas de hoy',
                      style: AppTheme.body(size: 11.5, weight: FontWeight.w600, color: AppColors.surface.withValues(alpha: 0.55))),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$${total.toStringAsFixed(2)}', style: AppTheme.display(size: 30, color: AppColors.surface)),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('MXN',
                            style: AppTheme.body(size: 13, weight: FontWeight.w600, color: AppColors.surface.withValues(alpha: 0.5))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _StatTile(label: 'Cobros realizados', value: '${hoy.length}')),
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

class _OutlineAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _OutlineAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: AppColors.navy),
            const SizedBox(width: 7),
            Text(label, style: AppTheme.body(size: 12.5, weight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _FilaVenta extends StatelessWidget {
  final VentaComercio venta;
  final bool esUltima;
  final VoidCallback onTap;
  const _FilaVenta({required this.venta, required this.onTap, this.esUltima = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          border: esUltima ? null : const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(venta.iniciales, style: AppTheme.display(size: 12.5, color: AppColors.greenDark)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(venta.socioNombre, style: AppTheme.body(size: 13, weight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                  Text('Cobro QR · ${venta.folio} · ${formatoHora(venta.createdAt)}',
                      style: AppTheme.body(size: 11, color: AppColors.textDim)),
                ],
              ),
            ),
            Text('+\$${venta.monto.toStringAsFixed(2)}', style: AppTheme.body(size: 13.5, weight: FontWeight.w700, color: AppColors.greenDark)),
          ],
        ),
      ),
    );
  }
}
