enum RolComercio { administrador, supervisor }

/// Vista resumida de un comercio + el rol del usuario actual ahí — combina
/// `Comercio` y `ComercioRol` de prisma/schema.prisma para lo que necesita
/// la UI (tarjetas en Inicio/Comercios), no el modelo de BD completo.
class ComercioResumen {
  final String comercioId;
  final String nombreComercial;
  final String cuentaReceptoraLabel; // "Caja Hipódromo"
  final RolComercio rol;
  final bool activo;

  const ComercioResumen({
    required this.comercioId,
    required this.nombreComercial,
    required this.cuentaReceptoraLabel,
    required this.rol,
    this.activo = true,
  });

  factory ComercioResumen.fromJson(Map<String, dynamic> json) => ComercioResumen(
        comercioId: json['comercioId'] as String,
        nombreComercial: json['nombreComercial'] as String,
        cuentaReceptoraLabel: json['cuentaReceptoraLabel'] as String,
        rol: RolComercio.values.firstWhere((e) => e.name == json['rol']),
        activo: json['activo'] as bool? ?? true,
      );
}

/// Datos completos de un comercio — lo que ve el panel de administrador y
/// la pantalla de datos fiscales. Espejo de `Comercio` en prisma/schema.prisma.
class ComercioDetalle {
  final String id;
  final String nombreComercial;
  final String razonSocial;
  final String rfc;
  final String giro;
  final String direccion;
  final String institucionReceptora;
  final bool activo;

  const ComercioDetalle({
    required this.id,
    required this.nombreComercial,
    required this.razonSocial,
    required this.rfc,
    required this.giro,
    required this.direccion,
    required this.institucionReceptora,
    this.activo = true,
  });

  ComercioDetalle copyWith({String? razonSocial, String? rfc, String? direccion}) => ComercioDetalle(
        id: id,
        nombreComercial: nombreComercial,
        razonSocial: razonSocial ?? this.razonSocial,
        rfc: rfc ?? this.rfc,
        giro: giro,
        direccion: direccion ?? this.direccion,
        institucionReceptora: institucionReceptora,
        activo: activo,
      );
}
