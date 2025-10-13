import 'dart:convert';
import 'package:http/http.dart' as http;

class AsistenciaService {
  final String baseUrl;
  final Map<String, String> headers = {
    'Accept': 'application/json',
    'User-Agent': 'Flutter-Client',
  };

  // Simula las cookies de sesión
  Map<String, String> cookies = {};

  AsistenciaService(this.baseUrl);

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

  // Actualiza cookies de la sesión
  void _updateCookies(http.Response response) {
    final rawCookies = response.headers['set-cookie'];
    if (rawCookies != null) {
      final cookie = rawCookies.split(';')[0];
      cookies['cookie'] = cookie;
      headers['cookie'] = cookie;
    }
  }

  // GET /asistencias/
  Future<List<dynamic>> getTodasAsistencias() async {
    await _ensureCookies();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener asistencias: ${response.statusCode}');
    }
  }

  // GET /asistencias/{id}
  Future<Map<String, dynamic>> getAsistencia(int id) async {
    await _ensureCookies();
    final response = await http.get(Uri.parse('$baseUrl$id'), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Asistencia con ID $id no encontrada');
    } else {
      throw Exception('Error al obtener asistencia: ${response.statusCode}');
    }
  }

  // GET /asistencias/persona/{id_persona}
  Future<List<dynamic>> getAsistenciasPorPersona(int idPersona) async {
    await _ensureCookies();
    final query = jsonEncode({'id_persona': idPersona});
    final url = Uri.parse('$baseUrl?q=$query');

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener asistencias por persona: ${response.statusCode}');
    }
  }

  // GET /asistencias/sesion/{id_sesion}
  Future<List<dynamic>> getAsistenciasPorSesion(int idSesion) async {
    await _ensureCookies();
    final query = jsonEncode({'id_sesiones': idSesion});
    final url = Uri.parse('$baseUrl?q=$query');

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener asistencias por sesión: ${response.statusCode}');
    }
  }

  // POST /asistencias/
  Future<void> createAsistencia(Map<String, dynamic> asistencia) async {
    await _ensureCookies();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode(asistencia),
    );

    if (![200, 201, 204].contains(response.statusCode)) {
      throw Exception('Error al crear asistencia: ${response.statusCode}');
    }
  }

  // PUT /asistencias/{id}
  Future<void> updateAsistencia(int id, Map<String, dynamic> asistencia) async {
    await _ensureCookies();
    final response = await http.put(
      Uri.parse('$baseUrl$id'),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode(asistencia),
    );

    if (![200, 204].contains(response.statusCode)) {
      throw Exception('Error al actualizar asistencia: ${response.statusCode}');
    }
  }

  // DELETE /asistencias/{id}
  Future<void> deleteAsistencia(int id) async {
    await _ensureCookies();
    final response = await http.delete(Uri.parse('$baseUrl$id'), headers: headers);

    if (![200, 204].contains(response.statusCode)) {
      throw Exception('Error al eliminar asistencia: ${response.statusCode}');
    }
  }
}
