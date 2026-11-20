import '../models/usuario.dart';

/// Contrato de autenticación. La identidad real la resuelve OriginalAuth
/// (sesión + callback + polling — ver integrations/original-auth/ del
/// playbook); este repositorio es la cara que el resto de la app ve, sin
/// conocer ese detalle.
abstract class AuthRepository {
  Future<Usuario?> usuarioActual();
  Future<Usuario> iniciarSesion({required String email});
  Future<void> cerrarSesion();
}

/// Implementación simulada — sustituir por una que llame al backend real
/// una vez que exista `POST /auth/validate` (ver README de este proyecto).
class MockAuthRepository implements AuthRepository {
  Usuario? _actual;

  @override
  Future<Usuario?> usuarioActual() async => _actual;

  @override
  Future<Usuario> iniciarSesion({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _actual = const Usuario(
      id: 'usr_demo_001',
      email: 'nicolas.ibarra@example.com',
      nombre: 'Nicolás Ibarra',
      perfilCompleto: true,
    );
    return _actual!;
  }

  @override
  Future<void> cerrarSesion() async {
    _actual = null;
  }
}
