import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/comercio.dart';
import '../../models/invitacion_supervisor.dart';
import '../../repositories/comercios_repository.dart';
import '../../routing/route_observer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../cuentas/cuentas_screen.dart';
import '../inicio/inicio_screen.dart';
import '../pagos/escanear_qr_screen.dart';
import '../perfil/perfil_screen.dart';
import 'habilitar_comercio_screen.dart';
import 'invitaciones_recibidas_screen.dart';
import 'panel_comercio_screen.dart';
import 'panel_supervisor_screen.dart';

class ComerciosScreen extends StatefulWidget {
  const ComerciosScreen({super.key});

  @override
  State<ComerciosScreen> createState() => _ComerciosScreenState();
}

class _ComerciosScreenState extends State<ComerciosScreen> with RouteAware {
  late Future<List<ComercioResumen>> _misComerciosFuture;
  late Future<List<ComercioResumen>> _superviosFuture;
  late Future<List<InvitacionRecibida>> _invitacionesFuture;

  void _cargarDatos() {
    final repo = context.read<ComerciosRepository>();
    _misComerciosFuture = repo.misComercios();
    _superviosFuture = repo.comerciosQueSupervisio();
    _invitacionesFuture = repo.invitacionesPendientes();
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

  void _onTab(AppTab tab) {
    if (tab == AppTab.comercios) return;
    Widget destino;
    switch (tab) {
      case AppTab.inicio:
        destino = const InicioScreen();
        break;
      case AppTab.cuentas:
        destino = const CuentasScreen();
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Comercios', style: AppTheme.display(size: 22)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(13)),
                      child: Text(
                        'Aquí ves los comercios que administras y los que te invitaron a supervisar. '
                        'Administrar y supervisar son permisos por comercio, no cuentas distintas.',
                        style: AppTheme.body(size: 11, color: AppColors.textDim),
                      ),
                    ),
                    const SizedBox(height: 22),
                    FutureBuilder<List<InvitacionRecibida>>(
                      future: _invitacionesFuture,
                      builder: (context, snap) {
                        final invitaciones = snap.data ?? const [];
                        if (invitaciones.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('INVITACIONES PENDIENTES',
                                  style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
                              const SizedBox(height: 10),
                              ...invitaciones.map((inv) => InkWell(
                                    onTap: () => Navigator.of(context)
                                        .push(MaterialPageRoute(builder: (_) => InvitacionesRecibidasScreen(invitacion: inv)))
                                        .then((_) => setState(_cargarDatos)),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(11)),
                                            alignment: Alignment.center,
                                            child: Text(
                                              inv.comercioNombre.substring(0, 2).toUpperCase(),
                                              style: AppTheme.display(size: 13, color: AppColors.greenDark),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(inv.comercioNombre, style: AppTheme.body(size: 13.5, weight: FontWeight.w700)),
                                                Text('${inv.invitadoPorNombre} te invitó como supervisor',
                                                    style: AppTheme.body(size: 11, color: AppColors.textDim)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 16,
                                            height: 16,
                                            decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                                            alignment: Alignment.center,
                                            child: Text('1', style: AppTheme.body(size: 9.5, weight: FontWeight.w700, color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        );
                      },
                    ),
                    _Seccion(
                      titulo: 'Mis comercios',
                      future: _misComerciosFuture,
                      onTap: (c) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PanelComercioScreen(comercioId: c.comercioId))),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => const HabilitarComercioScreen()))
                          .then((_) => setState(_cargarDatos)),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border, width: 1.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_rounded, size: 15, color: AppColors.navy),
                            const SizedBox(width: 8),
                            Text('Habilitar un nuevo comercio', style: AppTheme.body(size: 12.5, weight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _Seccion(
                      titulo: 'Comercios que superviso',
                      future: _superviosFuture,
                      onTap: (c) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PanelSupervisorScreen(comercioId: c.comercioId))),
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
                current: AppTab.comercios,
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

class _Seccion extends StatelessWidget {
  final String titulo;
  final Future<List<ComercioResumen>> future;
  final ValueChanged<ComercioResumen> onTap;
  const _Seccion({required this.titulo, required this.future, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo.toUpperCase(), style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
        const SizedBox(height: 10),
        FutureBuilder<List<ComercioResumen>>(
          future: future,
          builder: (context, snap) {
            if (!snap.hasData) return const SizedBox(height: 50);
            return Column(
              children: snap.data!.map((c) {
                final esAdmin = c.rol == RolComercio.administrador;
                return InkWell(
                  onTap: () => onTap(c),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: esAdmin ? AppColors.navy : Colors.white,
                      border: esAdmin ? null : Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: esAdmin ? AppColors.green : AppColors.cream,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          alignment: Alignment.center,
                          child: Text(c.nombreComercial.substring(0, 2).toUpperCase(),
                              style: AppTheme.display(size: 14, color: esAdmin ? AppColors.surface : AppColors.greenDark)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.nombreComercial,
                                  style: AppTheme.body(size: 14, weight: FontWeight.w700, color: esAdmin ? AppColors.surface : AppColors.navy)),
                              Text('${c.cuentaReceptoraLabel} · Activo',
                                  style: AppTheme.body(size: 11, color: esAdmin ? AppColors.surface.withValues(alpha: 0.55) : AppColors.textDim)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: esAdmin ? AppColors.green.withValues(alpha: 0.3) : AppColors.border,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(esAdmin ? 'Administrador' : 'Solo lectura',
                              style: AppTheme.body(size: 9.5, weight: FontWeight.w700, color: esAdmin ? AppColors.greenLight : AppColors.navy)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
