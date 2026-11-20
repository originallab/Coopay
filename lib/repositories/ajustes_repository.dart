class AjustesSeguridad {
  final bool biometriaActiva;
  final bool ocultarSaldos;
  const AjustesSeguridad({required this.biometriaActiva, required this.ocultarSaldos});
}

abstract class AjustesRepository {
  Future<AjustesSeguridad> obtener();
  Future<void> actualizar({bool? biometriaActiva, bool? ocultarSaldos});

  /// No valida el PIN actual contra nada real — no hay backend todavía.
  /// Simula la latencia y el "éxito" que vería el usuario.
  Future<void> cambiarPin(String nuevoPin);
}

class MockAjustesRepository implements AjustesRepository {
  bool _biometria = true;
  bool _ocultarSaldos = true;

  @override
  Future<AjustesSeguridad> obtener() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return AjustesSeguridad(biometriaActiva: _biometria, ocultarSaldos: _ocultarSaldos);
  }

  @override
  Future<void> actualizar({bool? biometriaActiva, bool? ocultarSaldos}) async {
    if (biometriaActiva != null) _biometria = biometriaActiva;
    if (ocultarSaldos != null) _ocultarSaldos = ocultarSaldos;
  }

  @override
  Future<void> cambiarPin(String nuevoPin) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }
}
