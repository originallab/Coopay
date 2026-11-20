import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class TerminosPrivacidadScreen extends StatefulWidget {
  const TerminosPrivacidadScreen({super.key});

  @override
  State<TerminosPrivacidadScreen> createState() => _TerminosPrivacidadScreenState();
}

class _TerminosPrivacidadScreenState extends State<TerminosPrivacidadScreen> {
  bool _enTerminos = true;

  static const _terminos = [
    ('1. Aceptación de los términos',
        'Al usar CooPay aceptas estos términos, que aplican junto con las condiciones particulares de cada caja de ahorro o SOFIPO que vincules a tu cuenta.'),
    ('2. Naturaleza del servicio',
        'CooPay es una capa de experiencia y orquestación sobre los servicios financieros de las instituciones participantes. No sustituye el core financiero ni la responsabilidad regulatoria de cada caja.'),
    ('3. Identidad y Original Auth',
        'Tu identidad se valida a través de Original Auth. Eres responsable de mantener tus credenciales y dispositivos de confianza seguros.'),
    ('4. Uso de transferencias y pagos',
        'Las operaciones que realices a través de CooPay se procesan con el consentimiento y la confirmación explícita que das en cada pantalla, incluyendo tu PIN transaccional o biometría.'),
    ('5. Limitación de responsabilidad',
        'CooPay no es responsable de interrupciones del servicio atribuibles a terceros, incluyendo el core financiero de las instituciones o proveedores de pago.'),
  ];

  static const _privacidad = [
    ('1. Datos que recopilamos',
        'Nombre, correo, teléfono, datos de identificación oficial y biometría capturados durante tu registro con Original Auth, así como el historial de operaciones dentro de la app.'),
    ('2. Para qué los usamos',
        'Para verificar tu identidad, procesar tus operaciones, prevenir fraude y cumplir con los requerimientos regulatorios de las instituciones a las que estás afiliado.'),
    ('3. Con quién los compartimos',
        'Únicamente con la caja de ahorro o SOFIPO correspondiente a cada cuenta que vinculas, y con los proveedores que procesan pagos (Original Pay) bajo los mismos estándares de protección.'),
    ('4. Cómo protegemos tus datos',
        'Tus datos sensibles se cifran en reposo y en tránsito. El acceso administrativo queda registrado en un log de auditoría independiente del log operativo.'),
    ('5. Tus derechos',
        'Puedes solicitar acceso, corrección o eliminación de tus datos personales escribiendo a soporte, salvo la información que las instituciones deban conservar por obligación regulatoria.'),
  ];

  @override
  Widget build(BuildContext context) {
    final secciones = _enTerminos ? _terminos : _privacidad;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
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
                  Expanded(child: Text('Términos y Aviso de Privacidad', style: AppTheme.display(size: 17))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _Tab(label: 'Términos y condiciones', activo: _enTerminos, onTap: () => setState(() => _enTerminos = true)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Tab(label: 'Aviso de privacidad', activo: !_enTerminos, onTap: () => setState(() => _enTerminos = false)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (titulo, texto) in secciones) ...[
                      Text(titulo, style: AppTheme.body(size: 13.5, weight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(texto, style: AppTheme.body(size: 12.5, color: AppColors.textDim)),
                      const SizedBox(height: 14),
                    ],
                    Center(
                      child: Text('Última actualización: noviembre 2026', style: AppTheme.body(size: 11, color: AppColors.textDim)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool activo;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(color: activo ? AppColors.navy : AppColors.cream, borderRadius: BorderRadius.circular(999)),
        alignment: Alignment.center,
        child: Text(label, textAlign: TextAlign.center, style: AppTheme.body(size: 12.5, weight: FontWeight.w700, color: activo ? AppColors.greenLight : AppColors.navy.withValues(alpha: 0.5))),
      ),
    );
  }
}
