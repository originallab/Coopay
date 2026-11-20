import '../models/comercio.dart';
import '../models/corte_caja.dart';
import '../models/invitacion_supervisor.dart';
import '../models/notificacion_comercio.dart';
import '../models/sucursal.dart';
import '../models/supervisor.dart';
import '../models/venta_comercio.dart';
import '../utils/fecha.dart';

abstract class ComerciosRepository {
  Future<List<ComercioResumen>> misComercios();
  Future<List<ComercioResumen>> comerciosQueSupervisio();
  Future<ComercioDetalle> obtenerComercio(String comercioId);
  Future<List<VentaComercio>> ventasDe(String comercioId);
  Future<VentaComercio> marcarReembolso(String comercioId, String ventaId);
  Future<void> actualizarDatosFiscales(
    String comercioId, {
    required String razonSocial,
    required String rfc,
    required String direccion,
  });
  Future<List<Supervisor>> supervisoresDe(String comercioId);
  Future<void> invitarSupervisor(String comercioId, String contacto);
  Future<void> revocarSupervisor(String comercioId, String supervisorId);
  Future<List<InvitacionRecibida>> invitacionesPendientes();

  /// Si `aceptar` es true, el comercio pasa a `comerciosQueSupervisio()` —
  /// igual que `ComercioRol` se crea al aceptar una `InvitacionSupervisor`.
  Future<void> responderInvitacion(String invitacionId, {required bool aceptar});

  Future<List<NotificacionComercio>> notificacionesDe(String comercioId);
  Future<void> marcarNotificacionesLeidas(String comercioId);

  Future<List<Sucursal>> sucursalesDe(String comercioId);
  Future<Sucursal> agregarSucursal(String comercioId, {required String nombre, required String direccion});

  Future<EstadoCorteCaja> estadoCorteCaja(String comercioId);
  Future<EstadoCorteCaja> cerrarCaja(String comercioId);

  /// Crea el comercio y lo agrega a `misComercios()` con rol Administrador
  /// — igual que `Comercio` + `ComercioRol` en prisma/schema.prisma.
  Future<ComercioResumen> habilitarComercio({
    required String cuentaReceptoraLabel,
    required String nombreComercial,
    required String razonSocial,
    required String rfc,
    required String giro,
    required String direccion,
  });
}

class MockComerciosRepository implements ComerciosRepository {
  final List<ComercioResumen> _misComercios = [
    const ComercioResumen(
      comercioId: 'com_coopmarket',
      nombreComercial: 'Tienda CoopMarket',
      cuentaReceptoraLabel: 'Caja Hipódromo',
      rol: RolComercio.administrador,
    ),
  ];

  final List<ComercioResumen> _superviso = [
    const ComercioResumen(
      comercioId: 'com_farmacianorte',
      nombreComercial: 'Farmacia Norte',
      cuentaReceptoraLabel: 'Caja Genera',
      rol: RolComercio.supervisor,
    ),
  ];

  final Map<String, ComercioDetalle> _detalles = {
    'com_coopmarket': const ComercioDetalle(
      id: 'com_coopmarket',
      nombreComercial: 'Tienda CoopMarket',
      razonSocial: 'CoopMarket S.A. de C.V.',
      rfc: 'CMA181004KT3',
      giro: 'Abarrotes y tiendas de conveniencia',
      direccion: 'Av. Hipódromo 120, Col. Condesa, C.P. 06140, CDMX',
      institucionReceptora: 'Caja Hipódromo',
    ),
    'com_farmacianorte': const ComercioDetalle(
      id: 'com_farmacianorte',
      nombreComercial: 'Farmacia Norte',
      razonSocial: 'Farmacia Norte S.A. de C.V.',
      rfc: 'FNO150322AB7',
      giro: 'Farmacia',
      direccion: 'Calle Norte 48, Col. San Rafael, C.P. 06470, CDMX',
      institucionReceptora: 'Caja Genera',
    ),
  };

  late final Map<String, List<VentaComercio>> _ventas = _datosVentasDemo();

  final Map<String, List<Supervisor>> _supervisores = {
    'com_coopmarket': [
      Supervisor(id: 'sup1', nombre: 'Ana Cervantes', contacto: 'ana.cervantes@email.com', desde: DateTime(2026, 10, 12)),
      Supervisor(id: 'sup2', nombre: 'Jorge Palacios', contacto: '+52 55 2231 0098', desde: DateTime(2026, 10, 28)),
    ],
  };

  final List<InvitacionRecibida> _invitacionesPendientes = [
    const InvitacionRecibida(
      id: 'inv1',
      comercioId: 'com_panaderia',
      comercioNombre: 'Panadería Dulce Hogar',
      invitadoPorNombre: 'Juan Pérez',
    ),
  ];

  late final Map<String, List<NotificacionComercio>> _notificaciones = _datosNotificacionesDemo();

  final Map<String, List<Sucursal>> _sucursales = {
    'com_coopmarket': [
      const Sucursal(id: 'suc1', nombre: 'Sucursal Centro', direccion: 'Av. Hipódromo 120, Col. Condesa, CDMX'),
      const Sucursal(id: 'suc2', nombre: 'Sucursal Norte', direccion: 'Calle Norte 48, Col. San Rafael, CDMX'),
    ],
    'com_farmacianorte': [
      const Sucursal(id: 'suc3', nombre: 'Sucursal Principal', direccion: 'Calle Norte 48, Col. San Rafael, CDMX'),
    ],
  };

  final Map<String, DateTime?> _cierreDeHoy = {};

  static Map<String, List<NotificacionComercio>> _datosNotificacionesDemo() {
    final ahora = DateTime.now();
    DateTime hace(int h) => ahora.subtract(Duration(hours: h));

    return {
      'com_coopmarket': [
        NotificacionComercio(
          id: 'nc1',
          categoria: CategoriaNotifComercio.pago,
          titulo: 'Pago recibido',
          detalle: 'Mariana López pagó en Caja Hipódromo · CP-30418-QR',
          createdAt: hace(3),
          ventaId: 'v1',
          montoTexto: '+\$350.00',
        ),
        NotificacionComercio(
          id: 'nc2',
          categoria: CategoriaNotifComercio.pago,
          titulo: 'Pago recibido',
          detalle: 'Diego Torres pagó en Caja Hipódromo · CP-30417-QR',
          createdAt: hace(4),
          leido: true,
          ventaId: 'v2',
          montoTexto: '+\$420.00',
        ),
        NotificacionComercio(
          id: 'nc3',
          categoria: CategoriaNotifComercio.pago,
          titulo: 'Pago recibido',
          detalle: 'Fernanda Ruiz pagó en Sucursal Centro · CP-30404-QR',
          createdAt: hace(5),
          leido: true,
          ventaId: 'v3',
          montoTexto: '+\$180.00',
        ),
        NotificacionComercio(
          id: 'nc4',
          categoria: CategoriaNotifComercio.pago,
          titulo: 'Pago recibido',
          detalle: 'Jorge Medina pagó en Sucursal Norte · CP-30398-QR',
          createdAt: hace(5),
          leido: true,
          ventaId: 'v4',
          montoTexto: '+\$275.00',
        ),
        NotificacionComercio(
          id: 'nc5',
          categoria: CategoriaNotifComercio.retiro,
          titulo: 'Retiro procesado',
          detalle: 'Enviado a BBVA México ···· 6035 · Folio RT-0068',
          createdAt: ahora.subtract(const Duration(days: 1)),
          leido: true,
          montoTexto: '-\$12,000.00',
        ),
        NotificacionComercio(
          id: 'nc6',
          categoria: CategoriaNotifComercio.retiro,
          titulo: 'Retiro procesado',
          detalle: 'Enviado a BBVA México ···· 6035 · Folio RT-0064',
          createdAt: ahora.subtract(const Duration(days: 8)),
          leido: true,
          montoTexto: '-\$15,000.00',
        ),
        NotificacionComercio(
          id: 'nc7',
          categoria: CategoriaNotifComercio.retiro,
          titulo: 'Retiro procesado',
          detalle: 'Enviado a Banorte ···· 2210 · Folio RT-0056',
          createdAt: ahora.subtract(const Duration(days: 15)),
          leido: true,
          montoTexto: '-\$15,000.00',
        ),
        NotificacionComercio(
          id: 'nc8',
          categoria: CategoriaNotifComercio.aviso,
          titulo: 'Nuevo dispositivo vinculado',
          detalle: 'Se inició sesión en un teléfono nuevo con el usuario de Administrador.',
          createdAt: hace(9),
        ),
        NotificacionComercio(
          id: 'nc9',
          categoria: CategoriaNotifComercio.aviso,
          titulo: 'Actualización de términos',
          detalle: 'Revisa los cambios al contrato de comercio antes del 15 de noviembre.',
          createdAt: ahora.subtract(const Duration(days: 3)),
          leido: true,
        ),
        NotificacionComercio(
          id: 'nc10',
          categoria: CategoriaNotifComercio.aviso,
          titulo: 'Mantenimiento programado',
          detalle: 'El sábado de 02:00 a 04:00 los cobros podrían tardar más de lo normal.',
          createdAt: ahora.subtract(const Duration(days: 6)),
          leido: true,
        ),
      ],
    };
  }

  static Map<String, List<VentaComercio>> _datosVentasDemo() {
    final ahora = DateTime.now();
    DateTime haceDias(int d, int h, int m) => DateTime(ahora.year, ahora.month, ahora.day - d, h, m);

    return {
      'com_coopmarket': [
        VentaComercio(
            id: 'v1',
            folio: 'CP-30418-QR',
            socioNombre: 'Mariana López',
            monto: 350,
            createdAt: haceDias(0, 10, 47),
            concepto: 'Abarrotes / Mesa 4',
            cobradoPor: 'Mariana Soto · Caja 1'),
        VentaComercio(id: 'v2', folio: 'CP-30417-QR', socioNombre: 'Diego Torres', monto: 420, createdAt: haceDias(0, 10, 15)),
        VentaComercio(id: 'v3', folio: 'CP-30404-QR', socioNombre: 'Fernanda Ruiz', monto: 180, createdAt: haceDias(0, 9, 41)),
        VentaComercio(id: 'v4', folio: 'CP-30398-QR', socioNombre: 'Jorge Medina', monto: 275, createdAt: haceDias(0, 9, 15)),
        VentaComercio(id: 'v5', folio: 'CP-30391-QR', socioNombre: 'Sofía Ramírez', monto: 125, createdAt: haceDias(0, 8, 52)),
        VentaComercio(id: 'v6', folio: 'CP-30388-QR', socioNombre: 'Carlos Mena', monto: 90, createdAt: haceDias(0, 8, 35), reembolsada: true),
        VentaComercio(id: 'v7', folio: 'CP-30385-QR', socioNombre: 'Luis Herrera', monto: 500, createdAt: haceDias(0, 8, 20)),
        VentaComercio(id: 'v8', folio: 'CP-30362-QR', socioNombre: 'Ana Pérez', monto: 310, createdAt: haceDias(2, 14, 2)),
        VentaComercio(id: 'v9', folio: 'CP-30340-QR', socioNombre: 'Valeria Cruz', monto: 220, createdAt: haceDias(3, 12, 18)),
        VentaComercio(id: 'v10', folio: 'CP-30301-QR', socioNombre: 'Rosa Nava', monto: 480, createdAt: haceDias(5, 17, 44)),
        VentaComercio(id: 'v11', folio: 'CP-30288-QR', socioNombre: 'Pedro Salgado', monto: 65, createdAt: haceDias(6, 11, 5), reembolsada: true),
        VentaComercio(id: 'v12', folio: 'CP-30201-QR', socioNombre: 'Héctor Ramos', monto: 405, createdAt: haceDias(9, 16, 30)),
        VentaComercio(id: 'v13', folio: 'CP-30122-QR', socioNombre: 'Lucía Flores', monto: 300, createdAt: haceDias(12, 9, 50)),
      ],
      'com_farmacianorte': [
        VentaComercio(id: 'fn1', folio: 'FN-20481-QR', socioNombre: 'Socio verificado', monto: 340, createdAt: haceDias(0, 11, 12)),
        VentaComercio(id: 'fn2', folio: 'FN-20477-QR', socioNombre: 'Socio verificado', monto: 210, createdAt: haceDias(0, 10, 50)),
        VentaComercio(id: 'fn3', folio: 'FN-20465-QR', socioNombre: 'Socio verificado', monto: 480, createdAt: haceDias(0, 10, 21)),
        VentaComercio(id: 'fn4', folio: 'FN-20452-QR', socioNombre: 'Socio verificado', monto: 190, createdAt: haceDias(0, 9, 47)),
        VentaComercio(id: 'fn5', folio: 'FN-20440-QR', socioNombre: 'Socio verificado', monto: 255, createdAt: haceDias(0, 9, 10)),
        VentaComercio(id: 'fn6', folio: 'FN-20431-QR', socioNombre: 'Socio verificado', monto: 665, createdAt: haceDias(0, 8, 35)),
      ],
    };
  }

  @override
  Future<List<ComercioResumen>> misComercios() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_misComercios);
  }

  @override
  Future<List<ComercioResumen>> comerciosQueSupervisio() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_superviso);
  }

  @override
  Future<ComercioDetalle> obtenerComercio(String comercioId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final d = _detalles[comercioId];
    if (d == null) throw StateError('Comercio no encontrado o sin acceso');
    return d;
  }

  @override
  Future<List<VentaComercio>> ventasDe(String comercioId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final lista = _ventas[comercioId] ?? const [];
    final ordenada = [...lista]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(ordenada);
  }

  @override
  Future<VentaComercio> marcarReembolso(String comercioId, String ventaId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lista = _ventas[comercioId];
    if (lista == null) throw StateError('Comercio no encontrado');
    final idx = lista.indexWhere((v) => v.id == ventaId);
    if (idx == -1) throw StateError('Venta no encontrada');
    final actualizada = lista[idx].copyWith(reembolsada: true);
    lista[idx] = actualizada;
    return actualizada;
  }

  @override
  Future<void> actualizarDatosFiscales(
    String comercioId, {
    required String razonSocial,
    required String rfc,
    required String direccion,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final actual = _detalles[comercioId];
    if (actual == null) return;
    _detalles[comercioId] = actual.copyWith(razonSocial: razonSocial, rfc: rfc, direccion: direccion);
  }

  @override
  Future<List<Supervisor>> supervisoresDe(String comercioId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_supervisores[comercioId] ?? const []);
  }

  @override
  Future<void> invitarSupervisor(String comercioId, String contacto) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<void> revocarSupervisor(String comercioId, String supervisorId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _supervisores[comercioId]?.removeWhere((s) => s.id == supervisorId);
  }

  @override
  Future<List<InvitacionRecibida>> invitacionesPendientes() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_invitacionesPendientes);
  }

  @override
  Future<void> responderInvitacion(String invitacionId, {required bool aceptar}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _invitacionesPendientes.indexWhere((i) => i.id == invitacionId);
    if (idx == -1) return;
    final inv = _invitacionesPendientes.removeAt(idx);
    if (aceptar) {
      _superviso.add(ComercioResumen(
        comercioId: inv.comercioId,
        nombreComercial: inv.comercioNombre,
        cuentaReceptoraLabel: '—',
        rol: RolComercio.supervisor,
      ));
    }
  }

  @override
  Future<List<NotificacionComercio>> notificacionesDe(String comercioId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final lista = [...(_notificaciones[comercioId] ?? const [])]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(lista);
  }

  @override
  Future<void> marcarNotificacionesLeidas(String comercioId) async {
    final lista = _notificaciones[comercioId];
    if (lista == null) return;
    for (var i = 0; i < lista.length; i++) {
      lista[i] = lista[i].copyWith(leido: true);
    }
  }

  @override
  Future<ComercioResumen> habilitarComercio({
    required String cuentaReceptoraLabel,
    required String nombreComercial,
    required String razonSocial,
    required String rfc,
    required String giro,
    required String direccion,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final id = 'com_${DateTime.now().microsecondsSinceEpoch}';
    final resumen = ComercioResumen(
      comercioId: id,
      nombreComercial: nombreComercial,
      cuentaReceptoraLabel: cuentaReceptoraLabel,
      rol: RolComercio.administrador,
    );
    _misComercios.add(resumen);
    _detalles[id] = ComercioDetalle(
      id: id,
      nombreComercial: nombreComercial,
      razonSocial: razonSocial,
      rfc: rfc,
      giro: giro,
      direccion: direccion,
      institucionReceptora: cuentaReceptoraLabel,
    );
    _ventas[id] = [];
    _supervisores[id] = [];
    _notificaciones[id] = [];
    _sucursales[id] = [];
    return resumen;
  }

  @override
  Future<List<Sucursal>> sucursalesDe(String comercioId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_sucursales[comercioId] ?? const []);
  }

  @override
  Future<Sucursal> agregarSucursal(String comercioId, {required String nombre, required String direccion}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final sucursal = Sucursal(id: 'suc_${DateTime.now().microsecondsSinceEpoch}', nombre: nombre, direccion: direccion);
    _sucursales.putIfAbsent(comercioId, () => []).add(sucursal);
    return sucursal;
  }

  EstadoCorteCaja _calcularEstadoCorteCaja(String comercioId) {
    final ventasHoy = (_ventas[comercioId] ?? const [])
        .where((v) => esHoy(v.createdAt) && !v.reembolsada)
        .toList();
    final total = ventasHoy.fold<double>(0, (a, v) => a + v.monto);
    final promedio = ventasHoy.isEmpty ? 0.0 : total / ventasHoy.length;
    final cierre = _cierreDeHoy[comercioId];
    final abierto = cierre == null || !esHoy(cierre);
    return EstadoCorteCaja(
      abierto: abierto,
      cerradoA: abierto ? null : cierre,
      ventas: ventasHoy.length,
      total: total,
      promedio: promedio,
    );
  }

  @override
  Future<EstadoCorteCaja> estadoCorteCaja(String comercioId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _calcularEstadoCorteCaja(comercioId);
  }

  @override
  Future<EstadoCorteCaja> cerrarCaja(String comercioId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _cierreDeHoy[comercioId] = DateTime.now();
    return _calcularEstadoCorteCaja(comercioId);
  }
}
