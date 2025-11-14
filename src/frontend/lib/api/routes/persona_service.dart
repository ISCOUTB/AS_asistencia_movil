import 'dart:convert';
import 'package:http/http.dart' as http;

class PersonaService {
  final String baseUrl;
  final Map<String, String> headers = {
    'Accept': 'application/json',
    'User-Agent': 'Flutter-Client',
  };

  // Simula las cookies de sesión
  Map<String, String> cookies = {};

  PersonaService(this.baseUrl);

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

  // GET /personas/
  Future<List<dynamic>> getPersonas() async {
    await _ensureCookies();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener personas: ${response.statusCode}');
    }
  }

  // GET /personas/{id}
  Future<Map<String, dynamic>> getPersona(int id) async {
    await _ensureCookies();
    final response = await http.get(Uri.parse('$baseUrl$id'), headers: headers);

    if (response.statusCode == 200 || response.statusCode == 204) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Persona con ID $id no encontrada');
    } else {
      throw Exception('Error al obtener persona: ${response.statusCode}');
    }
  }

  // GET /personas/documento/{documento}
  Future<List<dynamic>> getPersonaPorDocumento(String documento) async {
    await _ensureCookies();
    final query = jsonEncode({'identificacion': documento});
    final url = Uri.parse('$baseUrl?q=$query');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Persona con documento $documento no encontrada');
    } else {
      throw Exception('Error al buscar persona: ${response.statusCode}');
    }
  }

  // GET /personas/correo_institucional/{correo}
  Future<List<dynamic>> getPersonaPorCorreo(String correo) async {
    await _ensureCookies();
    final query = jsonEncode({'correo_institucional': correo});
    final url = Uri.parse('$baseUrl?q=$query');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Persona con correo institucional: $correo no encontrada');
    } else {
      throw Exception('Error al buscar persona: ${response.statusCode}');
    }
  }


  // POST /personas/
  Future<void> createPersona(Map<String, dynamic> persona) async {
    await _ensureCookies();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode(persona),
    );

    if (![200, 201, 204].contains(response.statusCode)) {
      throw Exception('Error al crear persona: ${response.statusCode}');
    }
  }

  // PUT /personas/{id}
  Future<void> updatePersona(int id, Map<String, dynamic> persona) async {
    await _ensureCookies();
    final response = await http.put(
      Uri.parse('$baseUrl$id'),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode(persona),
    );

    if (![200, 204].contains(response.statusCode)) {
      throw Exception('Error al actualizar persona: ${response.statusCode}');
    }
  }

  // DELETE /personas/{id}
  Future<void> deletePersona(int id) async {
    await _ensureCookies();
    final response = await http.delete(Uri.parse('$baseUrl$id'), headers: headers);

    if (![200, 204].contains(response.statusCode)) {
      throw Exception('Error al eliminar persona: ${response.statusCode}');
    }
  }
}