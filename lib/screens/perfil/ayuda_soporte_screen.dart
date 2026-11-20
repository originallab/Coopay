import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class AyudaSoporteScreen extends StatefulWidget {
  const AyudaSoporteScreen({super.key});

  @override
  State<AyudaSoporteScreen> createState() => _AyudaSoporteScreenState();
}

class _AyudaSoporteScreenState extends State<AyudaSoporteScreen> {
  bool _chatSolicitado = false;
  int? _faqAbierta;

  static const _faqs = [
    ('¿Cómo transfiero a un socio de otra caja?',
        'Por ahora las transferencias son entre socios de la misma caja. Ya estamos preparando transferencias entre instituciones distintas.'),
    ('¿Qué hago si mi pago QR no se refleja?',
        'Espera unos minutos y revisa tu historial de movimientos. Si no aparece, escríbenos con el folio de la operación.'),
    ('¿Cómo cambio mi PIN transaccional?', 'Ve a Perfil → Ajustes y seguridad → Cambiar PIN transaccional y sigue los 3 pasos.'),
    ('¿Es seguro vincular varias cajas?',
        'Sí. Cada caja ve solo su propia información; tu identidad se valida una sola vez con Original Auth.'),
    ('¿Cómo reporto un dispositivo perdido?',
        'Ve a Perfil → Ajustes y seguridad → Dispositivos y sesiones, y cierra esa sesión de inmediato.'),
  ];

  void _simular(String medio) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$medio — no hay integración real todavía, esto es una simulación')));
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
              Row(
                children: [
                  Expanded(child: _Contacto(icon: Icons.call_outlined, label: 'Llamar', onTap: () => _simular('Llamada'))),
                  const SizedBox(width: 10),
                  Expanded(child: _Contacto(icon: Icons.chat_bubble_outline_rounded, label: 'WhatsApp', onTap: () => _simular('WhatsApp'))),
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
                    Text('CooPay · Soporte disponible 24/7', style: AppTheme.body(size: 10.5, color: AppColors.textDim)),
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
