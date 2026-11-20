import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'confirmar_pago_screen.dart';

/// Pantalla de "escanear QR" simulada — todavía no hay integración de cámara
/// ni decodificador de QR real, así que el "escaneo" es elegir un comercio
/// de esta lista de demo (no se limita a los comercios que administras:
/// cualquier socio puede pagarle a cualquier comercio con QR).
class EscanearQrScreen extends StatelessWidget {
  const EscanearQrScreen({super.key});

  static const _comerciosDemo = [
    'Tienda CoopMarket',
    'Farmacia Norte',
    'Café Aroma',
    'Papelería Lupita',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pagar con QR', style: AppTheme.display(size: 20))),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(24)),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_scanner_rounded, color: AppColors.cream, size: 44),
                  const SizedBox(height: 10),
                  Text('Apunta al código QR del comercio',
                      style: AppTheme.body(size: 12.5, color: AppColors.cream.withValues(alpha: 0.75))),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('DEMO — SIN CÁMARA TODAVÍA',
                style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.textDim)),
            const SizedBox(height: 4),
            Text('Toca un comercio para simular que ya se escaneó su QR.',
                style: AppTheme.body(size: 12, color: AppColors.textDim)),
            const SizedBox(height: 14),
            ..._comerciosDemo.map((nombre) => _ComercioTile(
                  nombre: nombre,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ConfirmarPagoScreen(comercioNombre: nombre)),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _ComercioTile extends StatelessWidget {
  final String nombre;
  final VoidCallback onTap;
  const _ComercioTile({required this.nombre, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(11)),
              alignment: Alignment.center,
              child:
                  Text(nombre.substring(0, 2).toUpperCase(), style: AppTheme.display(size: 13, color: AppColors.greenDark)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(nombre, style: AppTheme.body(size: 13.5, weight: FontWeight.w700))),
            const Icon(Icons.qr_code_rounded, size: 18, color: AppColors.textDim),
          ],
        ),
      ),
    );
  }
}
