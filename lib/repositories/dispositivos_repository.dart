import '../models/dispositivo.dart';

abstract class DispositivosRepository {
  Future<List<Dispositivo>> listarOtros();
  Future<void> cerrarSesion(String dispositivoId);
  Future<void> cerrarTodas();
}

class MockDispositivosRepository implements DispositivosRepository {
  final List<Dispositivo> _otros = [
    const Dispositivo(id: 'd1', nombre: 'iPad Air · Monterrey', actividad: 'Última actividad: hace 2 días'),
    const Dispositivo(id: 'd2', nombre: 'Chrome · Windows, Guadalajara', actividad: 'Última actividad: hace 5 días'),
  ];

  @override
  Future<List<Dispositivo>> listarOtros() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_otros);
  }

  @override
  Future<void> cerrarSesion(String dispositivoId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _otros.removeWhere((d) => d.id == dispositivoId);
  }

  @override
  Future<void> cerrarTodas() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _otros.clear();
  }
}
