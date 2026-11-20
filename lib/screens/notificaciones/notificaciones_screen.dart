import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notificacion.dart';
import '../../repositories/notificaciones_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  late Future<List<Notificacion>> _future;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    _future = context.read<NotificacionesRepository>().listar();
  }

  Future<void> _marcarLeida(Notificacion n) async {
    if (n.leido) return;
    await context.read<NotificacionesRepository>().marcarLeida(n.id);
    setState(_cargar);
  }

  IconData _icono(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.pagoRecibido:
      case TipoNotificacion.pagoEnviado:
        return Icons.sync_alt_rounded;
      case TipoNotificacion.invitacionSupervisor:
        return Icons.storefront_rounded;
      case TipoNotificacion.seguridad:
        return Icons.shield_outlined;
      case TipoNotificacion.sistema:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notificaciones', style: AppTheme.display(size: 20))),
      body: FutureBuilder<List<Notificacion>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final datos = snap.data!;
          if (datos.isEmpty) {
            return Center(child: Text('No tienes notificaciones.', style: AppTheme.body(size: 13, color: AppColors.textDim)));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            itemCount: datos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final n = datos[i];
              return InkWell(
                onTap: () => _marcarLeida(n),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: n.leido ? Colors.white : AppColors.cream.withValues(alpha: 0.6),
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Icon(_icono(n.tipo), size: 17, color: AppColors.cream),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.titulo, style: AppTheme.body(size: 13.5, weight: FontWeight.w700)),
                            const SizedBox(height: 3),
                            Text(n.mensaje, style: AppTheme.body(size: 12, color: AppColors.textDim)),
                          ],
                        ),
                      ),
                      if (!n.leido) ...[
                        const SizedBox(width: 8),
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle)),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
