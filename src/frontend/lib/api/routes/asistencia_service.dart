import 'dart:convert';
import 'package:http/http.dart' as http;

class AsistenciaService {
  final String baseUrl;
  final Map<String, String> headers = {
    'Accept': 'application/json',
    'User-Agent': 'Flutter-Client',
  };

  AsistenciaService(this.baseUrl);

  // GET /asistencia_sesion/
  Future<List<dynamic>> getAsistencias() async {
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
    } else if (response.statusCode == 404) {
      // Si no hay asistencias, devolver lista vacía
      return [];
    } else {
      throw Exception('Error al obtener asistencias: ${response.statusCode}');
    }
  }

  // GET /asistencia_sesion/sesion/{id_sesion}
  Future<List<dynamic>> getAsistenciasPorSesion(int idSesion) async {
    final query = jsonEncode({'id_sesion': idSesion});
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
      return []; // No hay asistencias para esta sesión
    } else {
      throw Exception('Error al obtener asistencias: ${response.statusCode}');
    }
  }

  // POST /asistencia_sesion/
  Future<void> createAsistencia(Map<String, dynamic> asistencia) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode(asistencia),
    );

    if (![200, 201, 204].contains(response.statusCode)) {
      throw Exception('Error al crear asistencia: ${response.statusCode}');
    }
  }

  // PUT /asistencia_sesion/{id}
  Future<void> updateAsistencia(int id, Map<String, dynamic> asistencia) async {
    final response = await http.put(
      Uri.parse('$baseUrl$id'),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode(asistencia),
    );

    if (![200, 204].contains(response.statusCode)) {
      throw Exception('Error al actualizar asistencia: ${response.statusCode}');
    }
  }

  // DELETE /asistencia_sesion/{id}
  Future<void> deleteAsistencia(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$id'),
      headers: headers,
    );

    if (![200, 204].contains(response.statusCode)) {
      throw Exception('Error al eliminar asistencia: ${response.statusCode}');
    }
  }

  // Método auxiliar para obtener sesiones con sus asistencias agrupadas
  Future<List<Map<String, dynamic>>> getSesionesConAsistencias() async {
    try {
      // Obtener todas las sesiones primero
      final sesionesUrl = baseUrl.replaceAll('asistencia_sesiones/', 'sesiones/');
      final sesionesResponse = await http.get(Uri.parse(sesionesUrl), headers: headers);
      
      List<dynamic> sesiones = [];
      if (sesionesResponse.statusCode == 200) {
        final sesionesData = jsonDecode(sesionesResponse.body);
        if (sesionesData is Map && sesionesData.containsKey('items')) {
          sesiones = sesionesData['items'] as List<dynamic>;
        } else if (sesionesData is List) {
          sesiones = sesionesData;
        }
      }
      
      // Si no hay sesiones, devolver lista vacía
      if (sesiones.isEmpty) {
        return [];
      }
      
      // Obtener todas las asistencias
      final asistencias = await getAsistencias();
      
      // Agrupar asistencias por sesión
      Map<int, List<dynamic>> asistenciasPorSesion = {};
      for (var asistencia in asistencias) {
        final idSesion = asistencia['id_sesiones'] as int; // Nota: el campo es 'id_sesiones'
        if (!asistenciasPorSesion.containsKey(idSesion)) {
          asistenciasPorSesion[idSesion] = [];
        }
        
        // Necesitamos obtener el nombre de la persona desde el endpoint de personas
        asistenciasPorSesion[idSesion]!.add({
          'id': asistencia['id'] ?? 0,
          'id_persona': asistencia['id_persona'] ?? 0,
          'documento': asistencia['documento_identidad'] ?? '',
          'observaciones': asistencia['observaciones'] ?? '',
          'nombre': 'Estudiante ${asistencia['id_persona']}', // Por ahora usamos el ID
          'email': '', // No está en la tabla de asistencias
          'estado': 'Presente', // Por defecto, ya que si está registrado, asistió
        });
      }
      
      // Crear lista de sesiones con sus estudiantes
      return sesiones.map<Map<String, dynamic>>((sesion) {
        final idSesion = sesion['id'] as int;
        return {
          'id': idSesion,
          'nombreSesion': sesion['nombre_sesion'] ?? 'Sesión $idSesion',
          'servicio': 'Servicio ${sesion['id_servicio']}', // Necesitaríamos otro endpoint para el nombre
          'fecha': sesion['fecha']?.toString().substring(0, 10) ?? '',
          'horaInicio': sesion['hora_inicio_sesion'] ?? '',
          'horaFin': sesion['hora_fin']?.toString().substring(11, 16) ?? '',
          'lugar': sesion['lugar_sesion'] ?? '',
          'estudiantes': asistenciasPorSesion[idSesion] ?? [],
        };
      }).toList();
    } catch (e) {
      // Si hay error, devolver lista vacía en lugar de lanzar excepción
      print('Info: No se encontraron sesiones/asistencias en el backend: $e');
      return [];
    }
  }
}
