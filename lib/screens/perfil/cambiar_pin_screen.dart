import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repositories/ajustes_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

enum _PasoPin { actual, nuevo, confirmar, listo }

/// El paso 1 solo recolecta 4 dígitos — no hay backend que valide el PIN
/// vigente todavía (igual que el prototipo: nunca rechaza el "PIN actual").
/// Solo paso 3 (nuevo vs. confirmación) se valida de verdad.
class CambiarPinScreen extends StatefulWidget {
  const CambiarPinScreen({super.key});

  @override
  State<CambiarPinScreen> createState() => _CambiarPinScreenState();
}

class _CambiarPinScreenState extends State<CambiarPinScreen> {
  _PasoPin _paso = _PasoPin.actual;
  String _actual = '';
  String _nuevo = '';
  String _confirmar = '';
  bool _error = false;

  void _presionar(String digito) {
    switch (_paso) {
      case _PasoPin.actual:
        if (_actual.length >= 4) return;
        setState(() => _actual += digito);
        if (_actual.length == 4) {
          Future.delayed(const Duration(milliseconds: 280), () {
            if (mounted) setState(() => _paso = _PasoPin.nuevo);
          });
        }
        break;
      case _PasoPin.nuevo:
        if (_nuevo.length >= 4) return;
        setState(() => _nuevo += digito);
        if (_nuevo.length == 4) {
          Future.delayed(const Duration(milliseconds: 280), () {
            if (mounted) setState(() => _paso = _PasoPin.confirmar);
          });
        }
        break;
      case _PasoPin.confirmar:
        if (_confirmar.length >= 4) return;
        setState(() {
          _confirmar += digito;
          _error = false;
        });
        if (_confirmar.length == 4) {
          Future.delayed(const Duration(milliseconds: 280), () async {
            if (!mounted) return;
            if (_confirmar == _nuevo) {
              await context.read<AjustesRepository>().cambiarPin(_nuevo);
              if (mounted) setState(() => _paso = _PasoPin.listo);
            } else {
              setState(() {
                _confirmar = '';
                _error = true;
              });
            }
          });
        }
        break;
      case _PasoPin.listo:
        break;
    }
  }

  void _borrar() {
    setState(() {
      switch (_paso) {
        case _PasoPin.actual:
          if (_actual.isNotEmpty) _actual = _actual.substring(0, _actual.length - 1);
          break;
        case _PasoPin.nuevo:
          if (_nuevo.isNotEmpty) _nuevo = _nuevo.substring(0, _nuevo.length - 1);
          break;
        case _PasoPin.confirmar:
          if (_confirmar.isNotEmpty) _confirmar = _confirmar.substring(0, _confirmar.length - 1);
          _error = false;
          break;
        case _PasoPin.listo:
          break;
      }
    });
  }

  int get _pasoNum => switch (_paso) { _PasoPin.actual => 1, _PasoPin.nuevo => 2, _PasoPin.confirmar => 3, _PasoPin.listo => 3 };

  @override
  Widget build(BuildContext context) {
    if (_paso == _PasoPin.listo) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
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
                      Text('PIN actualizado', style: AppTheme.display(size: 22)),
                      const SizedBox(height: 8),
                      Text(
                        'Usa tu nuevo PIN la próxima vez que confirmes un pago o transferencia.',
                        textAlign: TextAlign.center,
                        style: AppTheme.body(size: 14, color: AppColors.textDim),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Listo'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final String pinActual = switch (_paso) {
      _PasoPin.actual => _actual,
      _PasoPin.nuevo => _nuevo,
      _PasoPin.confirmar => _confirmar,
      _PasoPin.listo => '',
    };
    final titulo = switch (_paso) {
      _PasoPin.actual => 'Ingresa tu PIN actual',
      _PasoPin.nuevo => 'Crea tu nuevo PIN',
      _PasoPin.confirmar => 'Confirma tu nuevo PIN',
      _PasoPin.listo => '',
    };
    final subtitulo = switch (_paso) {
      _PasoPin.actual => 'Para tu seguridad, primero confirma tu PIN vigente.',
      _PasoPin.nuevo => 'Elige 4 dígitos que no uses en otra parte.',
      _PasoPin.confirmar => 'Vuelve a escribirlo para confirmar.',
      _PasoPin.listo => '',
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
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
                            decoration: BoxDecoration(
                              color: activo ? AppColors.green : AppColors.border,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: AppTheme.display(size: 22)),
                    const SizedBox(height: 10),
                    Text(subtitulo, style: AppTheme.body(size: 13.5, color: AppColors.textDim)),
                    if (_error) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 15, color: AppColors.danger),
                            const SizedBox(width: 8),
                            Text('Los PIN no coinciden, intenta de nuevo', style: AppTheme.body(size: 12, weight: FontWeight.w600, color: AppColors.danger)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (i) {
                        final lleno = i < pinActual.length;
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
                    const SizedBox(height: 30),
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
                                _TeclaPin(label: d, onTap: () => _presionar(d)),
                              const SizedBox.shrink(),
                              _TeclaPin(label: '0', onTap: () => _presionar('0')),
                              _TeclaPin(icon: Icons.backspace_outlined, onTap: _borrar),
                            ],
                          ),
                        ),
                      ),
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

class _TeclaPin extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  const _TeclaPin({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(18)),
        alignment: Alignment.center,
        child: label != null
            ? Text(label!, style: AppTheme.display(size: 20))
            : Icon(icon, size: 19, color: AppColors.navy),
      ),
    );
  }
}
