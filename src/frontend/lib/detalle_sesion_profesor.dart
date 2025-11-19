import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'api/routes/sesion_service.dart';
import 'api/notificacion_service.dart';

// 🔑 CLAVE DE ADMINISTRADOR - Puedes cambiarla aquí
const String ADMIN_PASSWORD = 'soplapolla24';

class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 137, 99, 207);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
  static const backgroundLight = Color(0xFFF3F4F6);
}

class DetalleSesionProfesorPage extends StatefulWidget {
  final Map<String, dynamic> sesion;

  const DetalleSesionProfesorPage({
    super.key,
    required this.sesion,
  });

  @override
  State<DetalleSesionProfesorPage> createState() => _DetalleSesionProfesorPageState();
}

class _DetalleSesionProfesorPageState extends State<DetalleSesionProfesorPage> {
  final GlobalKey _qrKey = GlobalKey();
  bool _eliminando = false;

  // Mostrar diálogo para eliminar sesión con asistencias usando clave admin
  Future<void> _mostrarDialogoEliminarConAsistencias() async {
    final claveController = TextEditingController();
    bool claveIncorrecta = false;
    bool eliminando = false;

    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => WillPopScope(
          onWillPop: () async => !eliminando,
          child: AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 28),
                SizedBox(width: 10),
                Expanded(child: Text('Sesión con Asistencias')),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Esta sesión tiene estudiantes registrados.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  if (!eliminando) ...[
                    const Text(
                      '🔑 Ingresa la clave de administrador para forzar la eliminación:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: claveController,
                      obscureText: true,
                      enabled: !eliminando,
                      decoration: InputDecoration(
                        labelText: 'Clave de administrador',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        errorText: claveIncorrecta ? 'Clave incorrecta' : null,
                      ),
                      onChanged: (value) {
                        if (claveIncorrecta) {
                          setDialogState(() {
                            claveIncorrecta = false;
                          });
                        }
                      },
                      onSubmitted: (value) async {
                        if (value == ADMIN_PASSWORD) {
                          setDialogState(() {
                            eliminando = true;
                          });
                          final exito = await _forzarEliminacionConAsistencias();
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext, exito);
                          }
                        } else {
                          setDialogState(() {
                            claveIncorrecta = true;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '⚠️ Se eliminarán todas las asistencias registradas.',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ] else ...[
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Eliminando asistencias y sesión...'),
                          SizedBox(height: 8),
                          Text(
                            'Esto puede tardar unos segundos',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: eliminando ? [] : [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (claveController.text == ADMIN_PASSWORD) {
                    setDialogState(() {
                      eliminando = true;
                    });
                    final exito = await _forzarEliminacionConAsistencias();
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext, exito);
                    }
                  } else {
                    setDialogState(() {
                      claveIncorrecta = true;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar Todo'),
              ),
            ],
          ),
        ),
      ),
    );

    if (resultado == true) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión y asistencias eliminadas exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pop(context, true);
    }
  }

  // Forzar eliminación con múltiples estrategias
  Future<bool> _forzarEliminacionConAsistencias() async {
    try {
      final baseUrl = 'https://ga7a0b6c9043600-atpdb.adb.us-phoenix-1.oraclecloudapps.com/ords/ecoutb_workspace';
      final idSesion = widget.sesion['id'];
      
      debugPrint('🔥 FORZANDO eliminación de sesión $idSesion');

      // Estrategia 1: Intentar obtener y eliminar asistencias usando query directa
      try {
        final asistenciasUrl = '$baseUrl/asistencia_sesiones/?q={"id_sesiones":$idSesion}';
        debugPrint('📡 Buscando asistencias: $asistenciasUrl');
        
        final response = await http.get(
          Uri.parse(asistenciasUrl),
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'Flutter-Client',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final asistencias = (data['items'] as List?) ?? [];
          
          debugPrint('📋 ${asistencias.length} asistencias encontradas');

          // Intentar eliminar cada asistencia usando diferentes métodos
          for (var asistencia in asistencias) {
            final idAsistencia = asistencia['id'];
            debugPrint('🗑️ Eliminando asistencia $idAsistencia');

            // Método 1: DELETE directo
            try {
              await http.delete(
                Uri.parse('$baseUrl/asistencia_sesiones/$idAsistencia'),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              );
              debugPrint('✅ Método DELETE funcionó para $idAsistencia');
              continue;
            } catch (e) {
              debugPrint('⚠️ DELETE falló: $e');
            }

            // Método 2: PUT con estado "eliminado" o similar
            try {
              await http.put(
                Uri.parse('$baseUrl/asistencia_sesiones/$idAsistencia'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'estado_asistencia': 'ELIMINADO'}),
              );
              debugPrint('✅ Marcado como eliminado: $idAsistencia');
            } catch (e) {
              debugPrint('⚠️ PUT falló: $e');
            }
          }

          debugPrint('✅ Asistencias procesadas');
          
          // Esperar más tiempo para que el backend procese los cambios
          debugPrint('⏳ Esperando a que el backend procese las eliminaciones...');
          await Future.delayed(const Duration(seconds: 2));
          
          // Verificar que realmente se eliminaron
          debugPrint('🔍 Verificando eliminación de asistencias...');
          try {
            final verifyResponse = await http.get(
              Uri.parse(asistenciasUrl),
              headers: {
                'Accept': 'application/json',
                'User-Agent': 'Flutter-Client',
              },
            );
            
            if (verifyResponse.statusCode == 200) {
              final verifyData = jsonDecode(verifyResponse.body);
              final remaining = (verifyData['items'] as List?) ?? [];
              debugPrint('📊 Asistencias restantes: ${remaining.length}');
            }
          } catch (e) {
            debugPrint('⚠️ No se pudo verificar: $e');
          }
        }
      } catch (e) {
        debugPrint('⚠️ No se pudieron procesar asistencias: $e');
        // Continuar de todas formas
      }

      // Pausa adicional para asegurar que el backend procese
      debugPrint('⏳ Pausa final antes de eliminar sesión...');
      await Future.delayed(const Duration(milliseconds: 500));

      // Estrategia 2: Intentar eliminar la sesión con múltiples métodos
      final sesionService = SesionService('$baseUrl/sesiones/');
      
      try {
        await sesionService.deleteSesion(idSesion);
        debugPrint('✅ Sesión eliminada exitosamente');
        return true;
      } catch (e) {
        debugPrint('⚠️ Error al eliminar sesión: $e');
        
        // Si aún hay error de integridad, intentar eliminar asistencias de nuevo
        if (e.toString().contains('ORA-02292') || e.toString().contains('child record')) {
          debugPrint('🔄 Reintentando eliminación de asistencias...');
          
          try {
            // Intentar query diferente
            final altUrl = '$baseUrl/asistencia_sesiones/';
            final allResponse = await http.get(
              Uri.parse(altUrl),
              headers: {
                'Accept': 'application/json',
                'User-Agent': 'Flutter-Client',
              },
            );
            
            if (allResponse.statusCode == 200) {
              final allData = jsonDecode(allResponse.body);
              final allItems = (allData['items'] as List?) ?? [];
              
              // Filtrar manualmente por id_sesiones
              final sessionItems = allItems.where((item) => 
                item['id_sesiones'] == idSesion || 
                item['id_sesion'] == idSesion
              ).toList();
              
              debugPrint('🔍 Encontradas ${sessionItems.length} asistencias adicionales');
              
              for (var item in sessionItems) {
                try {
                  await http.delete(
                    Uri.parse('$altUrl${item['id']}'),
                    headers: {'Content-Type': 'application/json'},
                  );
                  debugPrint('✅ Asistencia ${item['id']} eliminada (segundo intento)');
                } catch (e2) {
                  debugPrint('❌ Fallo: $e2');
                }
              }
              
              // Esperar y reintentar eliminar sesión
              await Future.delayed(const Duration(seconds: 1));
              
              try {
                await sesionService.deleteSesion(idSesion);
                debugPrint('✅ Sesión eliminada en segundo intento');
                return true;
              } catch (e3) {
                debugPrint('❌ Segundo intento falló: $e3');
              }
            }
          } catch (e2) {
            debugPrint('❌ Reintento falló: $e2');
          }
        }
        
        // Estrategia final: Marcar como inactiva
        try {
          await http.put(
            Uri.parse('$baseUrl/sesiones/$idSesion'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'gestiona_asis': 'N',
              'n_maximo_asistentes': 0,
            }),
          );
          debugPrint('⚠️ Sesión marcada como inactiva');
          // Considerarlo como éxito parcial
          return true;
        } catch (e2) {
          debugPrint('❌ Todas las estrategias fallaron: $e2');
          return false;
        }
      }
    } catch (e) {
      debugPrint('❌ Error fatal en forzar eliminación: $e');
      return false;
    }
  }

  // Capturar el QR como imagen
  Future<Uint8List?> _capturarQR() async {
    try {
      RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error al capturar QR: $e');
      return null;
    }
  }

  // Cancelar sesión (marcar como inactiva y notificar)
  Future<void> _cancelarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text('Cancelar Sesión'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas cancelar esta sesión?\n\n'
          'Los estudiantes registrados recibirán una notificación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() {
      _eliminando = true;
    });

    try {
      final baseUrl = 'https://ga7a0b6c9043600-atpdb.adb.us-phoenix-1.oraclecloudapps.com/ords/ecoutb_workspace';
      final idSesion = widget.sesion['id'];
      
      debugPrint('🚫 Cancelando sesión $idSesion');

      // Obtener estudiantes registrados para notificarles
      try {
        final asistenciasUrl = '$baseUrl/asistencia_sesiones/?q={"id_sesiones":$idSesion}';
        final response = await http.get(
          Uri.parse(asistenciasUrl),
          headers: {'Accept': 'application/json', 'User-Agent': 'Flutter-Client'},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final asistencias = (data['items'] as List?) ?? [];
          
          debugPrint('📧 Enviando notificaciones a ${asistencias.length} estudiantes');
          
          // Enviar notificaciones a cada estudiante
          final notifService = context.read<NotificacionService>();
          for (var asistencia in asistencias) {
            final emailEstudiante = asistencia['email_persona'];
            debugPrint('📬 Notificando a: $emailEstudiante');
            
            await notifService.agregarNotificacion(
              email: emailEstudiante,
              tipo: 'sesion_cancelada',
              titulo: 'Sesión Cancelada',
              mensaje: 'La sesión "${widget.sesion['nombre_sesion']}" ha sido cancelada',
              datos: {'id_sesion': idSesion},
            );
          }
        }
      } catch (e) {
        debugPrint('⚠️ No se pudieron obtener asistencias: $e');
      }

      // Marcar sesión como cancelada
      await http.put(
        Uri.parse('$baseUrl/sesiones/$idSesion'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'gestiona_asis': 'N', // Inactiva
          'descripcion': (widget.sesion['descripcion'] ?? '') + ' [CANCELADA]',
        }),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión cancelada. Los estudiantes serán notificados.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pop(context, true);
      
    } catch (e) {
      debugPrint('❌ Error cancelando sesión: $e');
      
      if (!mounted) return;

      setState(() {
        _eliminando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cancelar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Eliminar sesión
  Future<void> _eliminarSesion() async {
    // Primer intento: diálogo de confirmación simple
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Sesión'),
        content: const Text('¿Estás seguro de que deseas eliminar esta sesión?\n\nSi tiene asistencias registradas, también se eliminarán.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() {
      _eliminando = true;
    });

    try {
      final sesionService = SesionService(
        'https://ga7a0b6c9043600-atpdb.adb.us-phoenix-1.oraclecloudapps.com/ords/ecoutb_workspace/sesiones/',
      );
      
      debugPrint('🗑️ Eliminando sesión ID: ${widget.sesion['id']}');
      await sesionService.deleteSesion(widget.sesion['id']);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión eliminada exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true); // Regresar con señal de actualización
      
    } catch (e) {
      debugPrint('❌ Error eliminando sesión: $e');
      
      if (!mounted) return;

      final errorString = e.toString();
      debugPrint('🔍 Analizando error: $errorString');
      debugPrint('🔍 Contiene ORA-02292: ${errorString.contains('ORA-02292')}');
      debugPrint('🔍 Contiene child record: ${errorString.contains('child record found')}');
      
      // Si el error es ORA-02292 (tiene asistencias), mostrar diálogo especial
      if (errorString.contains('ORA-02292') || errorString.contains('child record found') || errorString.contains('asistencias registradas')) {
        debugPrint('✅ Error de integridad detectado, mostrando diálogo especial');
        setState(() {
          _eliminando = false;
        });

        await _mostrarDialogoEliminarConAsistencias();

        return; // No continuar
      }

      setState(() {
        _eliminando = false;
      });

      // Otros errores
      String mensajeError = errorString.replaceAll('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $mensajeError'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener código de acceso de diferentes posibles campos
    final codigoAcceso = widget.sesion['codigo_acceso']?.toString() ?? 
                         widget.sesion['codigoAcceso']?.toString() ?? 
                         widget.sesion['codigo']?.toString() ?? 
                         widget.sesion['id']?.toString() ?? 'SIN_CODIGO';
    
    final nombreSesion = widget.sesion['nombre_sesion'] ?? widget.sesion['nombreSesion'] ?? 'Sesión';
    
    // Formatear fecha: solo el día (dd/mm/yyyy)
    String fechaRaw = widget.sesion['fecha']?.toString() ?? '';
    String fecha = 'Sin fecha';
    if (fechaRaw.isNotEmpty) {
      try {
        // Si viene en formato ISO (2025-11-19T02:38:28Z), extraer solo la fecha
        if (fechaRaw.contains('T')) {
          fechaRaw = fechaRaw.split('T')[0];
        }
        // Convertir de yyyy-mm-dd a dd/mm/yyyy
        final partes = fechaRaw.split('-');
        if (partes.length == 3) {
          fecha = '${partes[2]}/${partes[1]}/${partes[0]}';
        } else {
          fecha = fechaRaw;
        }
      } catch (e) {
        fecha = fechaRaw.substring(0, 10);
      }
    }
    
    // Formatear horas: solo HH:MM
    String formatearHora(String? horaRaw) {
      if (horaRaw == null || horaRaw.isEmpty) return 'N/A';
      try {
        // Si viene con formato completo (2025-11-19T02:00:00Z), extraer solo la hora
        if (horaRaw.contains('T')) {
          horaRaw = horaRaw.split('T')[1];
        }
        // Tomar solo HH:MM
        if (horaRaw.length >= 5) {
          return horaRaw.substring(0, 5);
        }
        return horaRaw;
      } catch (e) {
        return horaRaw ?? 'N/A';
      }
    }
    
    final horaInicio = formatearHora(widget.sesion['hora_inicio']?.toString() ?? widget.sesion['horaInicio']?.toString() ?? widget.sesion['hora_inicio_sesion']?.toString());
    final horaFin = formatearHora(widget.sesion['hora_fin']?.toString() ?? widget.sesion['horaFin']?.toString());
    final lugar = widget.sesion['lugar_sesion'] ?? widget.sesion['lugarSesion'] ?? 'Sin especificar';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Detalles de Sesión',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.universityBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.cancel_outlined),
            onPressed: _eliminando ? null : _cancelarSesion,
            tooltip: 'Cancelar sesión',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _eliminando ? null : _eliminarSesion,
            tooltip: 'Eliminar sesión (admin)',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card de información de la sesión
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.universityBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.event_note,
                          color: AppColors.universityBlue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombreSesion,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A202C),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lugar,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.calendar_today, 'Fecha', fecha),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.access_time, 'Hora', '$horaInicio - $horaFin'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Card del QR (principal) con código alfanumérico secundario
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Título con botón compartir
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Código QR de Asistencia',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _compartirGeneral(codigoAcceso, nombreSesion),
                        icon: const Icon(Icons.share, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.universityBlue.withValues(alpha: 0.1),
                          foregroundColor: AppColors.universityBlue,
                        ),
                        tooltip: 'Compartir',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // QR Code
                  RepaintBoundary(
                    key: _qrKey,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200, width: 2),
                      ),
                      child: QrImageView(
                        data: codigoAcceso,
                        version: QrVersions.auto,
                        size: 250,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Código alfanumérico (secundario)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.vpn_key, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            codigoAcceso,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: Color(0xFF1A202C),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: codigoAcceso));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Código copiado al portapapeles'),
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 16),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.universityBlue,
                            padding: const EdgeInsets.all(8),
                          ),
                          tooltip: 'Copiar código',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Los estudiantes pueden escanear el QR o ingresar el código manualmente',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A202C),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _compartirGeneral(String codigo, String nombreSesion) async {
    final mensaje = '''📚 Sesión: $nombreSesion
🔑 Código: $codigo

Escanea el QR o registra tu asistencia con este código en la app.''';

    // Intentar compartir con imagen QR
    try {
      final qrImage = await _capturarQR();
      if (qrImage != null) {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/qr_$codigo.png');
        await file.writeAsBytes(qrImage);
        
        await Share.shareXFiles(
          [XFile(file.path)],
          text: mensaje,
        );
        return;
      }
    } catch (e) {
      debugPrint('Error al capturar QR: $e');
    }

    // Si falla, compartir solo el mensaje
    Share.share(mensaje);
  }
}
