import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Contenido distinto al de Ayuda y soporte del socio (ver AyudaSoporteScreen):
/// aquí las preguntas son sobre cobros, QR de mostrador y retiros, no sobre
/// transferencias entre socios.
class AyudaSoporteComercioScreen extends StatefulWidget {
  const AyudaSoporteComercioScreen({super.key});

  @override
  State<AyudaSoporteComercioScreen> createState() => _AyudaSoporteComercioScreenState();
}

class _AyudaSoporteComercioScreenState extends State<AyudaSoporteComercioScreen> {
  int? _faqAbierta = 0;
  bool _chatSolicitado = false;

  static const _faqs = [
    ('Mi cliente pagó pero no me llegó la notificación',
        'Primero revisa en Historial de ventas si el cobro aparece con su folio. Si aparece, el pago sí se recibió y la alerta solo se retrasó. Si no aparece, pide a tu cliente su comprobante y repórtalo con el botón "Reportar un problema con un cobro".'),
    ('¿Cómo descargo mi QR de mostrador?',
        'Entra a Inicio y toca "Mi QR físico", o a Perfil del comercio > Sucursales > "Ver / Descargar QR físico". Elige formato y descárgalo. El código es permanente: imprímelo una vez y colócalo en tu mostrador.'),
    ('¿Cómo emito un reembolso?',
        'Ve al detalle de la transacción (desde Historial de ventas o la notificación del cobro) y toca "Emitir reembolso". El monto se regresa a tu cliente y la venta queda marcada como reembolsada.'),
    ('¿Qué es el corte de caja?',
        'Es el resumen de tus cobros del día. Puedes exportarlo como reporte y cerrarlo al final de la jornada — los cobros nuevos del día siguen llegando con normalidad.'),
    ('Olvidé mi PIN de seguridad',
        'Ve a Perfil del comercio > PIN de seguridad y sigue los pasos para crear uno nuevo, o contáctanos por Chat directo de ayuda para verificar tu identidad.'),
  ];

  void _mostrarReportarProblema() {
    final folioCtrl = TextEditingController();
    final descripcionCtrl = TextEditingController();
    bool enviado = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Reportar un problema', style: AppTheme.display(size: 18)),
                    InkWell(
                      onTap: () => Navigator.of(ctx).pop(),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded, size: 14, color: AppColors.navy),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Folio del cobro', style: AppTheme.body(size: 12, weight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(controller: folioCtrl, decoration: const InputDecoration(hintText: 'Ej. CP-30418-QR')),
                const SizedBox(height: 14),
                Text('Descripción de la falla', style: AppTheme.body(size: 12, weight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: descripcionCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: 'Cuéntanos qué pasó con este cobro'),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: enviado
                        ? null
                        : () {
                            setSheetState(() => enviado = true);
                            final navigator = Navigator.of(ctx);
                            Future.delayed(const Duration(milliseconds: 1200), () {
                              if (navigator.canPop()) navigator.pop();
                            });
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: enviado ? AppColors.greenDark : null),
                    child: Text(enviado ? '¡Reporte enviado!' : 'Enviar a soporte'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _simular(String medio) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$medio — no hay integración real todavía, esto es una simulación')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.navy),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text('Ayuda y soporte', style: AppTheme.display(size: 19)),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('¿Algo no salió bien con un cobro?',
                        style: AppTheme.body(size: 14, weight: FontWeight.w700, color: AppColors.surface)),
                    const SizedBox(height: 4),
                    Text('Cuéntanos el folio y qué pasó. Respondemos en menos de 24 horas.',
                        style: AppTheme.body(size: 11.5, color: AppColors.surface.withValues(alpha: 0.6))),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _mostrarReportarProblema,
                        icon: const Icon(Icons.report_problem_outlined, size: 16),
                        label: const Text('Reportar un problema con un cobro'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _Contacto(icon: Icons.call_outlined, label: 'Llamar', onTap: () => _simular('Llamada'))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Contacto(
                      icon: Icons.forum_outlined,
                      label: 'Chat en vivo',
                      activo: _chatSolicitado,
                      onTap: () => setState(() => _chatSolicitado = true),
                    ),
                  ),
                ],
              ),
              if (_chatSolicitado) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                  decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 15, color: AppColors.greenDark),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Solicitud enviada. Un agente te escribirá por chat en los próximos minutos.',
                            style: AppTheme.body(size: 12, color: AppColors.greenDark)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Text('PREGUNTAS FRECUENTES', style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
                child: Column(
                  children: List.generate(_faqs.length, (i) {
                    final abierta = _faqAbierta == i;
                    final esUltima = i == _faqs.length - 1;
                    return Container(
                      decoration: BoxDecoration(border: esUltima ? null : const Border(bottom: BorderSide(color: AppColors.border))),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () => setState(() => _faqAbierta = abierta ? null : i),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(child: Text(_faqs[i].$1, style: AppTheme.body(size: 13, weight: FontWeight.w600))),
                                  AnimatedRotation(
                                    turns: abierta ? 0.25 : 0,
                                    duration: const Duration(milliseconds: 150),
                                    child: const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textDim),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (abierta)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                              child: Text(_faqs[i].$2, style: AppTheme.body(size: 12, color: AppColors.textDim)),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_outlined, size: 13, color: AppColors.textDim),
                    const SizedBox(width: 6),
                    Text('Atención de tu caja de ahorro · Lun a Sáb 9:00–20:00', style: AppTheme.body(size: 10.5, color: AppColors.textDim)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Contacto extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool activo;
  final VoidCallback onTap;
  const _Contacto({required this.icon, required this.label, required this.onTap, this.activo = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: activo ? AppColors.green.withValues(alpha: 0.12) : Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.greenDark),
            const SizedBox(height: 7),
            Text(label, textAlign: TextAlign.center, style: AppTheme.body(size: 11, weight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
