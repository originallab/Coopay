import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repositories/vinculacion_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class VincularDocumentosScreen extends StatefulWidget {
  final String institucion;
  const VincularDocumentosScreen({super.key, required this.institucion});

  @override
  State<VincularDocumentosScreen> createState() => _VincularDocumentosScreenState();
}

class _VincularDocumentosScreenState extends State<VincularDocumentosScreen> {
  // Checklist de demo — qué documento exige cada institución para abrir
  // cuenta nueva todavía no está confirmado (ver README, "pendiente de
  // confirmar"); esta lista cubre lo típico de una apertura SOCAP/SOFIPO.
  final List<_Documento> _documentos = [
    _Documento('INE o identificación oficial'),
    _Documento('Comprobante de domicilio'),
    _Documento('Constancia de situación fiscal'),
  ];
  bool _enviando = false;

  bool get _todosSubidos => _documentos.every((d) => d.subido);

  Future<void> _enviarSolicitud() async {
    setState(() => _enviando = true);
    await context.read<VinculacionRepository>().solicitar(
          tipo: TipoSolicitudVinculacion.cuentaNueva,
          institucionNombre: widget.institucion,
        );
    if (!mounted) return;
    setState(() => _enviando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Solicitud enviada. ${widget.institucion} la revisará.')),
    );
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Documentos', style: AppTheme.display(size: 20))),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.institucion} pide estos documentos para abrir tu cuenta:',
                style: AppTheme.body(size: 13, color: AppColors.textDim)),
            const SizedBox(height: 18),
            ..._documentos.map((d) => _FilaDocumento(documento: d, onTap: () => setState(() => d.subido = !d.subido))),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(13)),
              child: Text(
                'Demo: todavía no hay integración con MediaAAS para subir el archivo real — esto solo simula el estado "subido".',
                style: AppTheme.body(size: 11, color: AppColors.textDim),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_todosSubidos && !_enviando) ? _enviarSolicitud : null,
                child: _enviando
                    ? const SizedBox(
                        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Enviar solicitud'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Documento {
  final String label;
  bool subido = false;
  _Documento(this.label);
}

class _FilaDocumento extends StatelessWidget {
  final _Documento documento;
  final VoidCallback onTap;
  const _FilaDocumento({required this.documento, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: documento.subido ? AppColors.green.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(color: documento.subido ? AppColors.green : AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(documento.subido ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                size: 19, color: documento.subido ? AppColors.greenDark : AppColors.textDim),
            const SizedBox(width: 12),
            Expanded(child: Text(documento.label, style: AppTheme.body(size: 13.5, weight: FontWeight.w600))),
            Text(documento.subido ? 'Subido' : 'Subir',
                style:
                    AppTheme.body(size: 12, weight: FontWeight.w700, color: documento.subido ? AppColors.greenDark : AppColors.navy)),
          ],
        ),
      ),
    );
  }
}
