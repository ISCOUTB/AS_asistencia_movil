import 'dart:convert';
import '../core/http_client.dart';

class AsistenciaEndpoint {
  final HttpClient http;

  AsistenciaEndpoint(this.http);

  // GET /asistencias/
  Future<List<dynamic>> getTodasAsistencias() async {
    final resp = await http.get("/asistencia_sesiones/");

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    }

    throw Exception("Error al obtener asistencias: ${resp.statusCode}");
  }

  // GET /asistencias/{id}
  Future<Map<String, dynamic>> getAsistencia(int id) async {
    final resp = await http.get("/asistencia_sesiones/$id");

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    }

    if (resp.statusCode == 404) {
      throw Exception("Asistencia con ID $id no encontrada");
    }

    throw Exception("Error al obtener asistencia: ${resp.statusCode}");
  }

  // GET /asistencias?q={"id_persona": X}
  Future<List<dynamic>> getAsistenciasPorPersona(int idPersona) async {
    final resp = await http.get(
      "/asistencia_sesiones/",
      query: {
        "q": {
          "id_persona": idPersona,
        }
      },
    );

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    }

    throw Exception("Error al obtener asistencias por persona: ${resp.statusCode}");
  }

  // GET /asistencias?q={"id_sesiones": X}
  Future<List<dynamic>> getAsistenciasPorSesion(int idSesion) async {
    final resp = await http.get(
      "/asistencia_sesiones/",
      query: {
        "q": {
          "id_sesiones": idSesion,
        }
      },
    );

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    }

    throw Exception("Error al obtener asistencias por sesión: ${resp.statusCode}");
  }

  // POST /asistencias/
  Future<void> createAsistencia(Map<String, dynamic> asistencia) async {
    final resp = await http.post("/asistencia_sesiones/", asistencia);

    if (![200, 201, 204].contains(resp.statusCode)) {
      throw Exception("Error al crear asistencia: ${resp.statusCode}");
    }
  }

  // PUT /asistencias/{id}
  Future<void> updateAsistencia(int id, Map<String, dynamic> asistencia) async {
    final resp = await http.put("/asistencia_sesiones/$id", asistencia);

    if (![200, 204].contains(resp.statusCode)) {
      throw Exception("Error al actualizar asistencia: ${resp.statusCode}");
    }
  }

  // DELETE /asistencias/{id}
  Future<void> deleteAsistencia(int id) async {
    final resp = await http.delete("/asistencia_sesiones/$id");

    if (![200, 204].contains(resp.statusCode)) {
      throw Exception("Error al eliminar asistencia: ${resp.statusCode}");
    }
  }
}
