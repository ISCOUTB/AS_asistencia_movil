import 'dart:convert';
import 'package:http/http.dart' as http;

class ServicioService {
  final String baseUrl;
  final Map<String, String> headers = {
    'Accept': 'application/json',
    'User-Agent': 'Flutter-Client',
  };

  // Simula las cookies de sesión
  Map<String, String> cookies = {};

  ServicioService(this.baseUrl);

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

  // GET /servicios/
  Future<List<dynamic>> getServicios() async {
    await _ensureCookies();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      return decoded["items"] as List;
    } else {
      throw Exception('Error al obtener servicios: ${response.statusCode}');
    }
  }

  // GET /servicios/{id}
  Future<Map<String, dynamic>> getServicio(int id) async {
    await _ensureCookies();
    final response = await http.get(Uri.parse('$baseUrl$id'), headers: headers);

    if (response.statusCode == 200 || response.statusCode == 204) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Servicio con ID $id no encontrado');
    } else {
      throw Exception('Error al obtener servicio: ${response.statusCode}');
    }
  }

  // GET /servicios/departamento/{id_departamento}
  Future<List<dynamic>> getServiciosPorDepartamento(int idDepartamento) async {
    await _ensureCookies();
    final query = jsonEncode({'id_departamento': idDepartamento});
    final url = Uri.parse('$baseUrl?q=$query');

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener servicios por departamento: ${response.statusCode}');
    }
  }

  // POST /servicios/
  Future<void> createServicio(Map<String, dynamic> servicio) async {
    await _ensureCookies();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode(servicio),
    );

    if (![200, 201, 204].contains(response.statusCode)) {
      throw Exception('Error al crear servicio: ${response.statusCode}');
    }
  }

  // PUT /servicios/{id}
  Future<void> updateServicio(int id, Map<String, dynamic> servicio) async {
    await _ensureCookies();
    final response = await http.put(
      Uri.parse('$baseUrl$id'),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode(servicio),
    );

    if (![200, 204].contains(response.statusCode)) {
      throw Exception('Error al actualizar servicio: ${response.statusCode}');
    }
  }

  // DELETE /servicios/{id}
  Future<void> deleteServicio(int id) async {
    await _ensureCookies();
    final response = await http.delete(Uri.parse('$baseUrl$id'), headers: headers);

    if (![200, 204].contains(response.statusCode)) {
      throw Exception('Error al eliminar servicio: ${response.statusCode}');
    }
  }
}
