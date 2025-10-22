import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
  
  
  // Obtener información de una persona por email
  static Future<Map<String, dynamic>?> getPersonaByEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personas/email/$email'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error al obtener persona: $e');
      return null;
    }
  }
  
  // Obtener información de un facilitador
  static Future<Map<String, dynamic>?> getFacilitadorByPersonaId(int personaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/facilitadores/persona/$personaId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error al obtener facilitador: $e');
      return null;
    }
  }
  
  // Obtener departamento por ID
  static Future<Map<String, dynamic>?> getDepartamento(int departamentoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/departamentos/$departamentoId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error al obtener departamento: $e');
      return null;
    }
  }
  
  // Obtener sesiones de un estudiante
  static Future<List<dynamic>> getSesionesEstudiante(int personaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sesiones/estudiante/$personaId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error al obtener sesiones: $e');
      return [];
    }
  }
  
  // Obtener asistencias de un estudiante
  static Future<List<dynamic>> getAsistenciasEstudiante(int personaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/asistencias/estudiante/$personaId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error al obtener asistencias: $e');
      return [];
    }
  }
}
