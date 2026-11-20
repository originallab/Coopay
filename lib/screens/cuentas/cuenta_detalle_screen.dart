import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cuenta.dart';
import '../../models/movimiento.dart';
import '../../repositories/cuentas_repository.dart';
import '../../routing/route_observer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../pagos/transferir_screen.dart';

class CuentaDetalleScreen extends StatefulWidget {
  final String cuentaId;
  const CuentaDetalleScreen({super.key, required this.cuentaId});

  @override
  State<CuentaDetalleScreen> createState() => _CuentaDetalleScreenState();
}

class _CuentaDetalleScreenState extends State<CuentaDetalleScreen> with RouteAware {
  bool _saldoOculto = false;
  bool _numeroRevelado = false;
  bool _clabeRevelada = false;
  late Future<Cuenta> _cuentaFuture;
  late Future<List<Movimiento>> _movimientosFuture;
  final _movimientosKey = GlobalKey();

  void _cargarDatos() {
    final repo = context.read<CuentasRepository>();
    _cuentaFuture = repo.obtenerCuenta(widget.cuentaId);
    _movimientosFuture = repo.movimientosDeCuenta(widget.cuentaId);
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

  void _compartirCuenta() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Compartido!')));
  }

  void _irAMovimientos() {
    final ctx = _movimientosKey.currentContext;
    if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle de cuenta', style: AppTheme.display(size: 20))),
      body: FutureBuilder<Cuenta>(
        future: _cuentaFuture,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final cuenta = snap.data!;
          final esSecundaria = !cuenta.esPrincipal;
          final saldoTexto = _saldoOculto ? '••••••' : '\$${cuenta.saldoDisponible.toStringAsFixed(2)}';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: esSecundaria ? AppColors.greenDark : AppColors.navy,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(999)),
                            child: Text(cuenta.institucionNombre,
                                style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.greenLight)),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _saldoOculto = !_saldoOculto),
                            icon: Icon(_saldoOculto ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                size: 18, color: AppColors.cream),
                          ),
                        ],
                      ),
                      Text('${cuenta.producto} · ····${cuenta.ultimosDigitos}',
                          style: AppTheme.body(size: 12, color: AppColors.cream.withValues(alpha: 0.62))),
                      const SizedBox(height: 5),
                      Text(saldoTexto, style: AppTheme.display(size: 32, color: AppColors.surface)),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                        decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(999)),
                        child: Text('Cuenta activa', style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.greenLight)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _Accion(
                        icon: Icons.sync_alt_rounded,
                        label: 'Transferir',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => TransferirScreen(cuentaOrigenId: cuenta.id)),
                        ),
                      ),
                    ),
                    Expanded(child: _Accion(icon: Icons.ios_share_rounded, label: 'Compartir cuenta', onTap: _compartirCuenta)),
                    Expanded(child: _Accion(icon: Icons.receipt_long_rounded, label: 'Movimientos', onTap: _irAMovimientos)),
                  ],
                ),
                const SizedBox(height: 20),
                Text('DETALLES DE LA CUENTA', style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      _FilaDetalle(label: 'Institución', valor: cuenta.institucionNombre),
                      _FilaDetalle(label: 'Producto', valor: cuenta.producto),
                      _FilaDetalle(
                        label: 'Número de cuenta',
                        valor: _numeroRevelado ? cuenta.numeroCuenta : '···· ···· ···· ${cuenta.ultimosDigitos}',
                        onTap: () => setState(() => _numeroRevelado = !_numeroRevelado),
                      ),
                      _FilaDetalle(
                        label: 'CLABE interbancaria',
                        valor: _clabeRevelada ? cuenta.clabe : '···· ···· ·· ${cuenta.clabe.substring(cuenta.clabe.length - 3)}',
                        onTap: () => setState(() => _clabeRevelada = !_clabeRevelada),
                        ultima: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('MOVIMIENTOS DE ESTA CUENTA',
                    key: _movimientosKey,
                    style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
                const SizedBox(height: 10),
                FutureBuilder<List<Movimiento>>(
                  future: _movimientosFuture,
                  builder: (context, movSnap) {
                    if (!movSnap.hasData) return const SizedBox(height: 40);
                    return Column(
                      children: movSnap.data!
                          .map((m) => _FilaMovimiento(movimiento: m))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Accion extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Accion({required this.icon, required this.label, required this.onTap});

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
            child: Icon(icon, color: AppColors.navy, size: 20),
          ),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, style: AppTheme.body(size: 11, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _FilaDetalle extends StatelessWidget {
  final String label;
  final String valor;
  final VoidCallback? onTap;
  final bool ultima;
  const _FilaDetalle({required this.label, required this.valor, this.onTap, this.ultima = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: ultima ? 0 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.body(size: 13, color: AppColors.textDim)),
          InkWell(
            onTap: onTap,
            child: Row(
              children: [
                Text(valor, style: AppTheme.body(size: 13.5, weight: FontWeight.w700)),
                if (onTap != null) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.remove_red_eye_outlined, size: 13, color: AppColors.textDim),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaMovimiento extends StatelessWidget {
  final Movimiento movimiento;
  const _FilaMovimiento({required this.movimiento});

  @override
  Widget build(BuildContext context) {
    final signo = movimiento.esIngreso ? '+' : '-';
    final color = movimiento.esIngreso ? AppColors.greenDark : AppColors.navy;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              (movimiento.contraparteNombre ?? '??').substring(0, 2).toUpperCase(),
              style: AppTheme.body(size: 13, weight: FontWeight.w700, color: AppColors.greenDark),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movimiento.contraparteNombre ?? movimiento.concepto ?? '—',
                    style: AppTheme.body(size: 14, weight: FontWeight.w600)),
                Text(movimiento.concepto ?? '', style: AppTheme.body(size: 12, color: AppColors.textDim)),
              ],
            ),
          ),
          Text('$signo\$${movimiento.monto.toStringAsFixed(2)}',
              style: AppTheme.body(size: 14, weight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
