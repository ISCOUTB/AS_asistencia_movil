import 'dart:convert';
import 'package:http/http.dart' as http;

class ServicioService {
  final String baseUrl;
  final Map<String, String> headers = {
    'Accept': 'application/json',
    'User-Agent': 'Flutter-Client',
  };

  ServicioService(this.baseUrl);

  // GET /servicios/
  Future<List<dynamic>> getServicios() async {
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
      throw Exception('Error al obtener servicios: ${response.statusCode}');
    }
  }

  // GET /servicios/{id}
  Future<Map<String, dynamic>> getServicio(int id) async {
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
      throw Exception('Servicio con ID $id no encontrado');
    } else {
      throw Exception('Error al obtener servicio: ${response.statusCode}');
    }
  }

  // GET /servicios/departamento/{id_departamento}
  Future<List<dynamic>> getServiciosPorDepartamento(int idDepartamento) async {
    final query = jsonEncode({'id_departamento': idDepartamento});
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
    } else {
      throw Exception('Error al obtener servicios por departamento: ${response.statusCode}');
    }
  }

  // POST /servicios/
  Future<void> createServicio(Map<String, dynamic> servicio) async {
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
    final response = await http.delete(Uri.parse('$baseUrl$id'), headers: headers);

    if (![200, 204].contains(response.statusCode)) {
      throw Exception('Error al eliminar servicio: ${response.statusCode}');
    }
  }
}