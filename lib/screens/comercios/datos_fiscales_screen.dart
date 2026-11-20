import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/comercio.dart';
import '../../repositories/comercios_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class DatosFiscalesScreen extends StatefulWidget {
  final String comercioId;
  const DatosFiscalesScreen({super.key, required this.comercioId});

  @override
  State<DatosFiscalesScreen> createState() => _DatosFiscalesScreenState();
}

class _DatosFiscalesScreenState extends State<DatosFiscalesScreen> {
  late Future<ComercioDetalle> _comercioFuture;
  final _razonSocialCtrl = TextEditingController();
  final _rfcCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();

  static const _regimenes = [
    '601 · General de Ley Personas Morales',
    '603 · Personas Morales con Fines no Lucrativos',
    '612 · Personas Físicas con Actividad Empresarial',
    '626 · Régimen Simplificado de Confianza (RESICO)',
  ];
  String _regimen = _regimenes.first;
  bool _regimenAbierto = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _comercioFuture = context.read<ComerciosRepository>().obtenerComercio(widget.comercioId).then((c) {
      _razonSocialCtrl.text = c.razonSocial;
      _rfcCtrl.text = c.rfc;
      _direccionCtrl.text = c.direccion;
      return c;
    });
  }

  @override
  void dispose() {
    _razonSocialCtrl.dispose();
    _rfcCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    await context.read<ComerciosRepository>().actualizarDatosFiscales(
          widget.comercioId,
          razonSocial: _razonSocialCtrl.text.trim(),
          rfc: _rfcCtrl.text.trim(),
          direccion: _direccionCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() => _guardando = false);
    _mostrarConfirmacion();
  }

  void _mostrarConfirmacion() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.greenDark, size: 32),
            ),
            const SizedBox(height: 14),
            Text('Cambios guardados', style: AppTheme.display(size: 19)),
            const SizedBox(height: 6),
            Text('Actualizamos los datos de ${_razonSocialCtrl.text}.',
                textAlign: TextAlign.center, style: AppTheme.body(size: 12.5, color: AppColors.textDim)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Volver al panel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<ComercioDetalle>(
          future: _comercioFuture,
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Datos fiscales y del negocio', style: AppTheme.display(size: 18)),
                            Text('Solo el administrador puede editarlos.', style: AppTheme.body(size: 11, color: AppColors.textDim)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RAZÓN SOCIAL', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.textDim)),
                        const SizedBox(height: 6),
                        TextField(controller: _razonSocialCtrl),
                        const SizedBox(height: 16),
                        Text('RFC', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.textDim)),
                        const SizedBox(height: 6),
                        TextField(controller: _rfcCtrl, textCapitalization: TextCapitalization.characters),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text('Se escribe en mayúsculas, sin espacios ni guiones', style: AppTheme.body(size: 10, color: AppColors.textDim)),
                        ),
                        const SizedBox(height: 16),
                        Text('DIRECCIÓN FISCAL', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.textDim)),
                        const SizedBox(height: 6),
                        TextField(controller: _direccionCtrl),
                        const SizedBox(height: 16),
                        Text('RÉGIMEN FISCAL', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.textDim)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => setState(() => _regimenAbierto = !_regimenAbierto),
                          borderRadius: BorderRadius.circular(13),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(13)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(_regimen, style: AppTheme.body(size: 13))),
                                Icon(_regimenAbierto ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textDim),
                              ],
                            ),
                          ),
                        ),
                        if (_regimenAbierto)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(13)),
                            child: Column(
                              children: _regimenes
                                  .map((r) => InkWell(
                                        onTap: () => setState(() {
                                          _regimen = r;
                                          _regimenAbierto = false;
                                        }),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                          child: Text(r, style: AppTheme.body(size: 12)),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Text('CATEGORÍA DEL COMERCIO', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.textDim)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(13)),
                          child: Text(snap.data!.giro, style: AppTheme.body(size: 13)),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                          decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(13)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.greenDark),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Si cambias el RFC o la razón social, tu caja de ahorro revisará los datos antes de aplicar el cambio en tus comprobantes.',
                                  style: AppTheme.body(size: 10.5, color: AppColors.greenDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _guardando ? null : _guardar,
                      child: _guardando
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Guardar cambios'),
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
