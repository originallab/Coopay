import 'package:flutter/material.dart';
import '../../models/comercio.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

enum _ModoQr { cartel, tarjeta, solo }

/// El QR "de mostrador" es permanente y sin monto: el cliente escanea e
/// ingresa el importe en su app. No requiere cámara ni conexión — es un
/// código estático para imprimir, por eso no hay integración real de
/// descarga/impresión todavía (solo feedback visual transitorio).
class MostradorQrScreen extends StatefulWidget {
  final ComercioDetalle comercio;
  final String? sucursalNombre;
  const MostradorQrScreen({super.key, required this.comercio, this.sucursalNombre});

  @override
  State<MostradorQrScreen> createState() => _MostradorQrScreenState();
}

class _MostradorQrScreenState extends State<MostradorQrScreen> {
  _ModoQr _modo = _ModoQr.solo;
  _Accion? _accionActiva;

  void _disparar(_Accion accion) {
    setState(() => _accionActiva = accion);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _accionActiva = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
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
                      Text(widget.sucursalNombre ?? 'Mi Código QR', style: AppTheme.display(size: 19)),
                      Text(
                        widget.sucursalNombre == null
                            ? 'Listo para imprimir en tu mostrador'
                            : 'QR de mostrador para esta sucursal',
                        style: AppTheme.body(size: 11, color: AppColors.textDim),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(13)),
                child: Row(
                  children: [
                    Expanded(child: _TabModo(label: 'Cartel', activo: _modo == _ModoQr.cartel, onTap: () => setState(() => _modo = _ModoQr.cartel))),
                    Expanded(child: _TabModo(label: 'Tarjeta', activo: _modo == _ModoQr.tarjeta, onTap: () => setState(() => _modo = _ModoQr.tarjeta))),
                    Expanded(child: _TabModo(label: 'Solo QR', activo: _modo == _ModoQr.solo, onTap: () => setState(() => _modo = _ModoQr.solo))),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  children: [
                    if (_modo == _ModoQr.solo) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.navy, width: 2), borderRadius: BorderRadius.circular(22)),
                        alignment: Alignment.center,
                        child: const _QrPlaceholder(size: 200, badge: 'CP'),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: _modo == _ModoQr.tarjeta ? 24 : 22, vertical: _modo == _ModoQr.tarjeta ? 22 : 28),
                        decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(_modo == _ModoQr.tarjeta ? 18 : 26)),
                        child: Column(
                          children: [
                            Text('Paga con CooPay', style: AppTheme.display(size: 19, color: AppColors.greenLight)),
                            const SizedBox(height: 2),
                            Text('Escanea, ingresa el monto y paga', style: AppTheme.body(size: 11, color: AppColors.surface.withValues(alpha: 0.6))),
                            const SizedBox(height: 14),
                            const _QrPlaceholder(size: 146, badge: 'CP'),
                            const SizedBox(height: 14),
                            Text(widget.comercio.nombreComercial, style: AppTheme.body(size: 14, weight: FontWeight.w700, color: AppColors.surface)),
                            Text('${widget.comercio.institucionReceptora} · ID CP-COM-03482',
                                style: AppTheme.body(size: 10, color: AppColors.surface.withValues(alpha: 0.5))),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                      decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(13)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.greenDark),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Código permanente: no expira ni cambia el monto. Cada cliente ingresa la cantidad en su app y lo recibes al instante.',
                              style: AppTheme.body(size: 11, color: AppColors.greenDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _disparar(_Accion.descargar),
                  icon: Icon(_accionActiva == _Accion.descargar ? Icons.check_rounded : Icons.download_rounded, size: 17),
                  label: Text(_accionActiva == _Accion.descargar ? '¡Descargado!' : 'Descargar QR (PNG / PDF)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accionActiva == _Accion.descargar ? AppColors.greenDark : AppColors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
              child: Row(
                children: [
                  Expanded(
                    child: _BotonSecundario(
                      icon: _accionActiva == _Accion.compartir ? Icons.check_rounded : Icons.ios_share_rounded,
                      label: _accionActiva == _Accion.compartir ? '¡Listo!' : 'Compartir',
                      onTap: () => _disparar(_Accion.compartir),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _BotonSecundario(
                      icon: _accionActiva == _Accion.imprimir ? Icons.check_rounded : Icons.print_rounded,
                      label: _accionActiva == _Accion.imprimir ? 'Enviado' : 'Imprimir',
                      onTap: () => _disparar(_Accion.imprimir),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Accion { descargar, compartir, imprimir }

class _TabModo extends StatelessWidget {
  final String label;
  final bool activo;
  final VoidCallback onTap;
  const _TabModo({required this.label, required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(color: activo ? AppColors.navy : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        child: Text(label, style: AppTheme.body(size: 12, weight: FontWeight.w700, color: activo ? AppColors.greenLight : AppColors.navy.withValues(alpha: 0.5))),
      ),
    );
  }
}

class _QrPlaceholder extends StatelessWidget {
  final double size;
  final String badge;
  const _QrPlaceholder({required this.size, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.qr_code_2_rounded, size: size * 0.85, color: AppColors.navy),
        ),
        Container(
          width: size * 0.25,
          height: size * 0.25,
          decoration: BoxDecoration(color: AppColors.cream, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
          alignment: Alignment.center,
          child: Text(badge, style: AppTheme.display(size: size * 0.09, color: AppColors.navy)),
        ),
      ],
    );
  }
}

class _BotonSecundario extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _BotonSecundario({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: AppColors.navy),
            const SizedBox(width: 7),
            Text(label, style: AppTheme.body(size: 12.5, weight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
