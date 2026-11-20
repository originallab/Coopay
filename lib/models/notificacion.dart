enum TipoNotificacion { pagoRecibido, pagoEnviado, invitacionSupervisor, seguridad, sistema }

/// Espejo de `Notificacion` en prisma/schema.prisma.
class Notificacion {
  final String id;
  final TipoNotificacion tipo;
  final String titulo;
  final String mensaje;
  final bool leido;
  final DateTime createdAt;

  const Notificacion({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    this.leido = false,
    required this.createdAt,
  });

  Notificacion copyWith({bool? leido}) => Notificacion(
        id: id,
        tipo: tipo,
        titulo: titulo,
        mensaje: mensaje,
        leido: leido ?? this.leido,
        createdAt: createdAt,
      );

  factory Notificacion.fromJson(Map<String, dynamic> json) => Notificacion(
        id: json['id'] as String,
        tipo: TipoNotificacion.values.firstWhere((e) => e.name == json['tipo']),
        titulo: json['titulo'] as String,
        mensaje: json['mensaje'] as String,
        leido: json['leido'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
