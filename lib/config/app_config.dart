/// Configuración centralizada — único lugar que lee variables de entorno
/// (playbook 02-arquitectura-base.md: "nunca dispersas por todo el código").
///
/// Hoy `useMockData` está en `true` a propósito: el backend de CooPay
/// todavía no existe (ver conversación con el equipo de backend). Cuando
/// esté listo el Swagger real, este flag se apaga y `ApiClient.baseUrl`
/// apunta al backend desplegado — ningún otro archivo debería necesitar
/// cambios para hacer ese switch.
class AppConfig {
  AppConfig._();

  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: true,
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.coopay.example.com', // placeholder — actualizar cuando exista
  );
}
