import 'dart:convert';
import 'package:http/http.dart' as http;

class FacilitadorService {
  final String baseUrl;
  final Map<String, String> headers = {
    'Accept': 'application/json',
    'User-Agent': 'Flutter-Client',
  };

  // Simula las cookies de sesión
  Map<String, String> cookies = {};

  FacilitadorService(this.baseUrl);

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

  void _updateCookies(http.Response response) {
    final rawCookies = response.headers['set-cookie'];
    if (rawCookies != null) {
      final cookie = rawCookies.split(';')[0];
      cookies['cookie'] = cookie;
      headers['cookie'] = cookie;
    }
  }

  // GET /facilitadores
  Future<List<dynamic>> getFacilitadores() async {
    await _ensureCookies();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener facilitadores: ${response.statusCode}');
    }
  }

  // GET /facilitadores/{id}
  Future<Map<String, dynamic>> getFacilitador(int id) async {
    await _ensureCookies();
    final response = await http.get(Uri.parse('$baseUrl$id'), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Facilitador con ID $id no encontrado');
    }
  }

  // POST /facilitadores
  Future<void> createFacilitador(Map<String, dynamic> facilitador) async {
    await _ensureCookies();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode(facilitador),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear facilitador: ${response.statusCode}');
    }
  }

  // PUT /facilitadores/{id}
  Future<void> updateFacilitador(int id, Map<String, dynamic> facilitador) async {
    await _ensureCookies();
    final response = await http.put(
      Uri.parse('$baseUrl$id'),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode(facilitador),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al actualizar facilitador: ${response.statusCode}');
    }
  }

  // DELETE /facilitadores/{id}
  Future<void> deleteFacilitador(int id) async {
    await _ensureCookies();
    final response = await http.delete(Uri.parse('$baseUrl$id'), headers: headers);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar facilitador: ${response.statusCode}');
    }
  }
}