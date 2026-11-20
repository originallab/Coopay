import '../models/cuenta.dart';
import '../models/movimiento.dart';

class SaldoInsuficienteException implements Exception {
  final String message;
  const SaldoInsuficienteException([this.message = 'Saldo insuficiente en la cuenta de origen.']);
  @override
  String toString() => message;
}

abstract class CuentasRepository {
  Future<List<Cuenta>> listarCuentas();

  /// Busca dentro de las cuentas del socio autenticado — nunca por un `id`
  /// suelto sin pasar por el mismo filtro que `listarCuentas` (evita IDOR,
  /// playbook 03-seguridad.md punto 6). Lanza si no pertenece al socio.
  Future<Cuenta> obtenerCuenta(String cuentaId);

  Future<List<Movimiento>> movimientosDeCuenta(String cuentaId, {int limite = 10});

  /// Pago por QR a un comercio (lado socio). `claveIdempotencia` la genera
  /// quien llama (ver lib/utils/idempotency.dart) y debe reenviarse igual si
  /// se reintenta el mismo pago tras un error de red.
  Future<Movimiento> pagarConQr({
    required String cuentaId,
    required String comercioNombre,
    required double monto,
    required String claveIdempotencia,
  });

  /// Transferencia socio-a-socio por CLABE.
  Future<Movimiento> transferir({
    required String cuentaId,
    required String clabeDestino,
    required String nombreDestinatario,
    required double monto,
    required String claveIdempotencia,
  });
}

/// Mock — misma forma de datos que ya usaba el prototipo en Figma/Artifact
/// (Caja Hipódromo $12,480.50 / Caja Genera $3,210.00). A diferencia del
/// primer lote, aquí el saldo y los movimientos SÍ son mutables en memoria,
/// porque ya hay acciones que mueven dinero (pagar, transferir) y la demo
/// necesita reflejarlo al volver a Inicio/Detalle.
class MockCuentasRepository implements CuentasRepository {
  final List<Cuenta> _cuentas = [
    const Cuenta(
      id: 'cta_hipodromo',
      institucionNombre: 'Caja Hipódromo',
      producto: 'Cuenta Light',
      numeroCuenta: '41027790331 24821',
      clabe: '014180012345678213',
      saldoDisponible: 12480.50,
      esPrincipal: true,
    ),
    const Cuenta(
      id: 'cta_genera',
      institucionNombre: 'Caja Genera',
      producto: 'Cuenta de Ahorro',
      numeroCuenta: '41028841229 00237',
      clabe: '032180098765432109',
      saldoDisponible: 3210.00,
    ),
  ];

  final Map<String, List<Movimiento>> _movimientos = {
    'cta_hipodromo': [
      Movimiento(
        id: 'OP-30392001',
        cuentaId: 'cta_hipodromo',
        tipo: TipoMovimiento.egreso,
        canal: CanalMovimiento.pagoQr,
        monto: 186.00,
        contraparteNombre: 'Tienda CoopMarket',
        concepto: 'Pago QR · Comercio',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Movimiento(
        id: 'OP-91027002',
        cuentaId: 'cta_hipodromo',
        tipo: TipoMovimiento.ingreso,
        canal: CanalMovimiento.transferenciaSocio,
        monto: 500.00,
        contraparteNombre: 'Mariana López',
        concepto: 'Transferencia recibida',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ],
    'cta_genera': [
      Movimiento(
        id: 'OP-GEN-001',
        cuentaId: 'cta_genera',
        tipo: TipoMovimiento.ingreso,
        canal: CanalMovimiento.rendimiento,
        monto: 12.40,
        concepto: 'Interés mensual',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ],
  };

  // Reintentos con la misma clave regresan el movimiento ya creado en vez de
  // duplicarlo (03-seguridad.md punto 13).
  final Map<String, Movimiento> _porIdempotencia = {};

  @override
  Future<List<Cuenta>> listarCuentas() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_cuentas);
  }

  @override
  Future<Cuenta> obtenerCuenta(String cuentaId) async {
    final cuentas = await listarCuentas();
    return cuentas.firstWhere(
      (c) => c.id == cuentaId,
      orElse: () => throw StateError('Cuenta no encontrada o no pertenece al socio'),
    );
  }

  @override
  Future<List<Movimiento>> movimientosDeCuenta(String cuentaId, {int limite = 10}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lista = _movimientos[cuentaId] ?? const [];
    return List.unmodifiable(lista.take(limite));
  }

  Movimiento _mover({
    required String cuentaId,
    required CanalMovimiento canal,
    required double monto,
    required String claveIdempotencia,
    String? concepto,
    String? contraparteNombre,
  }) {
    final previo = _porIdempotencia[claveIdempotencia];
    if (previo != null) return previo;

    final idx = _cuentas.indexWhere((c) => c.id == cuentaId);
    if (idx == -1) throw StateError('Cuenta no encontrada o no pertenece al socio');
    final cuenta = _cuentas[idx];
    if (monto > cuenta.saldoDisponible) throw const SaldoInsuficienteException();

    _cuentas[idx] = cuenta.copyWith(saldoDisponible: cuenta.saldoDisponible - monto);

    final mov = Movimiento(
      id: _nuevoFolio(),
      cuentaId: cuentaId,
      tipo: TipoMovimiento.egreso,
      canal: canal,
      monto: monto,
      concepto: concepto,
      contraparteNombre: contraparteNombre,
      createdAt: DateTime.now(),
    );
    _movimientos.putIfAbsent(cuentaId, () => []).insert(0, mov);
    _porIdempotencia[claveIdempotencia] = mov;
    return mov;
  }

  @override
  Future<Movimiento> pagarConQr({
    required String cuentaId,
    required String comercioNombre,
    required double monto,
    required String claveIdempotencia,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mover(
      cuentaId: cuentaId,
      canal: CanalMovimiento.pagoQr,
      monto: monto,
      claveIdempotencia: claveIdempotencia,
      concepto: 'Pago QR · Comercio',
      contraparteNombre: comercioNombre,
    );
  }

  @override
  Future<Movimiento> transferir({
    required String cuentaId,
    required String clabeDestino,
    required String nombreDestinatario,
    required double monto,
    required String claveIdempotencia,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mover(
      cuentaId: cuentaId,
      canal: CanalMovimiento.transferenciaSocio,
      monto: monto,
      claveIdempotencia: claveIdempotencia,
      concepto: 'Transferencia enviada',
      contraparteNombre: nombreDestinatario,
    );
  }

  String _nuevoFolio() {
    final n = DateTime.now().microsecondsSinceEpoch % 100000000;
    return 'OP-${n.toString().padLeft(8, '0')}';
  }
}
