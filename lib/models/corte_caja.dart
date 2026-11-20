/// Resumen de ventas del día para el corte de caja — no depende de un
/// turno por empleado (este comercio no maneja rol de Cajero), solo de si
/// el administrador ya cerró la caja de hoy o no.
class EstadoCorteCaja {
  final bool abierto;
  final DateTime? cerradoA;
  final int ventas;
  final double total;
  final double promedio;

  const EstadoCorteCaja({
    required this.abierto,
    required this.cerradoA,
    required this.ventas,
    required this.total,
    required this.promedio,
  });
}
