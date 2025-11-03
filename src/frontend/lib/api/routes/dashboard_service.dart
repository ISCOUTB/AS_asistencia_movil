import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardService {
  final String baseUrl;
  final Map<String, String> headers = {
    'Accept': 'application/json',
    'User-Agent': 'Flutter-Client',
  };

  DashboardService(this.baseUrl);

  // Obtener estadísticas generales del dashboard
  Future<Map<String, dynamic>> getEstadisticas() async {
    try {
      print('DashboardService: Obteniendo sesiones...');
      // Obtener sesiones con timeout
      final sesionesUrl = '${baseUrl}sesiones/';
      final sesionesResponse = await http.get(
        Uri.parse(sesionesUrl), 
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      List<dynamic> sesiones = [];
      if (sesionesResponse.statusCode == 200) {
        final data = jsonDecode(sesionesResponse.body);
        if (data is Map && data.containsKey('items')) {
          sesiones = data['items'] as List<dynamic>;
        } else if (data is List) {
          sesiones = data;
        }
      }
      print('DashboardService: ${sesiones.length} sesiones encontradas');
      
      // Obtener asistencias con timeout
      print('DashboardService: Obteniendo asistencias...');
      final asistenciasUrl = '${baseUrl}asistencia_sesiones/';
      final asistenciasResponse = await http.get(
        Uri.parse(asistenciasUrl), 
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      List<dynamic> asistencias = [];
      if (asistenciasResponse.statusCode == 200) {
        final data = jsonDecode(asistenciasResponse.body);
        if (data is Map && data.containsKey('items')) {
          asistencias = data['items'] as List<dynamic>;
        } else if (data is List) {
          asistencias = data;
        }
      }
      print('DashboardService: ${asistencias.length} asistencias encontradas');
      
      // Filtrar sesiones de hoy con manejo seguro de fechas
      final hoy = DateTime.now();
      int sesionesHoy = 0;
      try {
        sesionesHoy = sesiones.where((sesion) {
          try {
            if (sesion['fecha'] != null) {
              final fechaStr = sesion['fecha'].toString();
              final fecha = DateTime.parse(fechaStr);
              return fecha.year == hoy.year && 
                     fecha.month == hoy.month && 
                     fecha.day == hoy.day;
            }
          } catch (e) {
            print('Error parseando fecha de sesión: $e');
          }
          return false;
        }).length;
      } catch (e) {
        print('Error filtrando sesiones de hoy: $e');
      }
      
      // Contar asistencias de esta semana con manejo seguro
      int asistenciasSemana = 0;
      try {
        final inicioSemana = hoy.subtract(Duration(days: hoy.weekday - 1));
        asistenciasSemana = asistencias.where((asistencia) {
          try {
            if (asistencia['fecha_creacion'] != null) {
              final fechaStr = asistencia['fecha_creacion'].toString();
              final fecha = DateTime.parse(fechaStr);
              return fecha.isAfter(inicioSemana);
            }
          } catch (e) {
            print('Error parseando fecha de asistencia: $e');
          }
          return false;
        }).length;
      } catch (e) {
        print('Error filtrando asistencias de semana: $e');
      }
      
      final resultado = {
        'totalSesiones': sesiones.length,
        'sesionesHoy': sesionesHoy,
        'totalAsistencias': asistencias.length,
        'asistenciasSemana': asistenciasSemana,
        'sesiones': sesiones,
        'asistencias': asistencias,
      };
      
      print('DashboardService: Estadísticas calculadas exitosamente');
      return resultado;
    } catch (e) {
      print('DashboardService ERROR en getEstadisticas: $e');
      return {
        'totalSesiones': 0,
        'sesionesHoy': 0,
        'totalAsistencias': 0,
        'asistenciasSemana': 0,
        'sesiones': [],
        'asistencias': [],
      };
    }
  }

  // Obtener datos para gráfico de tendencias
  Future<Map<String, int>> getTendenciaAsistencias(String rango) async {
    try {
      print('DashboardService: Obteniendo tendencia para rango: $rango');
      final asistenciasUrl = '${baseUrl}asistencia_sesiones/';
      final response = await http.get(
        Uri.parse(asistenciasUrl), 
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        print('DashboardService: Error HTTP ${response.statusCode} al obtener tendencia');
        return {};
      }
      
      final data = jsonDecode(response.body);
      List<dynamic> asistencias = [];
      if (data is Map && data.containsKey('items')) {
        asistencias = data['items'] as List<dynamic>;
      } else if (data is List) {
        asistencias = data;
      }
      
      final ahora = DateTime.now();
      int dias = rango == 'today' ? 1 : (rango == '7d' ? 7 : 30);
      
      Map<String, int> tendencia = {};
      
      for (int i = 0; i < dias; i++) {
        final fecha = ahora.subtract(Duration(days: dias - 1 - i));
        final key = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
        
        int count = 0;
        try {
          count = asistencias.where((asistencia) {
            try {
              if (asistencia['fecha_creacion'] != null) {
                final fechaAsistencia = DateTime.parse(asistencia['fecha_creacion'].toString());
                return fechaAsistencia.year == fecha.year &&
                       fechaAsistencia.month == fecha.month &&
                       fechaAsistencia.day == fecha.day;
              }
            } catch (e) {
              print('Error parseando fecha en tendencia: $e');
            }
            return false;
          }).length;
        } catch (e) {
          print('Error contando asistencias para fecha $key: $e');
        }
        
        tendencia[key] = count;
      }
      
      print('DashboardService: Tendencia calculada - ${tendencia.length} días');
      return tendencia;
    } catch (e) {
      print('DashboardService ERROR en getTendenciaAsistencias: $e');
      return {};
    }
  }
}
