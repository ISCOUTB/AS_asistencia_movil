import 'dart:convert';
import '../core/http_client.dart';

class ServicioEndpoint {
  final HttpClient http;

  ServicioEndpoint(this.http);

  // GET /servicios/
  Future<List<dynamic>> getServicios() async {
    final resp = await http.get("/servicios/");

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    }

    throw Exception("Error al obtener servicios: ${resp.statusCode}");
  }

  // GET /servicios/{id}
  Future<Map<String, dynamic>> getServicio(int id) async {
    final resp = await http.get("/servicios/$id");

    if (resp.statusCode == 200 || resp.statusCode == 204) {
      return jsonDecode(resp.body);
    }

    if (resp.statusCode == 404) {
      throw Exception("Servicio con ID $id no encontrado");
    }

    throw Exception("Error al obtener servicio: ${resp.statusCode}");
  }

  // GET /servicios?q={"id_departamento": X}
  Future<List<dynamic>> getServiciosPorDepartamento(int idDepartamento) async {
    final resp = await http.get(
      "/servicios/",
      query: {
        "q": {
          "id_departamento": idDepartamento
        }
      },
    );

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    }

    if (resp.statusCode == 404) {
      return [];
    }

    throw Exception("Error al obtener servicios por departamento: ${resp.statusCode}");
  }

  // POST /servicios/
  Future<void> createServicio(Map<String, dynamic> servicio) async {
    final resp = await http.post("/servicios/", servicio);

    if (![200, 201, 204].contains(resp.statusCode)) {
      throw Exception("Error al crear servicio: ${resp.statusCode}");
    }
  }

  // PUT /servicios/{id}
  Future<void> updateServicio(int id, Map<String, dynamic> servicio) async {
    final resp = await http.put("/servicios/$id", servicio);

    if (![200, 204].contains(resp.statusCode)) {
      throw Exception("Error al actualizar servicio: ${resp.statusCode}");
    }
  }

  // DELETE /servicios/{id}
  Future<void> deleteServicio(int id) async {
    final resp = await http.delete("/servicios/$id");

    if (![200, 204].contains(resp.statusCode)) {
      throw Exception("Error al eliminar servicio: ${resp.statusCode}");
    }
  }
}
