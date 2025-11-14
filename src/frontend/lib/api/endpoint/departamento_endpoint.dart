import 'dart:convert';
import '../core/http_client.dart';

class DepartamentoEndpoint {
  final HttpClient http;

  DepartamentoEndpoint(this.http);

  // GET /departamentos/
  Future<List<dynamic>> getDepartamentos() async {
    final resp = await http.get("/departamento_eco/");

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    }

    throw Exception("Error al obtener departamentos: ${resp.statusCode}");
  }

  // GET /departamentos/{id}
  Future<Map<String, dynamic>> getDepartamento(int id) async {
    final resp = await http.get("/departamento_eco/$id");

    if (resp.statusCode == 200 || resp.statusCode == 204) {
      return jsonDecode(resp.body);
    }

    if (resp.statusCode == 404) {
      throw Exception("Departamento con ID $id no encontrado");
    }

    throw Exception("Error al obtener departamento: ${resp.statusCode}");
  }

  // POST /departamentos/
  Future<void> createDepartamento(Map<String, dynamic> departamento) async {
    final resp = await http.post("/departamento_eco/", departamento);

    if (![200, 201, 204].contains(resp.statusCode)) {
      throw Exception("Error al crear departamento: ${resp.statusCode}");
    }
  }

  // PUT /departamentos/{id}
  Future<void> updateDepartamento(int id, Map<String, dynamic> departamento) async {
    final resp = await http.put("/$id", departamento);

    if (![200, 204].contains(resp.statusCode)) {
      throw Exception("Error al actualizar departamento: ${resp.statusCode}");
    }
  }

  // DELETE /departamentos/{id}
  Future<void> deleteDepartamento(int id) async {
    final resp = await http.delete("/departamento_eco/$id");

    if (![200, 204].contains(resp.statusCode)) {
      throw Exception("Error al eliminar departamento: ${resp.statusCode}");
    }
  }
}
