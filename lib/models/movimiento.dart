enum TipoMovimiento { ingreso, egreso }

enum CanalMovimiento { pagoQr, transferenciaSocio, rendimiento, deposito, ajusteInterno }

/// Espejo de `Movimiento` en prisma/schema.prisma.
class Movimiento {
  final String id; // folio OP-XXXXXXXX
  final String cuentaId;
  final TipoMovimiento tipo;
  final CanalMovimiento canal;
  final double monto;
  final String? concepto;
  final String? contraparteNombre;
  final DateTime createdAt;

  const Movimiento({
    required this.id,
    required this.cuentaId,
    required this.tipo,
    required this.canal,
    required this.monto,
    this.concepto,
    this.contraparteNombre,
    required this.createdAt,
  });

  bool get esIngreso => tipo == TipoMovimiento.ingreso;

  factory Movimiento.fromJson(Map<String, dynamic> json) => Movimiento(
        id: json['id'] as String,
        cuentaId: json['cuentaId'] as String,
        tipo: TipoMovimiento.values.firstWhere((e) => e.name == json['tipo']),
        canal: CanalMovimiento.values.firstWhere((e) => e.name == json['canal']),
        monto: (json['monto'] as num).toDouble(),
        concepto: json['concepto'] as String?,
        contraparteNombre: json['contraparteNombre'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
