import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repositories/auth_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../inicio/inicio_screen.dart';

enum _PasoOnboarding { identidad, facial, pin, listo }

/// CU-01 de la especificación: captura de INE + prueba de vida. Ninguno de
/// los dos pasos tiene integración real con Original Auth todavía — "Subir
/// INE" y "Verificación facial" solo simulan el estado, igual que el
/// prototipo (su botón "Continuar" nunca valida que de verdad se haya
/// escaneado nada). Lo único real es el PIN, que sí se guarda en
/// `AjustesRepository` para reusarlo después en Cambiar PIN.
class OnboardingScreen extends StatefulWidget {
  final String nombre;
  final String email;
  const OnboardingScreen({super.key, required this.nombre, required this.email});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  _PasoOnboarding _paso = _PasoOnboarding.identidad;
  bool _ineCargada = false;
  String _pin = '';
  bool _verificando = false;

  int get _pasoNum => switch (_paso) {
        _PasoOnboarding.identidad => 1,
        _PasoOnboarding.facial => 2,
        _PasoOnboarding.pin => 3,
        _PasoOnboarding.listo => 3,
      };

  void _atras() {
    switch (_paso) {
      case _PasoOnboarding.identidad:
        Navigator.of(context).pop();
        break;
      case _PasoOnboarding.facial:
        setState(() => _paso = _PasoOnboarding.identidad);
        break;
      case _PasoOnboarding.pin:
        setState(() => _paso = _PasoOnboarding.facial);
        break;
      case _PasoOnboarding.listo:
        break;
    }
  }

  void _presionarPin(String digito) {
    if (_pin.length >= 4) return;
    setState(() => _pin += digito);
  }

  void _borrarPin() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _confirmarPin() async {
    if (_pin.length != 4) return;
    setState(() => _verificando = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _verificando = false;
      _paso = _PasoOnboarding.listo;
    });
  }

  Future<void> _irAMiCuenta() async {
    await context.read<AuthRepository>().iniciarSesion(email: widget.email);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const InicioScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (_paso != _PasoOnboarding.listo)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: _atras,
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 10),
                child: switch (_paso) {
                  _PasoOnboarding.identidad => _PasoIdentidad(cargada: _ineCargada, onToggle: () => setState(() => _ineCargada = !_ineCargada), onContinuar: () => setState(() => _paso = _PasoOnboarding.facial)),
                  _PasoOnboarding.facial => _PasoFacial(onContinuar: () => setState(() => _paso = _PasoOnboarding.pin)),
                  _PasoOnboarding.pin => _PasoPin(pin: _pin, verificando: _verificando, onDigito: _presionarPin, onBorrar: _borrarPin, onConfirmar: _confirmarPin),
                  _PasoOnboarding.listo => _PasoListo(nombre: widget.nombre, onIrAMiCuenta: _irAMiCuenta),
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_outlined, size: 13, color: AppColors.textDim),
                  const SizedBox(width: 6),
                  Text('Protegido por Original Auth', style: AppTheme.body(size: 11, weight: FontWeight.w600, color: AppColors.textDim)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasoIdentidad extends StatelessWidget {
  final bool cargada;
  final VoidCallback onToggle;
  final VoidCallback onContinuar;
  const _PasoIdentidad({required this.cargada, required this.onToggle, required this.onContinuar});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verifica tu identidad', style: AppTheme.display(size: 23)),
        const SizedBox(height: 8),
        Text('Sube una foto de tu INE o pasaporte vigente. Lo procesamos con Original Auth.',
            style: AppTheme.body(size: 13.5, color: AppColors.textDim)),
        const SizedBox(height: 18),
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: cargada ? AppColors.green : AppColors.border, width: cargada ? 1.6 : 1.5),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
                  child: Icon(cargada ? Icons.check_rounded : Icons.badge_outlined, size: 28, color: AppColors.greenDark),
                ),
                const SizedBox(height: 14),
                Text(cargada ? 'INE cargada' : 'Identificación oficial', style: AppTheme.body(size: 14, weight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(cargada ? 'Toca para reemplazarla' : 'Frente y reverso, buena iluminación',
                    style: AppTheme.body(size: 12.5, color: AppColors.textDim)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(14)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.greenLight),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Tus datos se cifran y comparten únicamente con tu caja de ahorro para validar tu alta.',
                    style: AppTheme.body(size: 11.5, color: AppColors.surface)),
              ),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: onContinuar, child: const Text('Escanear documento')),
        ),
      ],
    );
  }
}

class _PasoFacial extends StatelessWidget {
  final VoidCallback onContinuar;
  const _PasoFacial({required this.onContinuar});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verificación facial', style: AppTheme.display(size: 23)),
        const SizedBox(height: 8),
        Text('Centra tu rostro dentro del círculo y mantente quieto unos segundos.',
            style: AppTheme.body(size: 13.5, color: AppColors.textDim)),
        Expanded(
          child: Center(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.navy,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.greenLight, width: 3),
              ),
              child: const Icon(Icons.face_retouching_natural_rounded, size: 78, color: AppColors.cream),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(14)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.greenDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Prueba de vida (liveness) protegida por Original Auth — nunca se guarda como foto suelta.',
                    style: AppTheme.body(size: 11.5, color: AppColors.greenDark)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: onContinuar, child: const Text('Iniciar verificación')),
        ),
      ],
    );
  }
}

class _PasoPin extends StatelessWidget {
  final String pin;
  final bool verificando;
  final ValueChanged<String> onDigito;
  final VoidCallback onBorrar;
  final VoidCallback onConfirmar;
  const _PasoPin({required this.pin, required this.verificando, required this.onDigito, required this.onBorrar, required this.onConfirmar});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Crea tu PIN transaccional', style: AppTheme.display(size: 23)),
        const SizedBox(height: 8),
        Text('Lo usarás para confirmar pagos y transferencias.', style: AppTheme.body(size: 13.5, color: AppColors.textDim)),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) {
            final lleno = i < pin.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: lleno ? AppColors.navy : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.navy, width: 2),
              ),
            );
          }),
        ),
        const SizedBox(height: 26),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  for (final d in ['1', '2', '3', '4', '5', '6', '7', '8', '9'])
                    _Tecla(label: d, onTap: () => onDigito(d)),
                  const SizedBox.shrink(),
                  _Tecla(label: '0', onTap: () => onDigito('0')),
                  _Tecla(icon: Icons.backspace_outlined, onTap: onBorrar),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (pin.length == 4 && !verificando) ? onConfirmar : null,
            child: verificando
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Confirmar PIN'),
          ),
        ),
      ],
    );
  }
}

class _Tecla extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  const _Tecla({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(18)),
        alignment: Alignment.center,
        child: label != null ? Text(label!, style: AppTheme.display(size: 20)) : Icon(icon, size: 19, color: AppColors.navy),
      ),
    );
  }
}

class _PasoListo extends StatelessWidget {
  final String nombre;
  final VoidCallback onIrAMiCuenta;
  const _PasoListo({required this.nombre, required this.onIrAMiCuenta});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_outline_rounded, size: 44, color: AppColors.greenDark),
              ),
              const SizedBox(height: 18),
              Text('¡Cuenta verificada!', style: AppTheme.display(size: 22)),
              const SizedBox(height: 8),
              Text(
                'Tu identidad fue validada con Original Auth. Ya puedes activar tu Cuenta Light.',
                textAlign: TextAlign.center,
                style: AppTheme.body(size: 14, color: AppColors.textDim),
              ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: onIrAMiCuenta, child: const Text('Ir a mi cuenta')),
        ),
      ],
    );
  }
}
