import 'dart:convert';
import '../core/http_client.dart';

class SesionEndpoint {
  final HttpClient http;

  SesionEndpoint(this.http);

  // GET /sesion/
  Future<List<dynamic>> getSesiones() async {
    final resp = await http.get("/sesiones/");

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    }

    throw Exception("Error al obtener sesiones: ${resp.statusCode}");
  }

  // GET /sesion/{id}
  Future<Map<String, dynamic>> getSesion(int id) async {
    final resp = await http.get("/sesiones/$id");

    if (resp.statusCode == 200 || resp.statusCode == 204) {
      return jsonDecode(resp.body);
    }

    if (resp.statusCode == 404) {
      throw Exception("Sesión con ID $id no encontrada");
    }

    throw Exception("Error al obtener sesión: ${resp.statusCode}");
  }

  // GET /sesion?q={"id_servicio": X}
  Future<List<dynamic>> getSesionesPorServicio(int idServicio) async {
    final resp = await http.get(
      "/sesiones/",
      query: {
        "q": {
          "id_servicio": idServicio,
        }
      },
    );

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    }

    if (resp.statusCode == 404) {
      return []; 
    }

    throw Exception("Error al obtener sesiones por servicio: ${resp.statusCode}");
  }

  // POST /sesion/
  Future<void> createSesion(Map<String, dynamic> sesion) async {
    final resp = await http.post("/sesiones/", sesion);

    if (![200, 201, 204].contains(resp.statusCode)) {
      throw Exception("Error al crear sesión: ${resp.statusCode}");
    }
  }

  // PUT /sesion/{id}
  Future<void> updateSesion(int id, Map<String, dynamic> sesion) async {
    final resp = await http.put("/sesiones/$id", sesion);

    if (![200, 204].contains(resp.statusCode)) {
      throw Exception("Error al actualizar sesión: ${resp.statusCode}");
    }
  }

  // DELETE /sesion/{id}
  Future<void> deleteSesion(int id) async {
    final resp = await http.delete("/$id");

    if (![200, 204].contains(resp.statusCode)) {
      throw Exception("Error al eliminar sesión: ${resp.statusCode}");
    }
  }
}
