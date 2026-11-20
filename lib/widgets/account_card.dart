import 'package:flutter/material.dart';
import '../models/cuenta.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Misma tarjeta que `CuentaHipodromo.dc.html`/`Main.dc.html` del prototipo:
/// fondo navy o verde oscuro según la institución, saldo grande, pill de
/// "Cuenta activa". `oculto` la controla quien la usa (Inicio comparte un
/// solo estado de "ocultar saldos" entre las dos tarjetas).
class AccountCard extends StatelessWidget {
  final Cuenta cuenta;
  final bool oculto;
  final VoidCallback onToggleOculto;
  final VoidCallback onTap;
  final bool esSecundaria; // true = fondo verde oscuro (Caja Genera)

  const AccountCard({
    super.key,
    required this.cuenta,
    required this.oculto,
    required this.onToggleOculto,
    required this.onTap,
    this.esSecundaria = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = esSecundaria ? AppColors.greenDark : AppColors.navy;
    final badgeFg = esSecundaria ? AppColors.cream : AppColors.greenLight;
    final saldoTexto = oculto
        ? '••••••'
        : '\$${cuenta.saldoDisponible.toStringAsFixed(2).replaceAllMapped(
              RegExp(r'\B(?=(\d{3})+(?!\d)(?=\.))'),
              (m) => ',',
            )}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 282,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    cuenta.institucionNombre,
                    style: AppTheme.body(size: 11, weight: FontWeight.w700, color: badgeFg),
                  ),
                ),
                IconButton(
                  onPressed: onToggleOculto,
                  icon: Icon(oculto ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 18, color: AppColors.cream),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              '${cuenta.producto} · ····${cuenta.ultimosDigitos}',
              style: AppTheme.body(size: 12, weight: FontWeight.w500, color: AppColors.cream.withValues(alpha: 0.62)),
            ),
            const SizedBox(height: 5),
            Text(saldoTexto, style: AppTheme.display(size: 32, color: AppColors.surface)),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.greenLight, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('Cuenta activa', style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.greenLight)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
