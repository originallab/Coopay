import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Envoltorio mínimo sobre `http` para cuando el backend de CooPay exista.
/// Las implementaciones reales de cada repositorio (HttpCuentasRepository,
/// etc.) lo usan en vez de llamar a `http` directo — mismo principio de
/// capas que integrations/<servicio>/client.ts en el backend (playbook
/// 08-integracion-servicios-tol.md, punto 2).
class ApiClient {
  final http.Client _client;
  final String baseUrl;
  String? bearerToken; // el mismo `session` que entrega OriginalAuth

  ApiClient({http.Client? client, this.baseUrl = AppConfig.apiBaseUrl})
      : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
      };

  Future<http.Response> get(String path) =>
      _client.get(Uri.parse('$baseUrl$path'), headers: _headers);

  Future<http.Response> post(String path, Object body) => _client.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: body,
      );
}
