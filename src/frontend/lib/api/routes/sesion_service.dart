import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SesionService {
  final String baseUrl;
  final Map<String, String> headers = {
    'Accept': 'application/json',
    'User-Agent': 'Flutter-Client',
  };

  // Simula las cookies de sesión
  Map<String, String> cookies = {};

  SesionService(this.baseUrl);

  // Asegura que haya cookies antes de hacer peticiones (opcional)
  Future<void> _ensureCookies() async {
    if (cookies.isEmpty) {
      try {
        final response = await http.get(Uri.parse(baseUrl), headers: headers);
        if (response.statusCode == 200) {
          _updateCookies(response);
        }
      } catch (e) {
        // Las cookies son opcionales, continuar sin ellas
        debugPrint('⚠️ No se pudieron obtener cookies (continuando sin ellas): $e');
      }
    }
  }

  // Actualiza cookies
  void _updateCookies(http.Response response) {
    final rawCookies = response.headers['set-cookie'];
    if (rawCookies != null) {
      final cookie = rawCookies.split(';')[0];
      cookies['cookie'] = cookie;
      headers['cookie'] = cookie;
    }
  }

  // GET /sesion/
  Future<List<dynamic>> getSesiones() async {
    await _ensureCookies();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // EXTRAER LA LISTA REAL
      return decoded["items"] as List;
    } else {
      throw Exception('Error al obtener sesiones: ${response.statusCode}');
    }
  }

  // GET /sesion/{id}
  Future<Map<String, dynamic>> getSesion(int id) async {
    await _ensureCookies();
    final response = await http.get(Uri.parse('$baseUrl$id'), headers: headers);

    if (response.statusCode == 200 || response.statusCode == 204) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Sesión con ID $id no encontrada');
    } else {
      throw Exception('Error al obtener sesión: ${response.statusCode}');
    }
  }

  // GET /sesion/servicio/{id_servicio}
  Future<List<dynamic>> getSesionesPorServicio(int idServicio) async {
    await _ensureCookies();
    final query = jsonEncode({'id_servicio': idServicio});
    final url = Uri.parse('$baseUrl?q=$query');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('No se encontraron sesiones para el servicio $idServicio');
    } else {
      throw Exception('Error al obtener sesiones: ${response.statusCode}');
    }
  }

    // GET /sesion/servicio/{id_facilitador}
  // Nota: id_faciltiador en la BD es el correo electrónico, no un ID numérico
  Future<List<dynamic>> getSesionesPorFacilitador(String emailFacilitador) async {
    await _ensureCookies();
    final query = jsonEncode({'id_faciltiador': emailFacilitador});
    final url = Uri.parse('$baseUrl?q=$query');

    print('🔍 Buscando sesiones del facilitador: $emailFacilitador');
    print('🌐 URL: $url');

    final response = await http.get(url, headers: headers);

    print('📥 Respuesta: ${response.statusCode}');
    print('📄 Body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final items = decoded["items"] as List;
      print('✅ Sesiones encontradas: ${items.length}');
      return items;
    } else {
      // Mostrar el error detallado del servidor
      String errorMsg = 'Error al obtener sesiones: ${response.statusCode}';
      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody is Map && errorBody.containsKey('message')) {
          errorMsg = 'Error del servidor: ${errorBody['message']}';
        }
      } catch (e) {
        // Si no se puede decodificar, usar el mensaje genérico
      }
      throw Exception(errorMsg);
    }
  }

  // Validar código de acceso y obtener información de la sesión
  Future<Map<String, dynamic>?> validarCodigoAcceso(String codigo) async {
    debugPrint('🔍 Validando código de acceso: $codigo');
    
    try {
      // 1. Obtener todas las sesiones del backend
      await _ensureCookies();
      final response = await http.get(Uri.parse(baseUrl), headers: headers);
      
      if (response.statusCode != 200) {
        debugPrint('❌ Error al obtener sesiones: ${response.statusCode}');
        return null;
      }

      final decoded = jsonDecode(response.body);
      List<dynamic> sesiones = [];
      
      if (decoded is Map && decoded.containsKey('items')) {
        sesiones = decoded['items'] as List<dynamic>;
      } else if (decoded is List) {
        sesiones = decoded;
      }

      debugPrint('📋 Total sesiones en el backend: ${sesiones.length}');

      // 2. Buscar sesión por código de acceso o por ID
      for (var sesion in sesiones) {
        // Comparar código de acceso si existe en el backend
        if (sesion['codigo_acceso']?.toString() == codigo) {
          debugPrint('✅ Sesión encontrada por codigo_acceso: ${sesion['nombre_sesion']}');
          return sesion as Map<String, dynamic>;
        }
        
        // También comparar por ID (el código puede ser el ID de la sesión)
        if (sesion['id']?.toString() == codigo) {
          debugPrint('✅ Sesión encontrada por ID: ${sesion['nombre_sesion']}');
          sesion['codigo_acceso'] = codigo;
          return sesion as Map<String, dynamic>;
        }
      }

      debugPrint('❌ No se encontró ninguna sesión con código: $codigo');
      return null;
      
    } catch (e) {
      debugPrint('❌ Error al validar código: $e');
      return null;
    }
  }

  // GET sesiones activas (para estudiantes)
  Future<List<Map<String, dynamic>>> getSesionesActivas() async {
    debugPrint('📤 Obteniendo sesiones activas');
    
    try {
      await _ensureCookies();
      final response = await http.get(Uri.parse(baseUrl), headers: headers);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> sesiones = [];
        
        if (decoded is Map && decoded.containsKey('items')) {
          sesiones = decoded['items'] as List<dynamic>;
        } else if (decoded is List) {
          sesiones = decoded;
        }

        debugPrint('📥 Total sesiones: ${sesiones.length}');

        // Obtener códigos guardados localmente
        final prefs = await SharedPreferences.getInstance();
        final codigosGuardados = prefs.getString('codigos_acceso') ?? '{}';
        final Map<String, dynamic> codigosLocales = jsonDecode(codigosGuardados);

        // Mapear sesiones con códigos
        final List<Map<String, dynamic>> resultado = sesiones.map((s) {
          final id = s['id'];
          final codigoBackend = s['codigo_acceso'];
          final codigoLocal = codigosLocales[id.toString()];
          
          return {
            'id': id,
            'nombre_sesion': s['nombre_sesion'] ?? 'Sesión',
            'fecha_sesion': s['fecha_sesion'] ?? '',
            'hora_inicio_sesion': s['hora_inicio_sesion'] ?? '',
            'hora_fin': s['hora_fin'] ?? '',
            'lugar_sesion': s['lugar_sesion'] ?? '',
            'id_servicio': s['id_servicio'],
            'id_faciltiador': s['id_faciltiador'],
            'codigo_acceso': codigoBackend ?? codigoLocal ?? 'N/A',
          };
        }).toList();

        debugPrint('✅ Sesiones activas: ${resultado.length}');
        return resultado;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error al obtener sesiones: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      return [];
    }
  }

  // POST /sesion/
  Future<Map<String, dynamic>?> createSesion(Map<String, dynamic> sesion) async {
    await _ensureCookies();
    
    // Debug: Mostrar lo que se está enviando
    print('📤 Enviando sesión al backend:');
    print(jsonEncode(sesion));
    
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode(sesion),
    );

    print('📥 Respuesta del servidor: ${response.statusCode}');
    print('📄 Body de respuesta: ${response.body}');

    if (![200, 201, 204].contains(response.statusCode)) {
      // Intentar decodificar el mensaje de error del backend
      String errorMessage = 'Error al crear sesión: ${response.statusCode}';
      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody is Map && errorBody.containsKey('message')) {
          errorMessage = 'Error del servidor: ${errorBody['message']}';
        } else if (errorBody is Map && errorBody.containsKey('error')) {
          errorMessage = 'Error del servidor: ${errorBody['error']}';
        } else {
          errorMessage = 'Error del servidor: ${response.body}';
        }
      } catch (e) {
        errorMessage = 'Error ${response.statusCode}: ${response.body}';
      }
      throw Exception(errorMessage);
    }
    
    // Devolver la sesión creada si el backend la retorna
    if (response.body.isNotEmpty) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // PUT /sesion/{id}
  Future<void> updateSesion(int id, Map<String, dynamic> sesion) async {
    await _ensureCookies();
    final response = await http.put(
      Uri.parse('$baseUrl$id'),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode(sesion),
    );

    if (![200, 204].contains(response.statusCode)) {
      throw Exception('Error al actualizar sesión: ${response.statusCode}');
    }
  }

  // DELETE /sesiones/{id}
  Future<void> deleteSesion(int id) async {
    await _ensureCookies();
    
    // Agregar headers adicionales para DELETE con autenticación básica
    final deleteHeaders = {
      ...headers,
      'Content-Type': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      // Oracle ORDS puede requerir autenticación básica
      'Authorization': 'Basic ${base64Encode(utf8.encode('ecoutb_workspace:'))}',
    };
    
    debugPrint('🗑️ Intentando eliminar sesión $id');
    debugPrint('URL: $baseUrl$id');
    
    try {
      // Intentar primero con POST _method=DELETE (alternativa para ORDS)
      debugPrint('🔄 Método 1: Intentando con POST y _method=DELETE');
      var response = await http.post(
        Uri.parse('$baseUrl$id'),
        headers: deleteHeaders,
        body: jsonEncode({'_method': 'DELETE'}),
      );
      
      debugPrint('📥 Respuesta POST/_method: ${response.statusCode}');
      
      // Si POST no funciona, intentar con DELETE estándar
      if (response.statusCode == 302 || response.statusCode >= 400) {
        debugPrint('🔄 Método 2: Intentando con DELETE estándar');
        response = await http.delete(
          Uri.parse('$baseUrl$id'),
          headers: deleteHeaders,
          body: jsonEncode({}),
        );
        debugPrint('📥 Respuesta DELETE: ${response.statusCode}');
      }
      
      debugPrint('Body: ${response.body}');

      // Manejar códigos de éxito
      if ([200, 204].contains(response.statusCode)) {
        debugPrint('✅ Sesión eliminada exitosamente (código ${response.statusCode})');
        return;
      }
      
      // Si es 302, verificar si realmente se eliminó
      if ([301, 302, 303, 307, 308].contains(response.statusCode)) {
        debugPrint('⚠️ Redirección detectada (${response.statusCode}), verificando eliminación...');
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        try {
          final checkResponse = await http.get(
            Uri.parse('$baseUrl$id'),
            headers: headers,
          );
          
          debugPrint('📥 Verificación GET: ${checkResponse.statusCode}');
          
          if (checkResponse.statusCode == 404) {
            debugPrint('✅ Sesión eliminada exitosamente (verificado con 404)');
            return;
          }
          
          if (checkResponse.statusCode == 200) {
            throw Exception('La sesión no fue eliminada (aún existe en el servidor). Puede que necesites permisos especiales para eliminar sesiones.');
          }
        } catch (e) {
          if (e.toString().contains('404')) {
            debugPrint('✅ Sesión eliminada exitosamente (404 en verificación)');
            return;
          }
          debugPrint('⚠️ Error al verificar: $e');
          throw Exception('No se pudo verificar si la sesión fue eliminada. Error: $e');
        }
      }
      
      // Mejorar mensaje de error para 400
      if (response.statusCode == 400) {
        final errorBody = response.body;
        
        // Detectar error de integridad referencial (asistencias existentes)
        if (errorBody.contains('ORA-02292') || errorBody.contains('child record found')) {
          throw Exception('No se puede eliminar: esta sesión tiene asistencias registradas. Elimina primero las asistencias o usa la opción de eliminar en cascada.');
        }
        
        throw Exception('Error de validación del servidor (400). Detalles: $errorBody');
      }
      
      // Error 403 = sin permisos
      if (response.statusCode == 403) {
        throw Exception('No tienes permisos para eliminar esta sesión. Verifica que seas el facilitador de esta sesión.');
      }
      
      throw Exception('Error al eliminar sesión: ${response.statusCode}');
      
    } catch (e) {
      debugPrint('❌ Error en deleteSesion: $e');
      rethrow;
    }
  }
}
