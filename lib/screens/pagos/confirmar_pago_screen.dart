import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cuenta.dart';
import '../../repositories/cuentas_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/idempotency.dart';
import 'comprobante_screen.dart';

class ConfirmarPagoScreen extends StatefulWidget {
  final String comercioNombre;
  const ConfirmarPagoScreen({super.key, required this.comercioNombre});

  @override
  State<ConfirmarPagoScreen> createState() => _ConfirmarPagoScreenState();
}

class _ConfirmarPagoScreenState extends State<ConfirmarPagoScreen> {
  final _montoCtrl = TextEditingController();
  late Future<List<Cuenta>> _cuentasFuture;
  String? _cuentaSeleccionada;
  bool _procesando = false;
  String? _error;

  // Generada una sola vez por pantalla: si el pago falla y el socio vuelve a
  // tocar "Pagar", se reenvía la MISMA clave (nunca cobrar dos veces por
  // reintento — playbook 03-seguridad.md punto 13).
  final String _claveIdempotencia = generarClaveIdempotencia();

  @override
  void initState() {
    super.initState();
    _cuentasFuture = context.read<CuentasRepository>().listarCuentas().then((cuentas) {
      if (cuentas.isNotEmpty) _cuentaSeleccionada = cuentas.first.id;
      return cuentas;
    });
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pagar() async {
    final monto = double.tryParse(_montoCtrl.text.replaceAll(',', '.'));
    if (monto == null || monto <= 0) {
      setState(() => _error = 'Ingresa un monto válido.');
      return;
    }
    if (_cuentaSeleccionada == null) return;
    setState(() {
      _procesando = true;
      _error = null;
    });
    try {
      final mov = await context.read<CuentasRepository>().pagarConQr(
            cuentaId: _cuentaSeleccionada!,
            comercioNombre: widget.comercioNombre,
            monto: monto,
            claveIdempotencia: _claveIdempotencia,
          );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ComprobanteScreen(movimiento: mov)));
    } on SaldoInsuficienteException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Confirmar pago', style: AppTheme.display(size: 20))),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vas a pagarle a', style: AppTheme.body(size: 12.5, color: AppColors.textDim)),
            Text(widget.comercioNombre, style: AppTheme.display(size: 20)),
            const SizedBox(height: 22),
            Text('DESDE', style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
            const SizedBox(height: 8),
            FutureBuilder<List<Cuenta>>(
              future: _cuentasFuture,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()));
                }
                final cuentas = snap.data!;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(999)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _cuentaSeleccionada,
                      isExpanded: true,
                      items: cuentas
                          .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text('${c.institucionNombre} · ····${c.ultimosDigitos}',
                                    style: AppTheme.body(size: 13.5, weight: FontWeight.w600)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _cuentaSeleccionada = v),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),
            Text('MONTO', style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
            const SizedBox(height: 8),
            TextField(
              controller: _montoCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTheme.display(size: 26),
              decoration: const InputDecoration(prefixText: '\$ ', hintText: '0.00'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: AppTheme.body(size: 12.5, color: AppColors.danger, weight: FontWeight.w600)),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _procesando ? null : _pagar,
                child: _procesando
                    ? const SizedBox(
                        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Pagar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
