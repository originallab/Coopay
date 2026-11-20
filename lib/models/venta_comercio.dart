/// Un cobro recibido por el comercio vía QR, visto desde el lado del
/// comercio (no del socio pagador). Espejo parcial de `Movimiento` +
/// `PagoQr` en prisma/schema.prisma, con el folio que ya usaba el prototipo.
class VentaComercio {
  final String id;
  final String folio;
  final String socioNombre;
  final double monto;
  final DateTime createdAt;
  final bool reembolsada;
  final String? concepto;
  final String? cobradoPor;

  const VentaComercio({
    required this.id,
    required this.folio,
    required this.socioNombre,
    required this.monto,
    required this.createdAt,
    this.reembolsada = false,
    this.concepto,
    this.cobradoPor,
  });

  String get iniciales {
    final partes = socioNombre.trim().split(RegExp(r'\s+'));
    return partes.take(2).map((p) => p.isEmpty ? '' : p[0]).join().toUpperCase();
  }

  VentaComercio copyWith({bool? reembolsada}) => VentaComercio(
        id: id,
        folio: folio,
        socioNombre: socioNombre,
        monto: monto,
        createdAt: createdAt,
        reembolsada: reembolsada ?? this.reembolsada,
        concepto: concepto,
        cobradoPor: cobradoPor,
      );
}
