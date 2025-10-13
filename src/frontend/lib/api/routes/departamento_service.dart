import 'dart:convert';
import 'package:http/http.dart' as http;

class DepartamentoService {
  final String baseUrl;
  final Map<String, String> headers = {
    'Accept': 'application/json',
    'User-Agent': 'Flutter-Client',
  };

  // Simula las cookies de sesión
  Map<String, String> cookies = {};

  DepartamentoService(this.baseUrl);

  // Asegura que haya cookies antes de hacer peticiones
  Future<void> _ensureCookies() async {
    if (cookies.isEmpty) {
      final response = await http.get(Uri.parse(baseUrl), headers: headers);
      if (response.statusCode == 200) {
        _updateCookies(response);
      } else {
        throw Exception('No se pudieron obtener cookies');
      }
    }
  }

  // Actualiza cookies
  void _updateCookies(http.Response response) {
    final rawCookies = response.headers['set-cookie'];
    if (rawCookies != null) {
      final cookie = rawCookies.split(';')[0];
      cookies['cookie'] = cookie;
      headers['cookie'] = cookie;
    }
  }

  // GET /departamentos/
  Future<List<dynamic>> getDepartamentos() async {
    await _ensureCookies();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener departamentos: ${response.statusCode}');
    }
  }

  // GET /departamentos/{id}
  Future<Map<String, dynamic>> getDepartamento(int id) async {
    await _ensureCookies();
    final response = await http.get(Uri.parse('$baseUrl$id'), headers: headers);

    if (response.statusCode == 200 || response.statusCode == 204) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Departamento con ID $id no encontrado');
    } else {
      throw Exception('Error al obtener departamento: ${response.statusCode}');
    }
  }

  // POST /departamentos/
  Future<void> createDepartamento(Map<String, dynamic> departamento) async {
    await _ensureCookies();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode(departamento),
    );

    if (![200, 201, 204].contains(response.statusCode)) {
      throw Exception('Error al crear departamento: ${response.statusCode}');
    }
  }

  // PUT /departamentos/{id}
  Future<void> updateDepartamento(int id, Map<String, dynamic> departamento) async {
    await _ensureCookies();
    final response = await http.put(
      Uri.parse('$baseUrl$id'),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode(departamento),
    );

    if (![200, 204].contains(response.statusCode)) {
      throw Exception('Error al actualizar departamento: ${response.statusCode}');
    }
  }

  // DELETE /departamentos/{id}
  Future<void> deleteDepartamento(int id) async {
    await _ensureCookies();
    final response = await http.delete(Uri.parse('$baseUrl$id'), headers: headers);

    if (![200, 204].contains(response.statusCode)) {
      throw Exception('Error al eliminar departamento: ${response.statusCode}');
    }
  }
}
