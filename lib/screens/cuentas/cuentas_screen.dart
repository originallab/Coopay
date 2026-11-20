import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cuenta.dart';
import '../../repositories/cuentas_repository.dart';
import '../../routing/route_observer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/account_card.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../comercios/comercios_screen.dart';
import '../inicio/inicio_screen.dart';
import '../pagos/escanear_qr_screen.dart';
import '../perfil/perfil_screen.dart';
import 'cuenta_detalle_screen.dart';
import 'vincular_cuenta_screen.dart';

class CuentasScreen extends StatefulWidget {
  const CuentasScreen({super.key});

  @override
  State<CuentasScreen> createState() => _CuentasScreenState();
}

class _CuentasScreenState extends State<CuentasScreen> with RouteAware {
  bool _saldosOcultos = false;
  late Future<List<Cuenta>> _cuentasFuture;

  void _cargarCuentas() {
    _cuentasFuture = context.read<CuentasRepository>().listarCuentas();
  }

  @override
  void initState() {
    super.initState();
    _cargarCuentas();
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
  void didPopNext() => setState(_cargarCuentas);

  void _onTab(AppTab tab) {
    if (tab == AppTab.cuentas) return;
    Widget destino;
    switch (tab) {
      case AppTab.inicio:
        destino = const InicioScreen();
        break;
      case AppTab.comercios:
        destino = const ComerciosScreen();
        break;
      case AppTab.perfil:
        destino = const PerfilScreen();
        break;
      default:
        return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => destino));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
              child: FutureBuilder<List<Cuenta>>(
                future: _cuentasFuture,
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final cuentas = snap.data!;
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cuentas', style: AppTheme.display(size: 22)),
                        const SizedBox(height: 18),
                        for (var i = 0; i < cuentas.length; i++) ...[
                          AccountCard(
                            cuenta: cuentas[i],
                            oculto: _saldosOcultos,
                            esSecundaria: i == 1,
                            onToggleOculto: () => setState(() => _saldosOcultos = !_saldosOcultos),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => CuentaDetalleScreen(cuentaId: cuentas[i].id)),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        const SizedBox(height: 10),
                        _VincularOtraCuenta(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const VincularCuentaScreen()),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 4,
              child: BottomNavBar(
                current: AppTab.cuentas,
                onTabSelected: _onTab,
                onScanTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EscanearQrScreen())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VincularOtraCuenta extends StatelessWidget {
  final VoidCallback onTap;
  const _VincularOtraCuenta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1.5, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, size: 15, color: AppColors.navy),
            const SizedBox(width: 8),
            Text('Vincular otra cuenta de ahorro', style: AppTheme.body(size: 12.5, weight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
