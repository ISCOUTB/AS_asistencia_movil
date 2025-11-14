import 'dart:convert';
import '../core/http_client.dart';

class FacilitadorEndpoint {
  final HttpClient http;

  FacilitadorEndpoint(this.http);

  // GET /facilitadores/
  Future<List<dynamic>> getFacilitadores() async {
    final resp = await http.get("/facilitadores/");

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    }

    throw Exception("Error al obtener facilitadores: ${resp.statusCode}");
  }

  // GET /facilitadores/{id}
  Future<Map<String, dynamic>> getFacilitador(int id) async {
    final resp = await http.get("/facilitadores/$id");

    if (resp.statusCode == 200 || resp.statusCode == 204) {
      return jsonDecode(resp.body);
    }

    if (resp.statusCode == 404) {
      throw Exception("Facilitador con ID $id no encontrado");
    }

    throw Exception("Error al obtener facilitador: ${resp.statusCode}");
  }

  // GET /facilitadores?q={"correo_institucional": "..."}
  Future<List<dynamic>> getFacilitadorPorCorreo(String correo) async {
    final resp = await http.get(
      "/facilitadores/",
      query: {
        "q": {
          "correo_institucional": correo,
        }
      },
    );

    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);

      // Si viene un Map, lo convertimos en una lista de 1 elemento
      if (decoded is Map<String, dynamic>) {
        return [decoded];
      } else if (decoded is List) {
        return decoded;
      } else {
        return [];
      }
    }

    if (resp.statusCode == 404) {
      return [];
    }

    throw Exception("Error al buscar facilitador: ${resp.statusCode}");
  }

  // POST /facilitadores/
  Future<void> createFacilitador(Map<String, dynamic> facilitador) async {
    final resp = await http.post("/facilitadores/", facilitador);

    if (![200, 201, 204].contains(resp.statusCode)) {
      throw Exception("Error al crear facilitador: ${resp.statusCode}");
    }
  }

  // PUT /facilitadores/{id}
  Future<void> updateFacilitador(int id, Map<String, dynamic> facilitador) async {
    final resp = await http.put("/facilitadores/$id", facilitador);

    if (![200, 204].contains(resp.statusCode)) {
      throw Exception("Error al actualizar facilitador: ${resp.statusCode}");
    }
  }

  // DELETE /facilitadores/{id}
  Future<void> deleteFacilitador(int id) async {
    final resp = await http.delete("/facilitadores/$id");

    if (![200, 204].contains(resp.statusCode)) {
      throw Exception("Error al eliminar facilitador: ${resp.statusCode}");
    }
  }
}
