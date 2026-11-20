import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/supervisor.dart';
import '../../repositories/comercios_repository.dart';
import '../../routing/route_observer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'invitar_supervisor_screen.dart';

class SupervisoresScreen extends StatefulWidget {
  final String comercioId;
  final String comercioNombre;
  const SupervisoresScreen({super.key, required this.comercioId, required this.comercioNombre});

  @override
  State<SupervisoresScreen> createState() => _SupervisoresScreenState();
}

class _SupervisoresScreenState extends State<SupervisoresScreen> with RouteAware {
  late Future<List<Supervisor>> _supervisoresFuture;

  void _cargar() {
    _supervisoresFuture = context.read<ComerciosRepository>().supervisoresDe(widget.comercioId);
  }

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() => setState(_cargar);

  Future<void> _confirmarRevocar(Supervisor s) async {
    final confirmado = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Revocar a ${s.nombre}?', style: AppTheme.display(size: 18)),
            const SizedBox(height: 8),
            Text(
              'Dejará de ver los cobros de este comercio de inmediato, incluso si tiene una sesión abierta. Sus otros permisos no se ven afectados.',
              style: AppTheme.body(size: 12.5, color: AppColors.textDim),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                child: const Text('Revocar acceso'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.navy,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
    if (confirmado == true && mounted) {
      final repo = context.read<ComerciosRepository>();
      await repo.revocarSupervisor(widget.comercioId, s.id);
      if (!mounted) return;
      setState(_cargar);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      Text('Supervisores', style: AppTheme.display(size: 20)),
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
                              'Un supervisor solo puede consultar los cobros de este comercio. No puede cobrar, editarlo ni invitar a otras personas.',
                              style: AppTheme.body(size: 11, color: AppColors.greenDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('ACCESO VIGENTE', style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
                    const SizedBox(height: 8),
                    FutureBuilder<List<Supervisor>>(
                      future: _supervisoresFuture,
                      builder: (context, snap) {
                        if (!snap.hasData) return const SizedBox(height: 60, child: Center(child: CircularProgressIndicator()));
                        final sups = snap.data!;
                        if (sups.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
                            child: Text('Todavía no invitas a ningún supervisor.', style: AppTheme.body(size: 12.5, color: AppColors.textDim)),
                          );
                        }
                        return Container(
                          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
                          child: Column(
                            children: sups
                                .map((s) => _FilaSupervisor(supervisor: s, esUltima: s == sups.last, onRevocar: () => _confirmarRevocar(s)))
                                .toList(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => InvitarSupervisorScreen(comercioId: widget.comercioId, comercioNombre: widget.comercioNombre),
                        )),
                        icon: const Icon(Icons.add_rounded, size: 17),
                        label: const Text('Invitar supervisor'),
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

class _FilaSupervisor extends StatelessWidget {
  final Supervisor supervisor;
  final bool esUltima;
  final VoidCallback onRevocar;
  const _FilaSupervisor({required this.supervisor, required this.onRevocar, this.esUltima = false});

  @override
  Widget build(BuildContext context) {
    const meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    final desdeTexto = '${supervisor.desde.day} ${meses[supervisor.desde.month - 1]} ${supervisor.desde.year}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(border: esUltima ? null : const Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              supervisor.nombre.split(' ').take(2).map((p) => p.isEmpty ? '' : p[0]).join().toUpperCase(),
              style: AppTheme.display(size: 12.5, color: AppColors.greenDark),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(supervisor.nombre, style: AppTheme.body(size: 13.5, weight: FontWeight.w700)),
                Text('${supervisor.contacto} · desde $desdeTexto', style: AppTheme.body(size: 11, color: AppColors.textDim)),
              ],
            ),
          ),
          TextButton(
            onPressed: onRevocar,
            style: TextButton.styleFrom(foregroundColor: AppColors.danger, padding: const EdgeInsets.symmetric(horizontal: 6)),
            child: Text('Revocar', style: AppTheme.body(size: 11.5, weight: FontWeight.w700, color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
