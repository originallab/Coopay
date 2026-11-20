import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/venta_comercio.dart';
import '../../repositories/comercios_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/fecha.dart';

class DetalleTransaccionComercioScreen extends StatefulWidget {
  final String comercioId;
  final VentaComercio venta;
  const DetalleTransaccionComercioScreen({super.key, required this.comercioId, required this.venta});

  @override
  State<DetalleTransaccionComercioScreen> createState() => _DetalleTransaccionComercioScreenState();
}

class _DetalleTransaccionComercioScreenState extends State<DetalleTransaccionComercioScreen> {
  late VentaComercio _venta;
  bool _compartiendo = false;
  bool _reembolsando = false;

  @override
  void initState() {
    super.initState();
    _venta = widget.venta;
  }

  Future<void> _compartir() async {
    setState(() => _compartiendo = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _compartiendo = false);
  }

  Future<void> _reembolsar() async {
    if (_venta.reembolsada) return;
    setState(() => _reembolsando = true);
    final actualizada = await context.read<ComerciosRepository>().marcarReembolso(widget.comercioId, _venta.id);
    if (!mounted) return;
    setState(() {
      _venta = actualizada;
      _reembolsando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(_venta),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: AppColors.navy),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text('Detalle de transacción', style: AppTheme.display(size: 19)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: _venta.reembolsada ? AppColors.danger.withValues(alpha: 0.12) : AppColors.green.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _venta.reembolsada ? 'Reembolsada' : 'Aprobada',
                            style: AppTheme.body(size: 11, weight: FontWeight.w700, color: _venta.reembolsada ? AppColors.danger : AppColors.greenDark),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${_venta.reembolsada ? '' : '+'}\$${_venta.monto.toStringAsFixed(2)} MXN',
                          style: AppTheme.display(size: 32, color: _venta.reembolsada ? AppColors.textDim : AppColors.navy),
                        ),
                        const SizedBox(height: 4),
                        Text('Cobro con QR · Tienda CoopMarket', style: AppTheme.body(size: 11.5, color: AppColors.textDim)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DESGLOSE DEL COBRO', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.textDim)),
                          const SizedBox(height: 10),
                          _Fila('Folio de operación', _venta.folio),
                          _Fila('Fecha', formatoFecha(_venta.createdAt)),
                          _Fila('Hora', formatoHora(_venta.createdAt)),
                          _Fila('Concepto', _venta.concepto ?? '—'),
                          _Fila('Cobrado por', _venta.cobradoPor ?? '—', ultima: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SOCIO EMISOR', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.textDim)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
                                alignment: Alignment.center,
                                child: Text(_venta.iniciales, style: AppTheme.display(size: 13, color: AppColors.greenDark)),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_venta.socioNombre, style: AppTheme.body(size: 13.5, weight: FontWeight.w700)),
                                  Text('Identidad verificada · Sesión activa', style: AppTheme.body(size: 11, color: AppColors.textDim)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 22),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _compartir,
                      icon: Icon(_compartiendo ? Icons.check_rounded : Icons.ios_share_rounded, size: 16, color: AppColors.greenDark),
                      label: Text(_compartiendo ? '¡Comprobante compartido!' : 'Compartir comprobante PDF'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.greenDark,
                        backgroundColor: AppColors.green.withValues(alpha: 0.1),
                        side: BorderSide(color: AppColors.green.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        textStyle: AppTheme.body(size: 14, weight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _venta.reembolsada ? null : _reembolsar,
                      icon: _reembolsando
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.danger))
                          : Icon(_venta.reembolsada ? Icons.check_rounded : Icons.replay_rounded, size: 16, color: AppColors.danger),
                      label: Text(_venta.reembolsada ? 'Reembolso emitido' : 'Emitir reembolso'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        backgroundColor: _venta.reembolsada ? AppColors.border : AppColors.danger.withValues(alpha: 0.08),
                        side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        textStyle: AppTheme.body(size: 14, weight: FontWeight.w700),
                        disabledForegroundColor: AppColors.textDim,
                      ),
                    ),
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

class _Fila extends StatelessWidget {
  final String label;
  final String valor;
  final bool ultima;
  const _Fila(this.label, this.valor, {this.ultima = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: ultima ? 0 : 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.body(size: 12.5, color: AppColors.textDim)),
          Flexible(child: Text(valor, textAlign: TextAlign.right, style: AppTheme.body(size: 12.5, weight: FontWeight.w700))),
        ],
      ),
    );
  }
}
