import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/comercio.dart';
import '../../models/cuenta.dart';
import '../../repositories/comercios_repository.dart';
import '../../repositories/cuentas_repository.dart';
import '../../repositories/notificaciones_repository.dart';
import '../../routing/route_observer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/account_card.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../comercios/comercios_screen.dart';
import '../comercios/panel_comercio_screen.dart';
import '../comercios/panel_supervisor_screen.dart';
import '../cuentas/cuenta_detalle_screen.dart';
import '../cuentas/cuentas_screen.dart';
import '../notificaciones/notificaciones_screen.dart';
import '../pagos/escanear_qr_screen.dart';
import '../pagos/transferir_screen.dart';
import '../perfil/perfil_screen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> with RouteAware {
  bool _saldosOcultos = false;
  late Future<List<Cuenta>> _cuentasFuture;
  late Future<List<ComercioResumen>> _misComerciosFuture;
  late Future<List<ComercioResumen>> _superviosFuture;
  late Future<int> _noLeidasFuture;

  void _cargarDatos() {
    _cuentasFuture = context.read<CuentasRepository>().listarCuentas();
    _misComerciosFuture = context.read<ComerciosRepository>().misComercios();
    _superviosFuture = context.read<ComerciosRepository>().comerciosQueSupervisio();
    _noLeidasFuture = context.read<NotificacionesRepository>().contarNoLeidas();
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

  // Al volver de pagar/transferir/ver notificaciones hay que refrescar — si
  // no, Inicio sigue mostrando el saldo y el badge de antes de la acción.
  @override
  void didPopNext() => setState(_cargarDatos);

  void _irA(Widget pantalla) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => pantalla));

  void _onTab(AppTab tab) {
    switch (tab) {
      case AppTab.inicio:
        return;
      case AppTab.cuentas:
        _irA(const CuentasScreen());
        return;
      case AppTab.comercios:
        _irA(const ComerciosScreen());
        return;
      case AppTab.perfil:
        _irA(const PerfilScreen());
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hola,', style: AppTheme.body(size: 13, color: AppColors.textDim)),
                            Text('Nicolás Ibarra', style: AppTheme.display(size: 23)),
                          ],
                        ),
                        FutureBuilder<int>(
                          future: _noLeidasFuture,
                          builder: (context, snap) => _NotificationBell(
                            tieneNoLeidas: (snap.data ?? 0) > 0,
                            onTap: () => _irA(const NotificacionesScreen()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 190,
                      child: FutureBuilder<List<Cuenta>>(
                        future: _cuentasFuture,
                        builder: (context, snap) {
                          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                          final cuentas = snap.data!;
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: cuentas.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 14),
                            itemBuilder: (context, i) {
                              final cuenta = cuentas[i];
                              return AccountCard(
                                cuenta: cuenta,
                                oculto: _saldosOcultos,
                                esSecundaria: i == 1,
                                onToggleOculto: () => setState(() => _saldosOcultos = !_saldosOcultos),
                                onTap: () => _irA(CuentaDetalleScreen(cuentaId: cuenta.id)),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.qr_code_scanner_rounded,
                            label: 'Pagar QR',
                            onTap: () => _irA(const EscanearQrScreen()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.sync_alt_rounded,
                            label: 'Transferir',
                            onTap: () => _irA(const TransferirScreen()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _SeccionComercios(
                      titulo: 'Mis comercios',
                      future: _misComerciosFuture,
                      verTodos: () => _irA(const ComerciosScreen()),
                    ),
                    const SizedBox(height: 18),
                    _SeccionComercios(
                      titulo: 'Comercios que superviso',
                      future: _superviosFuture,
                      verTodos: () => _irA(const ComerciosScreen()),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 4,
              child: BottomNavBar(
                current: AppTab.inicio,
                onTabSelected: _onTab,
                onScanTap: () => _irA(const EscanearQrScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final bool tieneNoLeidas;
  final VoidCallback onTap;
  const _NotificationBell({required this.tieneNoLeidas, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none_rounded, color: AppColors.navy, size: 19),
          ),
          if (tieneNoLeidas)
            Positioned(
              right: 2,
              top: 2,
              child: Container(width: 9, height: 9, decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle)),
            ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: AppColors.navy, size: 22),
          ),
          const SizedBox(height: 7),
          Text(label, style: AppTheme.body(size: 11.5, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SeccionComercios extends StatelessWidget {
  final String titulo;
  final Future<List<ComercioResumen>> future;
  final VoidCallback verTodos;

  const _SeccionComercios({required this.titulo, required this.future, required this.verTodos});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(titulo.toUpperCase(),
                style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
            GestureDetector(
              onTap: verTodos,
              child: Text('Ver todos', style: AppTheme.body(size: 12, weight: FontWeight.w700, color: AppColors.greenDark)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<ComercioResumen>>(
          future: future,
          builder: (context, snap) {
            if (!snap.hasData) return const SizedBox(height: 60);
            if (snap.data!.isEmpty) return const SizedBox.shrink();
            final c = snap.data!.first;
            final esAdmin = c.rol == RolComercio.administrador;
            return InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => esAdmin ? PanelComercioScreen(comercioId: c.comercioId) : PanelSupervisorScreen(comercioId: c.comercioId),
              )),
              borderRadius: BorderRadius.circular(16),
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: esAdmin ? AppColors.navy : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: esAdmin ? null : Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: esAdmin ? AppColors.green : AppColors.cream,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      c.nombreComercial.substring(0, 2).toUpperCase(),
                      style: AppTheme.display(size: 13, color: esAdmin ? AppColors.surface : AppColors.greenDark),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.nombreComercial,
                            style: AppTheme.body(size: 13.5, weight: FontWeight.w700, color: esAdmin ? AppColors.surface : AppColors.navy)),
                        Text('${c.cuentaReceptoraLabel} · Activo',
                            style: AppTheme.body(
                                size: 11, color: esAdmin ? AppColors.surface.withValues(alpha: 0.55) : AppColors.textDim)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: esAdmin ? AppColors.green.withValues(alpha: 0.3) : AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      esAdmin ? 'Administrador' : 'Supervisor',
                      style: AppTheme.body(size: 9.5, weight: FontWeight.w700, color: esAdmin ? AppColors.greenLight : AppColors.navy),
                    ),
                  ),
                ],
              ),
              ),
            );
          },
        ),
      ],
    );
  }
}
