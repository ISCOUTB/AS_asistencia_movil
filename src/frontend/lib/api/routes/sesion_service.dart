import 'dart:convert';
import 'package:http/http.dart' as http;

class SesionService {
  final String baseUrl;
  final Map<String, String> headers = {
    'Accept': 'application/json',
    'User-Agent': 'Flutter-Client',
  };

  // Simula las cookies de sesión
  Map<String, String> cookies = {};

  SesionService(this.baseUrl);

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

  // GET /sesion/
  Future<List<dynamic>> getSesiones() async {
    await _ensureCookies();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener sesiones: ${response.statusCode}');
    }
  }

  // GET /sesion/{id}
  Future<Map<String, dynamic>> getSesion(int id) async {
    await _ensureCookies();
    final response = await http.get(Uri.parse('$baseUrl$id'), headers: headers);

    if (response.statusCode == 200 || response.statusCode == 204) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Sesión con ID $id no encontrada');
    } else {
      throw Exception('Error al obtener sesión: ${response.statusCode}');
    }
  }

  // GET /sesion/servicio/{id_servicio}
  Future<List<dynamic>> getSesionesPorServicio(int idServicio) async {
    await _ensureCookies();
    final query = jsonEncode({'id_servicio': idServicio});
    final url = Uri.parse('$baseUrl?q=$query');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('No se encontraron sesiones para el servicio $idServicio');
    } else {
      throw Exception('Error al obtener sesiones: ${response.statusCode}');
    }
  }

  // POST /sesion/
  Future<void> createSesion(Map<String, dynamic> sesion) async {
    await _ensureCookies();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode(sesion),
    );

    if (![200, 201, 204].contains(response.statusCode)) {
      throw Exception('Error al crear sesión: ${response.statusCode}');
    }
  }

  // PUT /sesion/{id}
  Future<void> updateSesion(int id, Map<String, dynamic> sesion) async {
    await _ensureCookies();
    final response = await http.put(
      Uri.parse('$baseUrl$id'),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode(sesion),
    );

    if (![200, 204].contains(response.statusCode)) {
      throw Exception('Error al actualizar sesión: ${response.statusCode}');
    }
  }

  // DELETE /sesion/{id}
  Future<void> deleteSesion(int id) async {
    await _ensureCookies();
    final response = await http.delete(Uri.parse('$baseUrl$id'), headers: headers);

    if (![200, 204].contains(response.statusCode)) {
      throw Exception('Error al eliminar sesión: ${response.statusCode}');
    }
  }
}
