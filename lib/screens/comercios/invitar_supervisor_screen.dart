import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repositories/comercios_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class InvitarSupervisorScreen extends StatefulWidget {
  final String comercioId;
  final String comercioNombre;
  const InvitarSupervisorScreen({super.key, required this.comercioId, required this.comercioNombre});

  @override
  State<InvitarSupervisorScreen> createState() => _InvitarSupervisorScreenState();
}

class _InvitarSupervisorScreenState extends State<InvitarSupervisorScreen> {
  final _contactoCtrl = TextEditingController();
  bool _enviando = false;
  bool _enviada = false;

  static const _puedeVer = [
    'Nombre y estado del comercio',
    'Total cobrado por periodo',
    'Lista de cobros: fecha, importe, folio y estado',
    'Detalle no sensible de cada cobro',
  ];
  static const _noPuedeHacer = [
    'Cobrar o generar el QR operativo',
    'Editar el comercio o su cuenta receptora',
    'Invitar o revocar otros supervisores',
    'Ver tus cuentas o movimientos personales',
  ];

  @override
  void dispose() {
    _contactoCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (_contactoCtrl.text.trim().isEmpty) return;
    setState(() => _enviando = true);
    await context.read<ComerciosRepository>().invitarSupervisor(widget.comercioId, _contactoCtrl.text.trim());
    if (!mounted) return;
    setState(() {
      _enviando = false;
      _enviada = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_enviada) {
      final contacto = _contactoCtrl.text.trim().isEmpty ? 'esa persona' : _contactoCtrl.text.trim();
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
                        decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
                        child: const Icon(Icons.mail_outline_rounded, size: 40, color: AppColors.greenDark),
                      ),
                      const SizedBox(height: 16),
                      Text('Invitación enviada', style: AppTheme.display(size: 20)),
                      const SizedBox(height: 8),
                      Text(
                        'Avisamos a $contacto. Podrá ver los cobros de ${widget.comercioNombre} en cuanto acepte desde su cuenta CooPay.',
                        textAlign: TextAlign.center,
                        style: AppTheme.body(size: 13, color: AppColors.textDim),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Volver a supervisores'),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Invitar supervisor', style: AppTheme.display(size: 19)),
                      Text(widget.comercioNombre, style: AppTheme.body(size: 11, color: AppColors.textDim)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CORREO O TELÉFONO VERIFICADO', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.textDim)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _contactoCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'persona@email.com'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text('Debe tener (o crear) una cuenta CooPay para aceptar.', style: AppTheme.body(size: 10.5, color: AppColors.textDim)),
                    ),
                    const SizedBox(height: 18),
                    Text('QUÉ PODRÁ VER', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.textDim)),
                    const SizedBox(height: 8),
                    const _Lista(items: _puedeVer, icon: Icons.check_rounded, color: AppColors.greenDark),
                    const SizedBox(height: 16),
                    Text('QUÉ NO PODRÁ HACER', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppColors.textDim)),
                    const SizedBox(height: 8),
                    const _Lista(items: _noPuedeHacer, icon: Icons.close_rounded, color: AppColors.danger),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _enviando ? null : _enviar,
                  child: _enviando
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Enviar invitación'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Lista extends StatelessWidget {
  final List<String> items;
  final IconData icon;
  final Color color;
  const _Lista({required this.items, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: items
            .map((label) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: label == items.last ? null : const Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 15, color: color),
                      const SizedBox(width: 10),
                      Expanded(child: Text(label, style: AppTheme.body(size: 12.5))),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
