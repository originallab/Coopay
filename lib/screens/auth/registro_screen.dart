import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

/// Formulario alineado al diseño real (Registro.dc.html) — nombre, correo,
/// teléfono, contraseña + confirmación, términos. El mockup calcula un color
/// "habilitado" para el botón Continuar pero nunca lo conecta al link real
/// (el anchor queda siempre navy y siempre navega) — aquí sí se exige
/// aceptar términos y contraseñas coincidentes antes de continuar, porque
/// replicar eso tal cual sería copiar un bug del mockup, no el diseño que
/// pretende.
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _pass1Ctrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  bool _pass1Oculta = true;
  bool _pass2Oculta = true;
  bool _aceptaTerminos = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _pass1Ctrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  bool get _puedeContinuar =>
      _aceptaTerminos &&
      _nombreCtrl.text.trim().isNotEmpty &&
      _emailCtrl.text.trim().isNotEmpty &&
      _pass1Ctrl.text.length >= 8 &&
      _pass1Ctrl.text == _pass2Ctrl.text;

  void _continuar() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => OnboardingScreen(nombre: _nombreCtrl.text.trim(), email: _emailCtrl.text.trim()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
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
                  Text('Crea tu cuenta', style: AppTheme.display(size: 22)),
                ],
              ),
              const SizedBox(height: 16),
              Text('Únete a CooPay y conecta tus cajas de ahorro en un solo lugar.',
                  style: AppTheme.body(size: 13, color: AppColors.textDim)),
              const SizedBox(height: 20),
              _Campo(
                label: 'Nombre completo',
                child: TextField(controller: _nombreCtrl, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'Ej. Nicolás Ibarra')),
              ),
              const SizedBox(height: 14),
              _Campo(
                label: 'Correo electrónico',
                child: TextField(
                  controller: _emailCtrl,
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'tucorreo@email.com'),
                ),
              ),
              const SizedBox(height: 14),
              _Campo(
                label: 'Teléfono celular',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      height: 50,
                      decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(999)),
                      alignment: Alignment.center,
                      child: Text('+52', style: AppTheme.body(size: 13.5, weight: FontWeight.w700, color: AppColors.textDim)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _telefonoCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(hintText: '55 1234 5678'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _Campo(
                label: 'Crear contraseña',
                child: TextField(
                  controller: _pass1Ctrl,
                  onChanged: (_) => setState(() {}),
                  obscureText: _pass1Oculta,
                  decoration: InputDecoration(
                    hintText: 'Mínimo 8 caracteres',
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _pass1Oculta = !_pass1Oculta),
                      icon: Icon(_pass1Oculta ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 19, color: _pass1Oculta ? AppColors.textDim : AppColors.greenDark),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _Campo(
                label: 'Confirmar contraseña',
                child: TextField(
                  controller: _pass2Ctrl,
                  onChanged: (_) => setState(() {}),
                  obscureText: _pass2Oculta,
                  decoration: InputDecoration(
                    hintText: 'Repite tu contraseña',
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _pass2Oculta = !_pass2Oculta),
                      icon: Icon(_pass2Oculta ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 19, color: _pass2Oculta ? AppColors.textDim : AppColors.greenDark),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => setState(() => _aceptaTerminos = !_aceptaTerminos),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          color: _aceptaTerminos ? AppColors.green : Colors.white,
                          border: Border.all(color: _aceptaTerminos ? AppColors.green : AppColors.border, width: 1.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: _aceptaTerminos ? const Icon(Icons.check_rounded, size: 13, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTheme.body(size: 12, color: AppColors.textDim),
                            children: [
                              const TextSpan(text: 'Acepto los '),
                              TextSpan(text: 'Términos y condiciones', style: AppTheme.body(size: 12, weight: FontWeight.w700, color: AppColors.greenDark)),
                              const TextSpan(text: ' y el '),
                              TextSpan(text: 'Aviso de privacidad', style: AppTheme.body(size: 12, weight: FontWeight.w700, color: AppColors.greenDark)),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _puedeContinuar ? _continuar : null,
                  child: const Text('Continuar'),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: InkWell(
                  onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: RichText(
                    text: TextSpan(
                      style: AppTheme.body(size: 12.5, color: AppColors.textDim),
                      children: [
                        const TextSpan(text: '¿Ya tienes cuenta? '),
                        TextSpan(text: 'Iniciar sesión', style: AppTheme.body(size: 12.5, weight: FontWeight.w700, color: AppColors.greenDark)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_outlined, size: 12, color: AppColors.textDim),
                  const SizedBox(width: 6),
                  Text('Protegido por Original Auth', style: AppTheme.body(size: 10.5, weight: FontWeight.w600, color: AppColors.textDim)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final String label;
  final Widget child;
  const _Campo({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.body(size: 12, weight: FontWeight.w600)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
