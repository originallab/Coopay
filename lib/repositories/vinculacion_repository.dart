enum TipoSolicitudVinculacion { cuentaExistente, cuentaNueva }

abstract class VinculacionRepository {
  /// Pide vincular una cuenta nueva o existente en `institucionNombre`. Para
  /// `cuentaNueva` el checklist de documentos ya se validó en la pantalla
  /// anterior (ver VincularDocumentosScreen) — aquí solo se registra la
  /// solicitud, igual que `SolicitudVinculacion` en prisma/schema.prisma.
  Future<void> solicitar({required TipoSolicitudVinculacion tipo, required String institucionNombre});
}

class MockVinculacionRepository implements VinculacionRepository {
  @override
  Future<void> solicitar({required TipoSolicitudVinculacion tipo, required String institucionNombre}) async {
    await Future.delayed(const Duration(milliseconds: 700));
  }
}
