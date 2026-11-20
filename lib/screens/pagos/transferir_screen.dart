import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cuenta.dart';
import '../../repositories/cuentas_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/idempotency.dart';
import 'comprobante_screen.dart';

class TransferirScreen extends StatefulWidget {
  final String? cuentaOrigenId;
  const TransferirScreen({super.key, this.cuentaOrigenId});

  @override
  State<TransferirScreen> createState() => _TransferirScreenState();
}

class _TransferirScreenState extends State<TransferirScreen> {
  final _clabeCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  late Future<List<Cuenta>> _cuentasFuture;
  String? _cuentaSeleccionada;
  bool _procesando = false;
  String? _error;
  final String _claveIdempotencia = generarClaveIdempotencia();

  @override
  void initState() {
    super.initState();
    _cuentaSeleccionada = widget.cuentaOrigenId;
    _cuentasFuture = context.read<CuentasRepository>().listarCuentas().then((cuentas) {
      _cuentaSeleccionada ??= cuentas.isNotEmpty ? cuentas.first.id : null;
      return cuentas;
    });
  }

  @override
  void dispose() {
    _clabeCtrl.dispose();
    _nombreCtrl.dispose();
    _montoCtrl.dispose();
    super.dispose();
  }

  Future<void> _transferir() async {
    final clabe = _clabeCtrl.text.trim();
    final nombre = _nombreCtrl.text.trim();
    final monto = double.tryParse(_montoCtrl.text.replaceAll(',', '.'));

    // Validación de formato nada más — el checksum real de la CLABE lo hace
    // el banco/Core Financiero destino, no esta app.
    if (clabe.length != 18 || int.tryParse(clabe) == null) {
      setState(() => _error = 'La CLABE debe tener 18 dígitos.');
      return;
    }
    if (nombre.isEmpty) {
      setState(() => _error = 'Ingresa el nombre del destinatario.');
      return;
    }
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
      final mov = await context.read<CuentasRepository>().transferir(
            cuentaId: _cuentaSeleccionada!,
            clabeDestino: clabe,
            nombreDestinatario: nombre,
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
      appBar: AppBar(title: Text('Transferir', style: AppTheme.display(size: 20))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 20),
            Text('CLABE DESTINO', style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
            const SizedBox(height: 8),
            TextField(
              controller: _clabeCtrl,
              keyboardType: TextInputType.number,
              maxLength: 18,
              decoration: const InputDecoration(hintText: '18 dígitos', counterText: ''),
            ),
            const SizedBox(height: 16),
            Text('NOMBRE DEL DESTINATARIO', style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
            const SizedBox(height: 8),
            TextField(controller: _nombreCtrl, decoration: const InputDecoration(hintText: 'Nombre completo')),
            const SizedBox(height: 20),
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
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _procesando ? null : _transferir,
                child: _procesando
                    ? const SizedBox(
                        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Transferir'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
