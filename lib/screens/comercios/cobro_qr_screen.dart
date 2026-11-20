import 'package:flutter/material.dart';
import '../../models/comercio.dart';
import '../../models/venta_comercio.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'detalle_transaccion_comercio_screen.dart';

/// Pantalla "en vivo" para cobrar: en producción el servidor empuja el
/// evento de pago recibido por WebSocket/polling; aquí no hay backend, así
/// que "Simular cobro recibido" dispara el mismo overlay con datos fijos
/// (igual que el prototipo — no genera un cobro nuevo en el historial).
class CobroQrScreen extends StatefulWidget {
  final ComercioDetalle comercio;
  const CobroQrScreen({super.key, required this.comercio});

  @override
  State<CobroQrScreen> createState() => _CobroQrScreenState();
}

class _CobroQrScreenState extends State<CobroQrScreen> {
  bool _mostrarPago = false;

  static final _ventaDemo = VentaComercio(
    id: 'v1',
    folio: 'CP-30418-QR',
    socioNombre: 'Mariana López',
    monto: 350,
    createdAt: DateTime.now(),
    concepto: 'Abarrotes / Mesa 4',
    cobradoPor: 'Mariana Soto · Caja 1',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: Row(
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                        decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(999)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.greenLight, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('Esperando pago', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.greenLight)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 34),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.comercio.nombreComercial, style: AppTheme.display(size: 20, color: AppColors.surface)),
                      const SizedBox(height: 2),
                      Text('Pide al cliente escanear este código', style: AppTheme.body(size: 12, color: AppColors.surface.withValues(alpha: 0.55))),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(Icons.qr_code_2_rounded, size: 190, color: AppColors.navy),
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(color: AppColors.cream, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                              alignment: Alignment.center,
                              child: Text('CP', style: AppTheme.display(size: 14, color: AppColors.navy)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(widget.comercio.institucionReceptora, style: AppTheme.body(size: 14, weight: FontWeight.w600, color: AppColors.surface.withValues(alpha: 0.55))),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 26),
                  child: InkWell(
                    onTap: () => setState(() => _mostrarPago = true),
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bolt_rounded, size: 14, color: Colors.white.withValues(alpha: 0.65)),
                          const SizedBox(width: 7),
                          Text('Simular cobro recibido',
                              style: AppTheme.body(size: 12, weight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.65))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_mostrarPago)
              Container(
                color: AppColors.navy,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
                            child: Text('En tiempo real · hace 2s', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.greenLight)),
                          ),
                          InkWell(
                            onTap: () => setState(() => _mostrarPago = false),
                            customBorder: const CircleBorder(),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.close_rounded, size: 15, color: AppColors.cream),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 74,
                            height: 74,
                            decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.2), shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Container(
                              width: 54,
                              height: 54,
                              decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                              child: const Icon(Icons.check_rounded, color: Colors.white, size: 26),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Cobro por código QR', style: AppTheme.body(size: 12.5, weight: FontWeight.w600, color: AppColors.surface.withValues(alpha: 0.6))),
                          const SizedBox(height: 4),
                          Text('¡Pago Recibido!', style: AppTheme.display(size: 22, color: AppColors.surface)),
                          const SizedBox(height: 4),
                          Text('+\$${_ventaDemo.monto.toStringAsFixed(2)} MXN', style: AppTheme.display(size: 32, color: AppColors.surface)),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
                                alignment: Alignment.center,
                                child: Text(_ventaDemo.iniciales, style: AppTheme.display(size: 13, color: AppColors.greenDark)),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_ventaDemo.socioNombre, style: AppTheme.body(size: 13.5, weight: FontWeight.w700)),
                                  Text('Identidad verificada · ${widget.comercio.institucionReceptora}',
                                      style: AppTheme.body(size: 10.5, color: AppColors.textDim)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _Fila(label: 'Folio de operación', valor: _ventaDemo.folio),
                          _Fila(label: 'Concepto del cliente', valor: _ventaDemo.concepto ?? '—'),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => DetalleTransaccionComercioScreen(comercioId: widget.comercio.id, venta: _ventaDemo),
                              )),
                              child: const Text('Ver detalle del cobro'),
                            ),
                          ),
                          const SizedBox(height: 9),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => setState(() => _mostrarPago = false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.navy,
                                side: const BorderSide(color: AppColors.border),
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                textStyle: AppTheme.body(size: 13.5, weight: FontWeight.w700),
                              ),
                              child: const Text('Entendido'),
                            ),
                          ),
                        ],
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
  const _Fila({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.body(size: 12, color: AppColors.textDim)),
          Text(valor, style: AppTheme.body(size: 12, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}
