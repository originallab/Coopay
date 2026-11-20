import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repositories/vinculacion_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'vincular_documentos_screen.dart';

class VincularCuentaScreen extends StatefulWidget {
  const VincularCuentaScreen({super.key});

  @override
  State<VincularCuentaScreen> createState() => _VincularCuentaScreenState();
}

class _VincularCuentaScreenState extends State<VincularCuentaScreen> {
  static const _instituciones = ['Caja Hipódromo', 'Caja Genera', 'Caja Popular Mexicana'];
  String _institucion = _instituciones.first;
  TipoSolicitudVinculacion _tipo = TipoSolicitudVinculacion.cuentaExistente;
  bool _procesando = false;

  Future<void> _continuar() async {
    if (_tipo == TipoSolicitudVinculacion.cuentaNueva) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => VincularDocumentosScreen(institucion: _institucion)),
      );
      return;
    }
    setState(() => _procesando = true);
    await context.read<VinculacionRepository>().solicitar(tipo: _tipo, institucionNombre: _institucion);
    if (!mounted) return;
    setState(() => _procesando = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Solicitud enviada a $_institucion.')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vincular cuenta', style: AppTheme.display(size: 20))),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('INSTITUCIÓN', style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(999)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _institucion,
                  isExpanded: true,
                  items: _instituciones
                      .map((i) => DropdownMenuItem(value: i, child: Text(i, style: AppTheme.body(size: 13.5, weight: FontWeight.w600))))
                      .toList(),
                  onChanged: (v) => setState(() => _institucion = v!),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text('¿QUÉ TIPO DE CUENTA ES?', style: AppTheme.body(size: 11, weight: FontWeight.w700, color: AppColors.textDim)),
            const SizedBox(height: 10),
            _OpcionTipo(
              titulo: 'Ya soy titular validado ahí',
              subtitulo: 'Otra cuenta en una institución donde ya tienes identidad validada — sin documentos nuevos.',
              seleccionado: _tipo == TipoSolicitudVinculacion.cuentaExistente,
              onTap: () => setState(() => _tipo = TipoSolicitudVinculacion.cuentaExistente),
            ),
            const SizedBox(height: 10),
            _OpcionTipo(
              titulo: 'Es una institución nueva para mí',
              subtitulo: 'Vas a necesitar subir algunos documentos para abrir la cuenta.',
              seleccionado: _tipo == TipoSolicitudVinculacion.cuentaNueva,
              onTap: () => setState(() => _tipo = TipoSolicitudVinculacion.cuentaNueva),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _procesando ? null : _continuar,
                child: _procesando
                    ? const SizedBox(
                        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpcionTipo extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final bool seleccionado;
  final VoidCallback onTap;
  const _OpcionTipo({required this.titulo, required this.subtitulo, required this.seleccionado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.green.withValues(alpha: 0.12) : Colors.white,
          border: Border.all(color: seleccionado ? AppColors.green : AppColors.border, width: seleccionado ? 1.6 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(seleccionado ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                size: 19, color: seleccionado ? AppColors.greenDark : AppColors.textDim),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: AppTheme.body(size: 13.5, weight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(subtitulo, style: AppTheme.body(size: 11.5, color: AppColors.textDim)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
