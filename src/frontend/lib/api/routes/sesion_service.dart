import 'dart:convert';
import 'package:http/http.dart' as http;

class SesionService {
  final String baseUrl;
  final Map<String, String> headers = {
    'Accept': 'application/json',
    'User-Agent': 'Flutter-Client',
  };

  SesionService(this.baseUrl);

  // GET /sesion/
  Future<List<dynamic>> getSesiones() async {
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Oracle ORDS devuelve {items: [...]} o directamente una lista
      if (data is Map && data.containsKey('items')) {
        return data['items'] as List<dynamic>;
      } else if (data is List) {
        return data;
      } else {
        throw Exception('Formato de respuesta inesperado');
      }
    } else {
      throw Exception('Error al obtener sesiones: ${response.statusCode}');
    }
  }

  // GET /sesion/{id}
  Future<Map<String, dynamic>> getSesion(int id) async {
    final response = await http.get(Uri.parse('$baseUrl$id'), headers: headers);

    if (response.statusCode == 200 || response.statusCode == 204) {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('items') && (data['items'] as List).isNotEmpty) {
        return (data['items'] as List)[0];
      } else if (data is Map) {
        return data as Map<String, dynamic>;
      } else {
        throw Exception('Formato de respuesta inesperado');
      }
    } else if (response.statusCode == 404) {
      throw Exception('Sesión con ID $id no encontrada');
    } else {
      throw Exception('Error al obtener sesión: ${response.statusCode}');
    }
  }

  // GET /sesion/servicio/{id_servicio}
  Future<List<dynamic>> getSesionesPorServicio(int idServicio) async {
    final query = jsonEncode({'id_servicio': idServicio});
    final url = Uri.parse('$baseUrl?q=$query');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('items')) {
        return data['items'] as List<dynamic>;
      } else if (data is List) {
        return data;
      } else {
        throw Exception('Formato de respuesta inesperado');
      }
    } else if (response.statusCode == 404) {
      throw Exception('No se encontraron sesiones para el servicio $idServicio');
    } else {
      throw Exception('Error al obtener sesiones: ${response.statusCode}');
    }
  }

  // POST /sesion/
  Future<void> createSesion(Map<String, dynamic> sesion) async {
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
    final response = await http.delete(Uri.parse('$baseUrl$id'), headers: headers);

    if (![200, 204].contains(response.statusCode)) {
      throw Exception('Error al eliminar sesión: ${response.statusCode}');
    }
  }
}