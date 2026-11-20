/// Invitación pendiente que recibió el socio actual para supervisar un
/// comercio ajeno. Espejo de `InvitacionSupervisor` en prisma/schema.prisma.
class InvitacionRecibida {
  final String id;
  final String comercioId;
  final String comercioNombre;
  final String invitadoPorNombre;
  final String invitadoPorRol;

  const InvitacionRecibida({
    required this.id,
    required this.comercioId,
    required this.comercioNombre,
    required this.invitadoPorNombre,
    this.invitadoPorRol = 'Administrador',
  });
}
