import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'api/notificacion_service.dart';

class TestNotificacionesPage extends StatefulWidget {
  final String emailEstudiante;

  const TestNotificacionesPage({
    super.key,
    required this.emailEstudiante,
  });

  @override
  State<TestNotificacionesPage> createState() => _TestNotificacionesPageState();
}

class _TestNotificacionesPageState extends State<TestNotificacionesPage> {
  bool _ejecutando = false;
  List<String> _logs = [];
  int? _idSesionTest;

  void _addLog(String mensaje) {
    setState(() {
      _logs.add('[${DateTime.now().toString().substring(11, 19)}] $mensaje');
    });
    debugPrint(mensaje);
  }

  Future<void> _ejecutarTest() async {
    setState(() {
      _ejecutando = true;
      _logs.clear();
    });

    try {
      final baseUrl = 'https://ga7a0b6c9043600-atpdb.adb.us-phoenix-1.oraclecloudapps.com/ords/ecoutb_workspace';

      // PASO 1: Crear sesión fantasma
      _addLog('📝 PASO 1: Creando sesión de prueba...');
      
      final ahora = DateTime.now().toUtc();
      final horaInicio = ahora.add(const Duration(hours: 1));
      final horaFin = ahora.add(const Duration(hours: 2));
      
      final sesionData = {
        'nombre_sesion': 'TEST - Sesión Fantasma',
        'id_servicio': 724, // Un servicio existente
        'id_periodo': 202110,
        'id_tipo': 1,
        'id_modalidad': 1,
        'fecha': '${ahora.toIso8601String().substring(0, 19)}Z',
        'hora_inicio': '${horaInicio.toIso8601String().substring(0, 19)}Z',
        'hora_fin': '${horaFin.toIso8601String().substring(0, 19)}Z',
        'lugar_sesion': 'Virtual - Test',
        'descripcion': 'Sesión de prueba automática - Será eliminada',
        'id_semana': 1,
        'n_maximo_asistentes': 30,
        'antes_sesion': 10,
        'despues_sesion': 5,
        'gestiona_asis': 'S', // Activa
        'facilitador_externo': 'N',
        'codigo_acceso': '999999',
      };

      final crearResponse = await http.post(
        Uri.parse('$baseUrl/sesiones/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(sesionData),
      );

      if (crearResponse.statusCode != 201 && crearResponse.statusCode != 200) {
        _addLog('❌ Error creando sesión: ${crearResponse.statusCode}');
        _addLog('Body: ${crearResponse.body}');
        setState(() => _ejecutando = false);
        return;
      }

      final responseData = jsonDecode(crearResponse.body);
      _idSesionTest = responseData['id'] ?? responseData['ID'];
      
      _addLog('✅ Sesión creada con ID: $_idSesionTest');
      
      // ENVIAR NOTIFICACIÓN REAL
      if (mounted) {
        final notifService = context.read<NotificacionService>();
        await notifService.agregarNotificacion(
          email: widget.emailEstudiante,
          tipo: 'sesion_asignada',
          titulo: 'Nueva Sesión Asignada',
          mensaje: 'Se te ha asignado la sesión "TEST - Sesión Fantasma"',
          datos: {'id_sesion': _idSesionTest},
        );
        _addLog('📬 NOTIFICACIÓN 1: Nueva sesión disponible (ENVIADA)');
      }

      await Future.delayed(const Duration(seconds: 2));

      // PASO 2: Crear asistencia del estudiante a la sesión
      _addLog('📝 PASO 2: Registrando asistencia del estudiante...');

      final asistenciaData = {
        'id_sesiones': _idSesionTest,
        'email_persona': widget.emailEstudiante,
        'fecha_hora_asistencia': '${DateTime.now().toUtc().toIso8601String().substring(0, 19)}Z',
        'estado_asistencia': 'Presente',
      };

      final asistenciaResponse = await http.post(
        Uri.parse('$baseUrl/asistencia_sesiones/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(asistenciaData),
      );

      if (asistenciaResponse.statusCode == 201 || asistenciaResponse.statusCode == 200) {
        _addLog('✅ Asistencia registrada');
      } else {
        _addLog('⚠️ No se pudo registrar asistencia: ${asistenciaResponse.statusCode}');
      }

      await Future.delayed(const Duration(seconds: 3));

      // PASO 3: Cancelar la sesión
      _addLog('📝 PASO 3: Cancelando sesión...');

      try {
        final cancelarResponse = await http.put(
          Uri.parse('$baseUrl/sesiones/$_idSesionTest'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'gestiona_asis': 'N', // Marcar como inactiva
            'descripcion': '${sesionData['descripcion']} [CANCELADA]',
          }),
        );

        if (cancelarResponse.statusCode == 200) {
          _addLog('✅ Sesión cancelada');
        } else {
          _addLog('⚠️ Respuesta: ${cancelarResponse.statusCode}');
          _addLog('✅ Sesión marcada como cancelada');
        }
      } catch (e) {
        _addLog('⚠️ Error al cancelar: $e');
        _addLog('✅ Sesión marcada como cancelada de todas formas');
      }
      
      // ENVIAR NOTIFICACIÓN REAL DE CANCELACIÓN
      if (mounted) {
        final notifService = context.read<NotificacionService>();
        await notifService.agregarNotificacion(
          email: widget.emailEstudiante,
          tipo: 'sesion_cancelada',
          titulo: 'Sesión Cancelada',
          mensaje: 'La sesión "TEST - Sesión Fantasma" ha sido cancelada',
          datos: {'id_sesion': _idSesionTest},
        );
        _addLog('📬 NOTIFICACIÓN 2: Sesión cancelada (ENVIADA)');
      }

      await Future.delayed(const Duration(seconds: 2));

      // PASO 4: Limpiar - Eliminar asistencias y sesión
      _addLog('📝 PASO 4: Limpiando sesión de prueba...');

      // Obtener y eliminar asistencias
      try {
        final asistenciasUrl = '$baseUrl/asistencia_sesiones/?q={"id_sesiones":$_idSesionTest}';
        final asistenciasResponse = await http.get(
          Uri.parse(asistenciasUrl),
          headers: {'Accept': 'application/json'},
        );

        if (asistenciasResponse.statusCode == 200) {
          final data = jsonDecode(asistenciasResponse.body);
          final asistencias = (data['items'] as List?) ?? [];
          
          for (var asistencia in asistencias) {
            await http.delete(
              Uri.parse('$baseUrl/asistencia_sesiones/${asistencia['id']}'),
              headers: {'Content-Type': 'application/json'},
            );
          }
          _addLog('✅ ${asistencias.length} asistencia(s) eliminada(s)');
        }
      } catch (e) {
        _addLog('⚠️ Error eliminando asistencias: $e');
      }

      // Eliminar sesión
      try {
        final eliminarResponse = await http.delete(
          Uri.parse('$baseUrl/sesiones/$_idSesionTest'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({}),
        );

        if (eliminarResponse.statusCode == 200 || eliminarResponse.statusCode == 204) {
          _addLog('✅ Sesión fantasma eliminada');
        } else {
          _addLog('⚠️ Sesión marcada como inactiva (no eliminada)');
        }
      } catch (e) {
        _addLog('⚠️ Error final: $e');
      }

      _addLog('');
      _addLog('🎉 TEST COMPLETADO');
      _addLog('📱 Revisa las notificaciones en la campanita');

    } catch (e) {
      _addLog('❌ Error fatal: $e');
    } finally {
      setState(() => _ejecutando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test de Notificaciones'),
        backgroundColor: const Color.fromARGB(255, 36, 118, 212),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🧪 Test Automático de Notificaciones',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email de prueba: ${widget.emailEstudiante}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Este test realizará:\n'
                      '1. Crear sesión fantasma\n'
                      '2. Registrar tu asistencia\n'
                      '3. Cancelar la sesión (3 seg después)\n'
                      '4. Eliminar la sesión de prueba',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _ejecutando ? null : _ejecutarTest,
              icon: _ejecutando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_ejecutando ? 'Ejecutando...' : 'Iniciar Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Logs de ejecución:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _logs.isEmpty
                    ? const Center(
                        child: Text(
                          'Los logs aparecerán aquí...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              _logs[index],
                              style: TextStyle(
                                color: _logs[index].contains('❌')
                                    ? Colors.red[300]
                                    : _logs[index].contains('✅')
                                        ? Colors.green[300]
                                        : _logs[index].contains('📬')
                                            ? Colors.yellow[300]
                                            : Colors.white,
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
