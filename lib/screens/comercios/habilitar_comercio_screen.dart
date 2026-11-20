import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/comercio.dart';
import '../../models/cuenta.dart';
import '../../repositories/comercios_repository.dart';
import '../../repositories/cuentas_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'panel_comercio_screen.dart';

enum _PasoHabilitar { cuenta, datos, confirmar, listo }

class HabilitarComercioScreen extends StatefulWidget {
  const HabilitarComercioScreen({super.key});

  @override
  State<HabilitarComercioScreen> createState() => _HabilitarComercioScreenState();
}

class _HabilitarComercioScreenState extends State<HabilitarComercioScreen> {
  _PasoHabilitar _paso = _PasoHabilitar.cuenta;
  late Future<List<Cuenta>> _cuentasFuture;
  String? _cuentaId;

  final _nombreCtrl = TextEditingController();
  final _razonSocialCtrl = TextEditingController();
  final _rfcCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  static const _giro = 'Abarrotes y supermercado';

  bool _aceptaTerminos = false;
  bool _enviando = false;
  ComercioResumen? _resultado;

  @override
  void initState() {
    super.initState();
    _cuentasFuture = context.read<CuentasRepository>().listarCuentas().then((cuentas) {
      if (cuentas.isNotEmpty) _cuentaId = cuentas.first.id;
      return cuentas;
    });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _razonSocialCtrl.dispose();
    _rfcCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  int get _pasoNum => switch (_paso) {
        _PasoHabilitar.cuenta => 1,
        _PasoHabilitar.datos => 2,
        _PasoHabilitar.confirmar => 3,
        _PasoHabilitar.listo => 3,
      };

  Future<void> _avanzar(List<Cuenta> cuentas) async {
    if (_paso == _PasoHabilitar.cuenta) {
      setState(() => _paso = _PasoHabilitar.datos);
    } else if (_paso == _PasoHabilitar.datos) {
      setState(() => _paso = _PasoHabilitar.confirmar);
    } else if (_paso == _PasoHabilitar.confirmar && _aceptaTerminos) {
      final cuenta = cuentas.firstWhere((c) => c.id == _cuentaId);
      setState(() => _enviando = true);
      final resumen = await context.read<ComerciosRepository>().habilitarComercio(
            cuentaReceptoraLabel: '${cuenta.institucionNombre} · ····${cuenta.ultimosDigitos}',
            nombreComercial: _nombreCtrl.text.trim().isEmpty ? 'Mi comercio' : _nombreCtrl.text.trim(),
            razonSocial: _razonSocialCtrl.text.trim(),
            rfc: _rfcCtrl.text.trim(),
            giro: _giro,
            direccion: _direccionCtrl.text.trim(),
          );
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _resultado = resumen;
        _paso = _PasoHabilitar.listo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_paso == _PasoHabilitar.listo && _resultado != null) {
      final r = _resultado!;
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
                        child: const Icon(Icons.check_rounded, size: 38, color: AppColors.greenDark),
                      ),
                      const SizedBox(height: 16),
                      Text('Comercio activo', style: AppTheme.display(size: 21)),
                      const SizedBox(height: 8),
                      Text(
                        '${r.nombreComercial} ya puede cobrar. Se te asignó automáticamente el rol de administrador sobre ${r.cuentaReceptoraLabel}.',
                        textAlign: TextAlign.center,
                        style: AppTheme.body(size: 13, color: AppColors.textDim),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
                        child: Column(
                          children: [
                            _FilaResumen('Comercio', r.nombreComercial),
                            _FilaResumen('Cuenta receptora', r.cuentaReceptoraLabel),
                            const _FilaResumen('Tu rol', 'Administrador', ultima: true, valorColor: AppColors.greenDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => PanelComercioScreen(comercioId: r.comercioId)),
                    ),
                    child: const Text('Ir a mi comercio'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<Cuenta>>(
          future: _cuentasFuture,
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final cuentas = snap.data!;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: AppColors.navy),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Row(
                          children: List.generate(3, (i) {
                            final activo = _pasoNum >= i + 1;
                            return Expanded(
                              child: Container(
                                margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                                height: 5,
                                decoration: BoxDecoration(color: activo ? AppColors.green : AppColors.border, borderRadius: BorderRadius.circular(999)),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('Paso $_pasoNum de 3', style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
                    child: switch (_paso) {
                      _PasoHabilitar.cuenta => _PasoCuenta(cuentas: cuentas, seleccionado: _cuentaId, onSelect: (id) => setState(() => _cuentaId = id)),
                      _PasoHabilitar.datos => _PasoDatos(
                          nombreCtrl: _nombreCtrl,
                          razonSocialCtrl: _razonSocialCtrl,
                          rfcCtrl: _rfcCtrl,
                          direccionCtrl: _direccionCtrl,
                          giro: _giro,
                        ),
                      _PasoHabilitar.confirmar => _PasoConfirmar(
                          cuentaLabel: cuentas.isEmpty
                              ? ''
                              : '${cuentas.firstWhere((c) => c.id == _cuentaId).institucionNombre} · ····${cuentas.firstWhere((c) => c.id == _cuentaId).ultimosDigitos}',
                          acepta: _aceptaTerminos,
                          onToggle: () => setState(() => _aceptaTerminos = !_aceptaTerminos),
                        ),
                      _PasoHabilitar.listo => const SizedBox.shrink(),
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_paso == _PasoHabilitar.confirmar && !_aceptaTerminos) || _enviando ? null : () => _avanzar(cuentas),
                      child: _enviando
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(_paso == _PasoHabilitar.confirmar ? 'Habilitar comercio' : 'Continuar'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PasoCuenta extends StatelessWidget {
  final List<Cuenta> cuentas;
  final String? seleccionado;
  final ValueChanged<String> onSelect;
  const _PasoCuenta({required this.cuentas, required this.seleccionado, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Elige la cuenta receptora', style: AppTheme.display(size: 19)),
        const SizedBox(height: 4),
        Text('Solo puedes habilitar un comercio sobre una cuenta propia validada por tu caja.',
            style: AppTheme.body(size: 11.5, color: AppColors.textDim)),
        const SizedBox(height: 16),
        ...cuentas.map((c) {
          final activo = c.id == seleccionado;
          return InkWell(
            onTap: () => onSelect(c.id),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${c.institucionNombre} · ${c.producto}', style: AppTheme.body(size: 13.5, weight: FontWeight.w700)),
                        Text('····${c.ultimosDigitos} · Titular validado', style: AppTheme.body(size: 10.5, color: AppColors.textDim)),
                      ],
                    ),
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: activo ? AppColors.green : AppColors.border, width: 2)),
                    alignment: Alignment.center,
                    child: activo ? Container(width: 9, height: 9, decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle)) : null,
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(13)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.greenDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Ya eres titular validado de ambas cuentas, así que no necesitas repetir la verificación de identidad.',
                    style: AppTheme.body(size: 11, color: AppColors.greenDark)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PasoDatos extends StatelessWidget {
  final TextEditingController nombreCtrl;
  final TextEditingController razonSocialCtrl;
  final TextEditingController rfcCtrl;
  final TextEditingController direccionCtrl;
  final String giro;
  const _PasoDatos({
    required this.nombreCtrl,
    required this.razonSocialCtrl,
    required this.rfcCtrl,
    required this.direccionCtrl,
    required this.giro,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(11)),
              child: const Icon(Icons.receipt_long_rounded, size: 18, color: AppColors.greenDark),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Datos del comercio', style: AppTheme.display(size: 19)),
                  Text('Así aparecerán en los cobros de tus clientes.', style: AppTheme.body(size: 11.5, color: AppColors.textDim)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('NOMBRE COMERCIAL', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.textDim)),
        const SizedBox(height: 6),
        TextField(controller: nombreCtrl, decoration: const InputDecoration(hintText: 'Ej. Tienda CoopMarket')),
        const SizedBox(height: 14),
        Text('RAZÓN SOCIAL', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.textDim)),
        const SizedBox(height: 6),
        TextField(controller: razonSocialCtrl, decoration: const InputDecoration(hintText: 'Nombre legal del negocio')),
        const SizedBox(height: 14),
        Text('RFC', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.textDim)),
        const SizedBox(height: 6),
        TextField(controller: rfcCtrl, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(hintText: '12 o 13 caracteres')),
        const SizedBox(height: 14),
        Text('GIRO DEL NEGOCIO', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.textDim)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(13)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(giro, style: AppTheme.body(size: 13)),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textDim),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text('DIRECCIÓN DEL ESTABLECIMIENTO', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.textDim)),
        const SizedBox(height: 6),
        TextField(controller: direccionCtrl, decoration: const InputDecoration(hintText: 'Calle, número, colonia, ciudad')),
      ],
    );
  }
}

class _PasoConfirmar extends StatelessWidget {
  final String cuentaLabel;
  final bool acepta;
  final VoidCallback onToggle;
  const _PasoConfirmar({required this.cuentaLabel, required this.acepta, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Revisa y confirma', style: AppTheme.display(size: 19)),
        const SizedBox(height: 4),
        Text('Tu caja de ahorro puede revisar estos datos antes de activar cobros.', style: AppTheme.body(size: 11.5, color: AppColors.textDim)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              _FilaResumen('Cuenta receptora', cuentaLabel),
              const _FilaResumen('Titular', 'Nicolás Ibarra'),
              const _FilaResumen('Tu rol', 'Administrador', ultima: true, valorColor: AppColors.greenDark),
            ],
          ),
        ),
        const SizedBox(height: 14),
        InkWell(
          onTap: onToggle,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: acepta ? AppColors.green : Colors.transparent,
                  border: Border.all(color: acepta ? AppColors.green : AppColors.border, width: 1.5),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: acepta ? const Icon(Icons.check_rounded, size: 13, color: Colors.white) : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Acepto los términos de servicio para comercios y confirmo que soy el titular autorizado de esta cuenta.',
                    style: AppTheme.body(size: 11.5, color: AppColors.textDim)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(13)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.navy),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Habilitar este comercio no cambia la titularidad de tu cuenta de ahorro; solo autoriza que reciba cobros.',
                    style: AppTheme.body(size: 10.5, color: AppColors.navy)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilaResumen extends StatelessWidget {
  final String label;
  final String valor;
  final bool ultima;
  final Color? valorColor;
  const _FilaResumen(this.label, this.valor, {this.ultima = false, this.valorColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: ultima ? 0 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.body(size: 12.5, color: AppColors.textDim)),
          Text(valor, style: AppTheme.body(size: 12.5, weight: FontWeight.w700, color: valorColor ?? AppColors.navy)),
        ],
      ),
    );
  }
}
