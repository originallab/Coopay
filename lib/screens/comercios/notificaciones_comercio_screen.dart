import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/comercio.dart';
import '../../models/notificacion_comercio.dart';
import '../../models/venta_comercio.dart';
import '../../repositories/comercios_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/fecha.dart';
import '../perfil/dispositivos_sesiones_screen.dart';
import 'detalle_transaccion_comercio_screen.dart';

class NotificacionesComercioScreen extends StatefulWidget {
  final ComercioDetalle comercio;
  const NotificacionesComercioScreen({super.key, required this.comercio});

  @override
  State<NotificacionesComercioScreen> createState() => _NotificacionesComercioScreenState();
}

class _NotificacionesComercioScreenState extends State<NotificacionesComercioScreen> {
  late Future<List<NotificacionComercio>> _future;
  CategoriaNotifComercio _tab = CategoriaNotifComercio.pago;

  void _cargar() {
    _future = context.read<ComerciosRepository>().notificacionesDe(widget.comercio.id);
  }

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _marcarTodoLeido() async {
    await context.read<ComerciosRepository>().marcarNotificacionesLeidas(widget.comercio.id);
    if (!mounted) return;
    setState(_cargar);
  }

  Future<void> _abrirVenta(String? ventaId) async {
    if (ventaId == null) return;
    final ventas = await context.read<ComerciosRepository>().ventasDe(widget.comercio.id);
    VentaComercio? venta;
    for (final v in ventas) {
      if (v.id == ventaId) {
        venta = v;
        break;
      }
    }
    if (venta == null || !mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DetalleTransaccionComercioScreen(comercioId: widget.comercio.id, venta: venta!),
    ));
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: FutureBuilder<List<NotificacionComercio>>(
                      future: _future,
                      builder: (context, snap) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notificaciones', style: AppTheme.display(size: 19)),
                          Text('${widget.comercio.nombreComercial} · ${snap.data?.length ?? 0} en total',
                              style: AppTheme.body(size: 11, color: AppColors.textDim)),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _marcarTodoLeido,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.greenDark,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('Marcar todo\ncomo leído',
                        textAlign: TextAlign.right, style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.greenDark)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<NotificacionComercio>>(
              future: _future,
              builder: (context, snap) {
                final datos = snap.data ?? const [];
                int contar(CategoriaNotifComercio c) => datos.where((n) => n.categoria == c).length;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _ChipTab(
                          label: 'Pagos recibidos',
                          count: contar(CategoriaNotifComercio.pago),
                          activo: _tab == CategoriaNotifComercio.pago,
                          onTap: () => setState(() => _tab = CategoriaNotifComercio.pago),
                        ),
                        const SizedBox(width: 8),
                        _ChipTab(
                          label: 'Retiros procesados',
                          count: contar(CategoriaNotifComercio.retiro),
                          activo: _tab == CategoriaNotifComercio.retiro,
                          onTap: () => setState(() => _tab = CategoriaNotifComercio.retiro),
                        ),
                        const SizedBox(width: 8),
                        _ChipTab(
                          label: 'Avisos del sistema',
                          count: contar(CategoriaNotifComercio.aviso),
                          activo: _tab == CategoriaNotifComercio.aviso,
                          onTap: () => setState(() => _tab = CategoriaNotifComercio.aviso),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: FutureBuilder<List<NotificacionComercio>>(
                future: _future,
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final items = snap.data!.where((n) => n.categoria == _tab).toList();
                  final tituloSeccion = switch (_tab) {
                    CategoriaNotifComercio.pago => 'COBROS POR CÓDIGO QR',
                    CategoriaNotifComercio.retiro => 'ENVÍOS A TUS CUENTAS BANCARIAS',
                    CategoriaNotifComercio.aviso => 'SEGURIDAD Y CUENTA',
                  };
                  if (items.isEmpty) {
                    return Center(child: Text('Sin notificaciones en esta categoría.', style: AppTheme.body(size: 12.5, color: AppColors.textDim)));
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tituloSeccion, style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
                          child: Column(
                            children: items.map((n) => _FilaNotificacion(
                                  notificacion: n,
                                  esUltima: n == items.last,
                                  onTap: () => _onTapNotificacion(n),
                                )).toList(),
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

  void _onTapNotificacion(NotificacionComercio n) {
    if (n.categoria == CategoriaNotifComercio.pago) {
      _abrirVenta(n.ventaId);
    } else if (n.id == 'nc8') {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DispositivosSesionesScreen()));
    }
  }
}

class _ChipTab extends StatelessWidget {
  final String label;
  final int count;
  final bool activo;
  final VoidCallback onTap;
  const _ChipTab({required this.label, required this.count, required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(color: activo ? AppColors.navy : AppColors.cream, borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTheme.body(size: 11.5, weight: FontWeight.w700, color: activo ? AppColors.surface : AppColors.navy)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: activo ? Colors.white.withValues(alpha: 0.25) : AppColors.navy.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('$count', style: AppTheme.body(size: 10, weight: FontWeight.w700, color: activo ? AppColors.surface : AppColors.navy)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaNotificacion extends StatelessWidget {
  final NotificacionComercio notificacion;
  final bool esUltima;
  final VoidCallback onTap;
  const _FilaNotificacion({required this.notificacion, required this.onTap, this.esUltima = false});

  IconData get _icono => switch (notificacion.categoria) {
        CategoriaNotifComercio.pago => Icons.check_rounded,
        CategoriaNotifComercio.retiro => Icons.north_east_rounded,
        CategoriaNotifComercio.aviso => Icons.info_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final n = notificacion;
    final esTocable = n.categoria == CategoriaNotifComercio.pago || n.id == 'nc8';
    return InkWell(
      onTap: esTocable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(border: esUltima ? null : const Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(999)),
              alignment: Alignment.center,
              child: Icon(_icono, size: 15, color: AppColors.greenDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(n.titulo, style: AppTheme.body(size: 13, weight: FontWeight.w700))),
                      if (!n.leido) ...[
                        Container(width: 6, height: 6, margin: const EdgeInsets.only(right: 6), decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle)),
                      ],
                      if (n.montoTexto != null)
                        Text(n.montoTexto!,
                            style: AppTheme.body(
                              size: 13,
                              weight: FontWeight.w700,
                              color: n.categoria == CategoriaNotifComercio.pago ? AppColors.greenDark : AppColors.navy,
                            )),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(n.detalle, style: AppTheme.body(size: 11.5, color: AppColors.textDim)),
                  const SizedBox(height: 3),
                  Text(
                    esHoy(n.createdAt) ? 'Hoy, ${formatoHora(n.createdAt)}' : '${formatoFecha(n.createdAt)}, ${formatoHora(n.createdAt)}',
                    style: AppTheme.body(size: 10.5, color: AppColors.textDim.withValues(alpha: 0.75)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
