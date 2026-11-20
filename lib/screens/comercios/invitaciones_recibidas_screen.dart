import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/invitacion_supervisor.dart';
import '../../repositories/comercios_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

enum _Decision { pendiente, aceptada, rechazada }

class InvitacionesRecibidasScreen extends StatefulWidget {
  final InvitacionRecibida invitacion;
  const InvitacionesRecibidasScreen({super.key, required this.invitacion});

  @override
  State<InvitacionesRecibidasScreen> createState() => _InvitacionesRecibidasScreenState();
}

class _InvitacionesRecibidasScreenState extends State<InvitacionesRecibidasScreen> {
  _Decision _decision = _Decision.pendiente;
  bool _procesando = false;

  static const _puedeVer = [
    'Nombre y estado del comercio',
    'Total cobrado por periodo',
    'Lista de cobros: fecha, importe, folio y estado',
    'Detalle no sensible de cada cobro',
  ];

  Future<void> _responder(bool aceptar) async {
    setState(() => _procesando = true);
    await context.read<ComerciosRepository>().responderInvitacion(widget.invitacion.id, aceptar: aceptar);
    if (!mounted) return;
    setState(() {
      _procesando = false;
      _decision = aceptar ? _Decision.aceptada : _Decision.rechazada;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_decision == _Decision.aceptada) {
      return _Resultado(
        icono: Icons.check_rounded,
        iconoFondo: AppColors.cream,
        iconoColor: AppColors.greenDark,
        titulo: 'Ahora supervisas ${widget.invitacion.comercioNombre}',
        mensaje: 'Puedes consultar sus cobros en cualquier momento desde Comercios.',
        boton: 'Ir a Comercios',
      );
    }
    if (_decision == _Decision.rechazada) {
      return _Resultado(
        icono: Icons.close_rounded,
        iconoFondo: AppColors.border,
        iconoColor: AppColors.navy,
        titulo: 'Invitación rechazada',
        mensaje: 'No verás información de ${widget.invitacion.comercioNombre}. El administrador puede volver a invitarte cuando quieras.',
        boton: 'Volver a Comercios',
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
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
                  Text('Invitación recibida', style: AppTheme.display(size: 19)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(12)),
                                alignment: Alignment.center,
                                child: Text(
                                  widget.invitacion.comercioNombre.split(' ').take(2).map((p) => p.isEmpty ? '' : p[0]).join().toUpperCase(),
                                  style: AppTheme.display(size: 14, color: AppColors.greenDark),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.invitacion.comercioNombre, style: AppTheme.display(size: 17, color: AppColors.surface)),
                                    Text('Invitado por ${widget.invitacion.invitadoPorNombre} · ${widget.invitacion.invitadoPorRol}',
                                        style: AppTheme.body(size: 11, color: AppColors.surface.withValues(alpha: 0.55))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                            child: RichText(
                              text: TextSpan(
                                style: AppTheme.body(size: 11.5, color: AppColors.surface.withValues(alpha: 0.7)),
                                children: [
                                  const TextSpan(text: 'Te invitaron como '),
                                  TextSpan(text: 'Supervisor (solo lectura)', style: AppTheme.body(size: 11.5, weight: FontWeight.w700, color: AppColors.greenLight)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('QUÉ PODRÁS VER', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.textDim)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: _puedeVer
                            .map((label) => Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    border: label == _puedeVer.last ? null : const Border(bottom: BorderSide(color: AppColors.border)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_rounded, size: 15, color: AppColors.greenDark),
                                      const SizedBox(width: 10),
                                      Expanded(child: Text(label, style: AppTheme.body(size: 12.5))),
                                    ],
                                  ),
                                ))
                            .toList(),
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
                            child: Text(
                              'No podrás cobrar, editar el comercio ni ver las cuentas personales del administrador. El acceso puede revocarse en cualquier momento.',
                              style: AppTheme.body(size: 11, color: AppColors.navy.withValues(alpha: 0.65)),
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
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _procesando ? null : () => _responder(true),
                      child: _procesando
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Aceptar invitación'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _procesando ? null : () => _responder(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Rechazar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Resultado extends StatelessWidget {
  final IconData icono;
  final Color iconoFondo;
  final Color iconoColor;
  final String titulo;
  final String mensaje;
  final String boton;
  const _Resultado({
    required this.icono,
    required this.iconoFondo,
    required this.iconoColor,
    required this.titulo,
    required this.mensaje,
    required this.boton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(color: iconoFondo, shape: BoxShape.circle),
                      child: Icon(icono, size: 40, color: iconoColor),
                    ),
                    const SizedBox(height: 16),
                    Text(titulo, textAlign: TextAlign.center, style: AppTheme.display(size: 20)),
                    const SizedBox(height: 8),
                    Text(mensaje, textAlign: TextAlign.center, style: AppTheme.body(size: 13, color: AppColors.textDim)),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: Text(boton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
