import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppTab { inicio, cuentas, comercios, perfil }

/// Misma barra "liquid glass" navy del prototipo: 4 destinos + el botón de
/// escanear QR elevado al centro. Vive en `widgets/` (no en `screens/`)
/// porque la usan varias pantallas de nivel raíz.
class BottomNavBar extends StatelessWidget {
  final AppTab current;
  final ValueChanged<AppTab> onTabSelected;
  final VoidCallback onScanTap;

  const BottomNavBar({
    super.key,
    required this.current,
    required this.onTabSelected,
    required this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(color: AppColors.navy.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_rounded, label: 'Inicio', active: current == AppTab.inicio, onTap: () => onTabSelected(AppTab.inicio)),
          _NavItem(icon: Icons.credit_card_rounded, label: 'Cuentas', active: current == AppTab.cuentas, onTap: () => onTabSelected(AppTab.cuentas)),
          _ScanButton(onTap: onScanTap),
          _NavItem(icon: Icons.storefront_rounded, label: 'Comercios', active: current == AppTab.comercios, onTap: () => onTabSelected(AppTab.comercios)),
          _NavItem(icon: Icons.person_rounded, label: 'Perfil', active: current == AppTab.perfil, onTap: () => onTabSelected(AppTab.perfil)),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.greenLight : AppColors.cream;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 54,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppColors.greenLight.withValues(alpha: 0.18) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 19, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ScanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 54,
        height: 54,
        margin: const EdgeInsets.only(top: -20),
        decoration: BoxDecoration(
          color: AppColors.navy,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.65), width: 1.5),
          boxShadow: [BoxShadow(color: AppColors.navy.withValues(alpha: 0.22), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.cream, size: 22),
      ),
    );
  }
}
