enum EstadoCuenta { activa, inactiva, bloqueada }

/// Espejo de `Cuenta` en prisma/schema.prisma.
class Cuenta {
  final String id;
  final String institucionNombre; // "Caja Hipódromo" | "Caja Genera" | ...
  final String producto; // "Cuenta Light" | "Cuenta de Ahorro"
  final String numeroCuenta;
  final String clabe;
  final double saldoDisponible;
  final String moneda;
  final EstadoCuenta estado;
  final bool esPrincipal;

  const Cuenta({
    required this.id,
    required this.institucionNombre,
    required this.producto,
    required this.numeroCuenta,
    required this.clabe,
    required this.saldoDisponible,
    this.moneda = 'MXN',
    this.estado = EstadoCuenta.activa,
    this.esPrincipal = false,
  });

  /// Últimos 4 dígitos, para mostrar en tarjetas ("····4821").
  String get ultimosDigitos =>
      numeroCuenta.length >= 4 ? numeroCuenta.substring(numeroCuenta.length - 4) : numeroCuenta;

  Cuenta copyWith({double? saldoDisponible}) => Cuenta(
        id: id,
        institucionNombre: institucionNombre,
        producto: producto,
        numeroCuenta: numeroCuenta,
        clabe: clabe,
        saldoDisponible: saldoDisponible ?? this.saldoDisponible,
        moneda: moneda,
        estado: estado,
        esPrincipal: esPrincipal,
      );

  factory Cuenta.fromJson(Map<String, dynamic> json) => Cuenta(
        id: json['id'] as String,
        institucionNombre: json['institucionNombre'] as String,
        producto: json['producto'] as String,
        numeroCuenta: json['numeroCuenta'] as String,
        clabe: json['clabe'] as String,
        saldoDisponible: (json['saldoDisponible'] as num).toDouble(),
        moneda: json['moneda'] as String? ?? 'MXN',
        estado: EstadoCuenta.values.firstWhere(
          (e) => e.name == json['estado'],
          orElse: () => EstadoCuenta.activa,
        ),
        esPrincipal: json['esPrincipal'] as bool? ?? false,
      );
}
