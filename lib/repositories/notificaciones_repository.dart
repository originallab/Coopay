import '../models/notificacion.dart';

abstract class NotificacionesRepository {
  Future<List<Notificacion>> listar();
  Future<int> contarNoLeidas();
  Future<void> marcarLeida(String id);
}

/// Mock con estado mutable en memoria — a diferencia de la mayoría de los
/// Mock... de este proyecto, aquí sí importa que "marcar como leída"
/// persista entre pantallas dentro de la misma sesión de la app.
class MockNotificacionesRepository implements NotificacionesRepository {
  final List<Notificacion> _datos = [
    Notificacion(
      id: 'notif_1',
      tipo: TipoNotificacion.pagoRecibido,
      titulo: 'Pago recibido',
      mensaje: 'Mariana López te transfirió \$500.00.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Notificacion(
      id: 'notif_2',
      tipo: TipoNotificacion.invitacionSupervisor,
      titulo: 'Invitación a supervisar',
      mensaje: 'Farmacia Norte te invitó como supervisor.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Notificacion(
      id: 'notif_3',
      tipo: TipoNotificacion.seguridad,
      titulo: 'Nuevo inicio de sesión',
      mensaje: 'Se inició sesión desde un dispositivo nuevo.',
      leido: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<Notificacion>> listar() async {
    await Future.delayed(const Duration(milliseconds: 250));
    _datos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(_datos);
  }

  @override
  Future<int> contarNoLeidas() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _datos.where((n) => !n.leido).length;
  }

  @override
  Future<void> marcarLeida(String id) async {
    final i = _datos.indexWhere((n) => n.id == id);
    if (i == -1) return;
    _datos[i] = _datos[i].copyWith(leido: true);
  }
}
