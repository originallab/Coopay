/// Una sesión activa en otro dispositivo (no el actual). Espejo parcial de
/// `Sesion` en prisma/schema.prisma.
class Dispositivo {
  final String id;
  final String nombre;
  final String actividad;
  const Dispositivo({required this.id, required this.nombre, required this.actividad});
}
