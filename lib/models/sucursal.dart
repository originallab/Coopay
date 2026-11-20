/// Una sucursal física de un comercio — varias sucursales pueden compartir
/// el mismo comercio/cuenta receptora, cada una con su propio QR de
/// mostrador para imprimir. No implica un rol de empleado distinto: sigue
/// siendo el Administrador quien la gestiona.
class Sucursal {
  final String id;
  final String nombre;
  final String direccion;

  const Sucursal({required this.id, required this.nombre, required this.direccion});
}
