import 'package:flutter/material.dart';
import '../../models/movimiento.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/fecha.dart';

/// Comprobante de operación — compartido entre Pagar QR y Transferir (ambos
/// terminan en un Movimiento, así que la pantalla de éxito es la misma).
class ComprobanteScreen extends StatelessWidget {
  final Movimiento movimiento;
  const ComprobanteScreen({super.key, required this.movimiento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 18),
              Text('¡Listo!', style: AppTheme.display(size: 24)),
              const SizedBox(height: 4),
              Text(
                movimiento.canal == CanalMovimiento.pagoQr ? 'Pago enviado' : 'Transferencia enviada',
                style: AppTheme.body(size: 13, color: AppColors.textDim),
              ),
              const SizedBox(height: 24),
              Text('\$${movimiento.monto.toStringAsFixed(2)}', style: AppTheme.display(size: 34)),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    _Fila(label: 'Para', valor: movimiento.contraparteNombre ?? '—'),
                    _Fila(label: 'Concepto', valor: movimiento.concepto ?? '—'),
                    _Fila(label: 'Folio', valor: movimiento.id),
                    _Fila(label: 'Fecha', valor: formatoFechaHora(movimiento.createdAt), ultima: true),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('Listo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  final String label;
  final String valor;
  final bool ultima;
  const _Fila({required this.label, required this.valor, this.ultima = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: ultima ? 0 : 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.body(size: 13, color: AppColors.textDim)),
          Flexible(
            child: Text(valor, textAlign: TextAlign.right, style: AppTheme.body(size: 13.5, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
