enum CategoriaNotifComercio { pago, retiro, aviso }

/// Notificación del lado comercio (no confundir con `Notificacion`, la del
/// socio) — tiene su propia pantalla y categorías en el prototipo
/// (NotificacionesComercio.dc.html): Pagos recibidos, Retiros procesados,
/// Avisos del sistema.
class NotificacionComercio {
  final String id;
  final CategoriaNotifComercio categoria;
  final String titulo;
  final String detalle;
  final DateTime createdAt;
  final bool leido;
  final String? ventaId;
  final String? montoTexto;

  const NotificacionComercio({
    required this.id,
    required this.categoria,
    required this.titulo,
    required this.detalle,
    required this.createdAt,
    this.leido = false,
    this.ventaId,
    this.montoTexto,
  });

  NotificacionComercio copyWith({bool? leido}) => NotificacionComercio(
        id: id,
        categoria: categoria,
        titulo: titulo,
        detalle: detalle,
        createdAt: createdAt,
        leido: leido ?? this.leido,
        ventaId: ventaId,
        montoTexto: montoTexto,
      );
}
