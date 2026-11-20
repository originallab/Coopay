/// Un supervisor con acceso vigente a un comercio. Espejo de `ComercioRol`
/// (rol = SUPERVISOR) en prisma/schema.prisma.
class Supervisor {
  final String id;
  final String nombre;
  final String contacto;
  final DateTime desde;

  const Supervisor({required this.id, required this.nombre, required this.contacto, required this.desde});
}
