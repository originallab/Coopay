import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/comercio.dart';
import '../../models/sucursal.dart';
import '../../repositories/comercios_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'mostrador_qr_screen.dart';

/// Varias sucursales pueden compartir el mismo comercio/cuenta receptora —
/// no hay rol de empleado por sucursal en este modelo, solo un QR de
/// mostrador distinto para imprimir en cada una.
class GestionSucursalesScreen extends StatefulWidget {
  final ComercioDetalle comercio;
  const GestionSucursalesScreen({super.key, required this.comercio});

  @override
  State<GestionSucursalesScreen> createState() => _GestionSucursalesScreenState();
}

class _GestionSucursalesScreenState extends State<GestionSucursalesScreen> {
  late Future<List<Sucursal>> _sucursalesFuture;

  void _cargar() {
    _sucursalesFuture = context.read<ComerciosRepository>().sucursalesDe(widget.comercio.id);
  }

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _agregarSucursal() async {
    final nombreCtrl = TextEditingController();
    final direccionCtrl = TextEditingController();
    final agregada = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) {
            bool puedeGuardar() => nombreCtrl.text.trim().isNotEmpty && direccionCtrl.text.trim().isNotEmpty;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Agregar nueva sucursal', style: AppTheme.display(size: 18)),
                const SizedBox(height: 16),
                Text('Nombre de la sucursal', style: AppTheme.body(size: 12, weight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: nombreCtrl,
                  onChanged: (_) => setSheetState(() {}),
                  decoration: const InputDecoration(hintText: 'Ej. Sucursal Sur'),
                ),
                const SizedBox(height: 14),
                Text('Dirección', style: AppTheme.body(size: 12, weight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: direccionCtrl,
                  onChanged: (_) => setSheetState(() {}),
                  decoration: const InputDecoration(hintText: 'Calle, colonia, ciudad'),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: puedeGuardar() ? () => Navigator.of(ctx).pop(true) : null,
                    child: const Text('Agregar sucursal'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
    if (agregada == true && mounted) {
      await context.read<ComerciosRepository>().agregarSucursal(
            widget.comercio.id,
            nombre: nombreCtrl.text.trim(),
            direccion: direccionCtrl.text.trim(),
          );
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
                      Text('Sucursales', style: AppTheme.display(size: 20)),
                      Text(widget.comercio.nombreComercial, style: AppTheme.body(size: 11, color: AppColors.textDim)),
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
                    FutureBuilder<List<Sucursal>>(
                      future: _sucursalesFuture,
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return const SizedBox(height: 60, child: Center(child: CircularProgressIndicator()));
                        }
                        final sucursales = snap.data!;
                        if (sucursales.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
                            child: Text('Todavía no registras ninguna sucursal.', style: AppTheme.body(size: 12.5, color: AppColors.textDim)),
                          );
                        }
                        return Column(
                          children: sucursales
                              .map((s) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _FilaSucursal(
                                      sucursal: s,
                                      onVerQr: () => Navigator.of(context).push(MaterialPageRoute(
                                        builder: (_) => MostradorQrScreen(comercio: widget.comercio, sucursalNombre: s.nombre),
                                      )),
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _agregarSucursal,
                        icon: const Icon(Icons.add_rounded, size: 17),
                        label: const Text('Agregar nueva sucursal'),
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

class _FilaSucursal extends StatelessWidget {
  final Sucursal sucursal;
  final VoidCallback onVerQr;
  const _FilaSucursal({required this.sucursal, required this.onVerQr});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(Icons.storefront_outlined, size: 16, color: AppColors.navy),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sucursal.nombre, style: AppTheme.body(size: 13.5, weight: FontWeight.w700)),
                    Text(sucursal.direccion, style: AppTheme.body(size: 11, color: AppColors.textDim), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onVerQr,
              icon: const Icon(Icons.qr_code_2_rounded, size: 16),
              label: const Text('Ver / Descargar QR físico'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.navy,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
