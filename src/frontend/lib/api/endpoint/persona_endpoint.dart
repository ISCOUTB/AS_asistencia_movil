import 'dart:convert';
import '../core/http_client.dart';

class PersonaEndpoint {
  final HttpClient http;

  PersonaEndpoint(this.http);

  // GET /personas/
  Future<List<dynamic>> getPersonas() async {
    final resp = await http.get("/personas/");

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    }

    throw Exception("Error al obtener personas: ${resp.statusCode}");
  }

  // GET /personas/{id}
  Future<Map<String, dynamic>> getPersona(int id) async {
    final resp = await http.get("/personas/$id");

    if (resp.statusCode == 200 || resp.statusCode == 204) {
      return jsonDecode(resp.body);
    }

    if (resp.statusCode == 404) {
      throw Exception("Persona con ID $id no encontrada");
    }

    throw Exception("Error al obtener persona: ${resp.statusCode}");
  }

  // GET /personas?q={"identificacion": "..."}
  Future<List<dynamic>> getPersonaPorDocumento(String documento) async {
    final resp = await http.get(
      "/personas/",
      query: {
        "q": {
          "identificacion": documento
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
      return []; // igual que tu servicio original
    }

    throw Exception("Error al buscar persona: ${resp.statusCode}");
  }

  // GET /personas?q={"correo_institucional": "..."}
  Future<List<dynamic>> getPersonaPorCorreo(String correo) async {
    final resp = await http.get(
      "/personas/",
      query: {
        "q": {
          "correo_institucional": correo
        }
      },
    );

    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);

      // extraemos la lista de items si existe
      if (decoded is Map<String, dynamic> && decoded["items"] is List) {
        return decoded["items"];
      } else {
        return [];
      }
    }

    if (resp.statusCode == 404) {
      return [];
    }

    throw Exception("Error al buscar persona: ${resp.statusCode}");
  }

  // POST /personas/
  Future<void> createPersona(Map<String, dynamic> persona) async {
    final resp = await http.post("/personas/", persona);

    if (![200, 201, 204].contains(resp.statusCode)) {
      throw Exception("Error al crear persona: ${resp.statusCode}");
    }
  }

  // PUT /personas/{id}
  Future<void> updatePersona(int id, Map<String, dynamic> persona) async {
    final resp = await http.put("/personas/$id", persona);

    if (![200, 204].contains(resp.statusCode)) {
      throw Exception("Error al actualizar persona: ${resp.statusCode}");
    }
  }

  // DELETE /personas/{id}
  Future<void> deletePersona(int id) async {
    final resp = await http.delete("/personas/$id");

    if (![200, 204].contains(resp.statusCode)) {
      throw Exception("Error al eliminar persona: ${resp.statusCode}");
    }
  }
}
