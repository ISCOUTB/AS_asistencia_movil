import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // GET asistencias por email del estudiante
  Future<List<Map<String, dynamic>>> getAsistenciasPorEstudiante(String email) async {
    debugPrint('📤 Obteniendo asistencias para estudiante: $email');
    
    try {
      // Obtener todas las asistencias
      final response = await http.get(Uri.parse(baseUrl), headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> todasAsistencias = [];
        
        if (data is Map && data.containsKey('items')) {
          todasAsistencias = data['items'] as List<dynamic>;
        } else if (data is List) {
          todasAsistencias = data;
        }
        
        debugPrint('📥 Total asistencias: ${todasAsistencias.length}');
        
        // Filtrar por email del estudiante
        final asistenciasEstudiante = todasAsistencias
            .where((a) => a['email_persona'] == email)
            .toList();
        
        debugPrint('✅ Asistencias del estudiante: ${asistenciasEstudiante.length}');
        
        // Para cada asistencia, obtener información de la sesión
        final sesionesUrl = baseUrl.replaceAll('asistencia_sesiones/', 'sesiones/');
        final List<Map<String, dynamic>> resultado = [];
        
        for (var asistencia in asistenciasEstudiante) {
          final idSesion = asistencia['id_sesiones'];
          
          try {
            // Obtener detalles de la sesión
            final sesionResponse = await http.get(
              Uri.parse('$sesionesUrl$idSesion'),
              headers: headers,
            );
            
            if (sesionResponse.statusCode == 200) {
              final sesionData = jsonDecode(sesionResponse.body);
              
              resultado.add({
                'id_asistencia': asistencia['id'],
                'id_sesion': idSesion,
                'nombre_sesion': sesionData['nombre_sesion'] ?? 'Sesión',
                'fecha_sesion': sesionData['fecha_sesion'] ?? '',
                'hora_inicio': sesionData['hora_inicio_sesion'] ?? '',
                'lugar': sesionData['lugar_sesion'] ?? '',
                'fecha_hora_asistencia': asistencia['fecha_hora_asistencia'] ?? '',
                'estado': asistencia['estado_asistencia'] ?? 'Presente', // Obtener estado real del backend
              });
            }
          } catch (e) {
            debugPrint('⚠️ Error obteniendo sesión $idSesion: $e');
          }
        }
        
        return resultado;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error al obtener asistencias: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      return [];
    }
  }

  // POST /asistencia_sesion/
  Future<Map<String, dynamic>> createAsistencia(Map<String, dynamic> asistencia) async {
    debugPrint('📤 Registrando asistencia:');
    debugPrint(jsonEncode(asistencia));
    
    // No requerir cookies para registro de asistencia
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode(asistencia),
    );

    debugPrint('📥 Respuesta: ${response.statusCode}');
    debugPrint('📄 Body: ${response.body}');

    if ([200, 201, 204].contains(response.statusCode)) {
      // Intentar decodificar la respuesta si hay body
      if (response.body.isNotEmpty) {
        try {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          return {'success': true, 'message': 'Asistencia registrada'};
        }
      }
      return {'success': true, 'message': 'Asistencia registrada'};
    } else {
      // Intentar obtener mensaje de error del servidor
      String errorMsg = 'Error al crear asistencia: ${response.statusCode}';
      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody is Map && errorBody.containsKey('message')) {
          errorMsg = errorBody['message'];
        }
      } catch (e) {
        // Usar mensaje genérico
      }
      throw Exception(errorMsg);
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
    debugPrint('🗑️ Eliminando asistencia $id');
    
    final deleteHeaders = {
      ...headers,
      'Content-Type': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    };
    
    // Intentar con POST _method=DELETE primero
    var response = await http.post(
      Uri.parse('$baseUrl$id'),
      headers: deleteHeaders,
      body: jsonEncode({'_method': 'DELETE'}),
    );
    
    debugPrint('📥 POST/_method DELETE: ${response.statusCode}');
    
    // Si no funciona, intentar DELETE estándar
    if (response.statusCode >= 400) {
      response = await http.delete(
        Uri.parse('$baseUrl$id'),
        headers: deleteHeaders,
        body: jsonEncode({}),
      );
      debugPrint('📥 DELETE estándar: ${response.statusCode}');
    }

    if (![200, 204].contains(response.statusCode)) {
      debugPrint('❌ Error body: ${response.body}');
      throw Exception('Error al eliminar asistencia: ${response.statusCode}');
    }
    
    debugPrint('✅ Asistencia $id eliminada correctamente');
  }

  // DELETE asistencias por sesión (eliminar en cascada)
  Future<int> deleteAsistenciasPorSesion(int idSesion) async {
    debugPrint('🗑️ Eliminando asistencias de la sesión $idSesion');
    
    try {
      // Obtener todas las asistencias
      final response = await http.get(Uri.parse(baseUrl), headers: headers);
      
      if (response.statusCode != 200) {
        debugPrint('⚠️ No se pudieron obtener asistencias: ${response.statusCode}');
        return 0;
      }

      final data = jsonDecode(response.body);
      List<dynamic> todasAsistencias = [];
      
      if (data is Map && data.containsKey('items')) {
        todasAsistencias = data['items'] as List<dynamic>;
      } else if (data is List) {
        todasAsistencias = data;
      }

      // Filtrar por id_sesiones
      final asistenciasSesion = todasAsistencias
          .where((a) => a['id_sesiones'] == idSesion)
          .toList();

      debugPrint('📋 Encontradas ${asistenciasSesion.length} asistencias para eliminar');

      // Eliminar cada asistencia
      int eliminadas = 0;
      for (var asistencia in asistenciasSesion) {
        try {
          await deleteAsistencia(asistencia['id']);
          eliminadas++;
          debugPrint('✅ Asistencia ${asistencia['id']} eliminada');
        } catch (e) {
          debugPrint('❌ Error eliminando asistencia ${asistencia['id']}: $e');
        }
      }

      debugPrint('✅ Total asistencias eliminadas: $eliminadas/${asistenciasSesion.length}');
      return eliminadas;
      
    } catch (e) {
      debugPrint('❌ Error en deleteAsistenciasPorSesion: $e');
      return 0;
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
      
      // SOLUCIÓN TEMPORAL: Recuperar códigos guardados localmente
      final prefs = await SharedPreferences.getInstance();
      final codigosGuardados = prefs.getString('codigos_acceso') ?? '{}';
      final Map<String, dynamic> codigosLocales = jsonDecode(codigosGuardados);
      
      // Crear lista de sesiones con sus estudiantes
      return sesiones.map<Map<String, dynamic>>((sesion) {
        final idSesion = sesion['id'] as int;
        // Intentar obtener código del backend, si no existe usar el guardado localmente
        final codigoBackend = sesion['codigo_acceso'];
        final codigoLocal = codigosLocales[idSesion.toString()];
        final codigoFinal = codigoBackend ?? codigoLocal ?? 'N/A';
        
        return {
          'id': idSesion,
          'nombreSesion': sesion['nombre_sesion'] ?? 'Sesión $idSesion',
          'servicio': 'Servicio ${sesion['id_servicio']}', // Necesitaríamos otro endpoint para el nombre
          'fecha': sesion['fecha']?.toString().substring(0, 10) ?? '',
          'horaInicio': sesion['hora_inicio_sesion'] ?? '',
          'horaFin': sesion['hora_fin']?.toString().substring(11, 16) ?? '',
          'lugar': sesion['lugar_sesion'] ?? '',
          'codigo_acceso': codigoFinal, // Campo del código QR (backend o local)
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
