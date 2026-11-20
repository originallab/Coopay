/// Espejo de `Usuario` en prisma/schema.prisma — ver coopay_esquema_bd/.
/// Nunca incluye contraseña: la identidad real la resuelve OriginalAuth.
class Usuario {
  final String id;
  final String email;
  final String nombre;
  final String? telefono;
  final bool perfilCompleto;

  const Usuario({
    required this.id,
    required this.email,
    required this.nombre,
    this.telefono,
    this.perfilCompleto = false,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'] as String,
        email: json['email'] as String,
        nombre: json['nombre'] as String,
        telefono: json['telefono'] as String?,
        perfilCompleto: json['perfilCompleto'] as bool? ?? false,
      );
}
