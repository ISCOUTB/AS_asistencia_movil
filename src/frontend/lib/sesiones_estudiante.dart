import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/custom_header.dart';
import 'api/core/user_session_provider.dart';
import 'package:provider/provider.dart';
import 'utils/responsive_utils.dart';
import 'api/routes/asistencia_service.dart';
import 'api/routes/sesion_service.dart';
import 'api/notificacion_service.dart';
import 'notificaciones.dart';
import 'test_notificaciones.dart';
import 'qr_scanner_screen.dart';

class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 137, 99, 207);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
  static const backgroundLight = Color(0xFFF3F4F6);
}

class StudentSesionesPage extends StatefulWidget {
  const StudentSesionesPage({super.key});

  @override
  State<StudentSesionesPage> createState() => _StudentSesionesPageState();
}

class _StudentSesionesPageState extends State<StudentSesionesPage> {
  final Map<int, String> _attendance = {};
  List<Map<String, dynamic>> _sesiones = [];
  List<Map<String, dynamic>> _sesionesPendientes = [];
  bool _isLoading = true;
  bool _isLoadingPendientes = true;

  @override
  void initState() {
    super.initState();
    _cargarSesiones();
    _cargarSesionesPendientes();
    _loadAttendance();
    
    // Cargar notificaciones del usuario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userEmail = context.read<UserSessionProvider>().email;
      if (userEmail.isNotEmpty) {
        context.read<NotificacionService>().cargarNotificaciones(userEmail);
      }
    });
  }

  Future<void> _cargarSesiones() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userSession = context.read<UserSessionProvider>();
      final email = userSession.email;

      if (email.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtener asistencias del estudiante
      final asistenciaService = AsistenciaService(
        'https://ga7a0b6c9043600-atpdb.adb.us-phoenix-1.oraclecloudapps.com/ords/ecoutb_workspace/asistencia_sesiones/',
      );

      final asistencias = await asistenciaService.getAsistenciasPorEstudiante(email);
      
      // Obtener sesiones activas para mostrar solo las vigentes
      final sesionService = SesionService(
        'https://ga7a0b6c9043600-atpdb.adb.us-phoenix-1.oraclecloudapps.com/ords/ecoutb_workspace/sesiones/',
      );
      
      final todasSesiones = await sesionService.getSesionesActivas();
      
      // Filtrar solo las sesiones donde el estudiante tiene asistencia registrada
      final idsConAsistencia = asistencias.map((a) => a['id_sesion']).toSet();
      
      final sesionesVigentesConAsistencia = todasSesiones
          .where((s) => 
            idsConAsistencia.contains(s['id']) &&
            s['gestiona_asis'] == 'S' // Filtrar solo sesiones activas (no canceladas)
          )
          .map((sesion) {
            // Encontrar la asistencia correspondiente
            final asistencia = asistencias.firstWhere(
              (a) => a['id_sesion'] == sesion['id'],
              orElse: () => {},
            );
            
            return {
              'id': sesion['id'],
              'nombre_sesion': sesion['nombre_sesion'],
              'fecha_sesion': sesion['fecha'],
              'hora_inicio_sesion': sesion['hora_inicio_sesion'],
              'hora_fin': sesion['hora_fin'],
              'lugar_sesion': sesion['lugar_sesion'],
              'id_servicio': sesion['id_servicio'],
              'fecha_hora_asistencia': asistencia['fecha_hora_asistencia'] ?? '',
              'estado_asistencia': asistencia['estado'] ?? 'Presente',
            };
          }).toList();

      setState(() {
        _sesiones = sesionesVigentesConAsistencia;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error cargando sesiones: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refrescarDatos() async {
    await Future.wait([
      _cargarSesiones(),
      _cargarSesionesPendientes(),
    ]);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _cargarSesionesPendientes() async {
    setState(() {
      _isLoadingPendientes = true;
    });

    try {
      final userSession = context.read<UserSessionProvider>();
      final email = userSession.email;

      if (email.isEmpty) {
        setState(() {
          _isLoadingPendientes = false;
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final String key = 'sesiones_pendientes_$email';
      final String? sesionesJson = prefs.getString(key);

      if (sesionesJson != null && sesionesJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(sesionesJson);
        // Filtrar sesiones canceladas (gestiona_asis != 'S')
        final sesionesFiltradas = decoded
            .cast<Map<String, dynamic>>()
            .where((s) => s['gestiona_asis'] == 'S')
            .toList();
        setState(() {
          _sesionesPendientes = sesionesFiltradas;
          _isLoadingPendientes = false;
        });
      } else {
        setState(() {
          _sesionesPendientes = [];
          _isLoadingPendientes = false;
        });
      }
    } catch (e) {
      debugPrint('Error cargando sesiones pendientes: $e');
      setState(() {
        _sesionesPendientes = [];
        _isLoadingPendientes = false;
      });
    }
  }

  void _mostrarDialogoAsistencia(BuildContext context, int index) {
    final TextEditingController codigoController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono y título
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.universityBlue, AppColors.universityBlue],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Código de Asistencia',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Solicita el código al profesor',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Campo de código
              TextField(
                controller: codigoController,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                maxLength: 6,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'ABC123',
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.universityBlue,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Botones
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final codigo = codigoController.text.trim().toUpperCase();
                        if (codigo.length != 6) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: const Text('El código debe tener 6 caracteres'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                          return;
                        }

                        // Mostrar indicador de carga
                        Navigator.pop(dialogContext);
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text('Validando código...'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );

                        try {
                          // Obtener email del estudiante
                          final userSession = context.read<UserSessionProvider>();
                          final emailEstudiante = userSession.email;

                          if (emailEstudiante.isEmpty) {
                            if (!mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('No se pudo obtener la información del estudiante'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                            return;
                          }

                          // Validar código
                          final sesionService = SesionService('https://ga7a0b6c9043600-atpdb.adb.us-phoenix-1.oraclecloudapps.com/ords/ecoutb_workspace/sesiones/');
                          final sesionData = await sesionService.validarCodigoAcceso(codigo);

                          if (!mounted) return;
                          Navigator.pop(context); // Cerrar indicador de carga

                          if (sesionData == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.white),
                                    SizedBox(width: 12),
                                    Expanded(child: Text('Código inválido o sesión no encontrada')),
                                  ],
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                            return;
                          }

                          // Registrar asistencia
                          final asistencia = {
                            'id_sesiones': sesionData['id'], // El backend devuelve 'id', no 'id_sesiones'
                            'email_persona': emailEstudiante,
                            'fecha_hora_asistencia': DateTime.now().toIso8601String(),
                          };

                          final asistenciaService = AsistenciaService('https://ga7a0b6c9043600-atpdb.adb.us-phoenix-1.oraclecloudapps.com/ords/ecoutb_workspace/asistencia_sesiones/');
                          await asistenciaService.createAsistencia(asistencia);

                          if (!mounted) return;

                          // Éxito
                          setState(() {
                            _attendance[index] = 'Presente';
                          });
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text('Asistencia registrada en: ${sesionData['nombre_sesion'] ?? 'sesión'}'),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          // Cerrar indicador de carga si sigue abierto
                          try {
                            Navigator.pop(context);
                          } catch (_) {}
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al procesar: $e'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.universityBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Confirmar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('attendance_map');
      if (raw != null && raw.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(raw);
        _attendance.clear();
        decoded.forEach((k, v) {
          final intKey = int.tryParse(k);
          if (intKey != null && v is String) {
            _attendance[intKey] = v;
          }
        });
        if (mounted) setState(() {});
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _saveAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, String> toStore = {};
      _attendance.forEach((k, v) => toStore[k.toString()] = v);
      await prefs.setString('attendance_map', jsonEncode(toStore));
    } catch (e) {
      // ignore
    }
  }

  void _showAttendanceModal(BuildContext context, int index) {
    final currentStatus = _attendance[index];
    final isLandscape = context.isLandscape;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext modalContext) {
        final modalPadding = ResponsiveUtils.getCardPadding(modalContext);
        final titleFontSize = ResponsiveUtils.getFontSize(modalContext, 18);
        final subtitleFontSize = ResponsiveUtils.getFontSize(modalContext, 13);
        final iconSize = ResponsiveUtils.getIconSize(modalContext, 24);
        final spacing = ResponsiveUtils.getSpacing(modalContext, 12);
        final iconPadding = isLandscape ? 8.0 : 10.0;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(ResponsiveUtils.getBorderRadius(modalContext, 24))),
          ),
          padding: modalPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle visual
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(modalContext, 20)),
              
              // Título
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(iconPadding),
                    decoration: BoxDecoration(
                      color: AppColors.universityBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(modalContext, 12)),
                    ),
                    child: Icon(Icons.how_to_reg, color: AppColors.universityBlue, size: iconSize),
                  ),
                  SizedBox(width: spacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estado de Asistencia',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          'Selecciona tu estado',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: ResponsiveUtils.getSpacing(modalContext, 24)),
              
              // Opciones de asistencia
              _buildAttendanceOption(
                modalContext,
                index,
                'Presente',
                Icons.check_circle,
                Colors.green,
                currentStatus == 'Presente',
              ),
              SizedBox(height: spacing),
              _buildAttendanceOption(
                modalContext,
                index,
                'Ausente',
                Icons.cancel,
                Colors.red,
                currentStatus == 'Ausente',
              ),
              SizedBox(height: spacing),
              _buildAttendanceOption(
                modalContext,
                index,
                'Inasistencia Justificada',
                Icons.assignment_turned_in,
                Colors.orange,
                currentStatus == 'Inasistencia Justificada',
              ),
              SizedBox(height: spacing),
              _buildAttendanceOption(
                modalContext,
                index,
                'Inasistencia No Justificada',
                Icons.assignment_late,
                Colors.deepOrange,
                currentStatus == 'Inasistencia No Justificada',
              ),
              
              SizedBox(height: ResponsiveUtils.getSpacing(modalContext, 20)),
              
              // Botón para quitar estado (si existe)
              if (currentStatus != null) ...[
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _attendance.remove(index);
                    });
                    _saveAttendance();
                    Navigator.pop(modalContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Estado de asistencia eliminado'),
                        backgroundColor: Colors.grey.shade700,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  icon: Icon(Icons.delete_outline, size: ResponsiveUtils.getIconSize(modalContext, 20)),
                  label: Text(
                    'Quitar Estado de Asistencia',
                    style: TextStyle(fontSize: ResponsiveUtils.getFontSize(modalContext, 14)),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: isLandscape ? 10.0 : 12.0),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendanceOption(
    BuildContext modalContext,
    int index,
    String status,
    IconData icon,
    Color color,
    bool isSelected,
  ) {
    final isLandscape = modalContext.isLandscape;
    final optionFontSize = ResponsiveUtils.getFontSize(modalContext, 16);
    final optionIconSize = ResponsiveUtils.getIconSize(modalContext, 24);
    final borderRadius = ResponsiveUtils.getBorderRadius(modalContext, 14);
    final iconBorderRadius = ResponsiveUtils.getBorderRadius(modalContext, 10);
    final iconPadding = isLandscape ? 8.0 : 10.0;
    final containerPadding = isLandscape ? 14.0 : 16.0;
    final spacing = ResponsiveUtils.getSpacing(modalContext, 16);
    
    return InkWell(
      onTap: () {
        setState(() {
          _attendance[index] = status;
        });
        _saveAttendance();
        Navigator.pop(modalContext);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Asistencia registrada como: $status'),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: EdgeInsets.all(containerPadding),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(iconBorderRadius),
              ),
              child: Icon(icon, color: color, size: optionIconSize),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: Text(
                status,
                style: TextStyle(
                  fontSize: optionFontSize,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? color : const Color(0xFF1A1A1A),
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: optionIconSize),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPadding = context.horizontalPadding;
    final spacing = ResponsiveUtils.getSpacing(context, 10);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight, // Fondo claro
      body: SafeArea(
        child: Column(
          children: [
            // Header con campanita de notificaciones
            Consumer<NotificacionService>(
              builder: (context, notifService, _) {
                return StudentHeader(
                  title: "Sesiones",
                  notificationCount: notifService.noLeidas,
                  onNotificationTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificacionesPage(),
                      ),
                    );
                  },
                );
              },
            ),
            
            Expanded(
              child: Container(
                color: AppColors.backgroundLight,
                child: RefreshIndicator(
                  onRefresh: _refrescarDatos,
                  color: AppColors.universityBlue,
                  child: (_isLoading || _isLoadingPendientes)
                      ? const Center(child: CircularProgressIndicator())
                      : (_sesiones.isEmpty && _sesionesPendientes.isEmpty)
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getSpacing(context, 32)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.event_busy,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
                                    Text(
                                      'No has escaneado ningún código QR aún',
                                      style: TextStyle(
                                        fontSize: ResponsiveUtils.getFontSize(context, 16),
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveUtils.getSpacing(context, 8)),
                                    Text(
                                      'Escanea el QR de una sesión para verla aquí',
                                      style: TextStyle(
                                        fontSize: ResponsiveUtils.getFontSize(context, 13),
                                        color: Colors.grey.shade500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView(
                              padding: EdgeInsets.only(
                                left: hPadding,
                                right: hPadding,
                                top: ResponsiveUtils.getSpacing(context, 16),
                                bottom: MediaQuery.of(context).padding.bottom + 20,
                              ),
                              children: [
                                // Sección de sesiones pendientes
                                if (_sesionesPendientes.isNotEmpty) ...[
                                  Padding(
                                    padding: EdgeInsets.only(bottom: ResponsiveUtils.getSpacing(context, 12)),
                                    child: Row(
                                      children: [
                                        Icon(Icons.pending_actions, color: Colors.orange.shade700, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Sesiones Pendientes',
                                          style: TextStyle(
                                            fontSize: ResponsiveUtils.getFontSize(context, 16),
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1A1A1A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ..._sesionesPendientes.map((sesion) => Padding(
                                        padding: EdgeInsets.only(bottom: spacing),
                                        child: _buildSesionPendienteCard(context, sesion),
                                      )),
                                  SizedBox(height: ResponsiveUtils.getSpacing(context, 24)),
                                  Divider(color: Colors.grey.shade300, thickness: 1),
                                  SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
                                ],
                                
                                // Título de sesiones confirmadas
                                if (_sesiones.isNotEmpty) ...[
                                  Padding(
                                    padding: EdgeInsets.only(bottom: ResponsiveUtils.getSpacing(context, 12)),
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Sesiones Confirmadas',
                                          style: TextStyle(
                                            fontSize: ResponsiveUtils.getFontSize(context, 16),
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1A1A1A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ..._sesiones.map((s) => Padding(
                                        padding: EdgeInsets.only(bottom: spacing),
                                        child: _buildSessionCard(context, s, _sesiones.indexOf(s)),
                                      )),
                                ],
                              ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final email = context.read<UserSessionProvider>().email;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TestNotificacionesPage(emailEstudiante: email),
            ),
          );
        },
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.bug_report),
        label: const Text('Test'),
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    Map<String, dynamic> s,
    int index,
  ) {
    final cardPadding = ResponsiveUtils.getCardPadding(context);
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 14);
    final titleFontSize = ResponsiveUtils.getFontSize(context, 15);
    final subtitleFontSize = ResponsiveUtils.getFontSize(context, 12);
    final iconSize = ResponsiveUtils.getIconSize(context, 20);
    final buttonIconSize = ResponsiveUtils.getIconSize(context, 16);
    final buttonFontSize = ResponsiveUtils.getFontSize(context, 13);
    final isLandscape = context.isLandscape;
    final iconBg = isLandscape ? 6.0 : 8.0;
    final iconBorderRadius = ResponsiveUtils.getBorderRadius(context, 10);
    final spacing = ResponsiveUtils.getSpacing(context, 10);
    final buttonVPadding = isLandscape ? 8.0 : 10.0;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header compacto
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(iconBg),
                decoration: BoxDecoration(
                  color: AppColors.universityBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(iconBorderRadius),
                ),
                child: Icon(Icons.event_note, color: AppColors.universityBlue, size: iconSize),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s['nombre_sesion'] ?? 'Sesión',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Servicio ${s['id_servicio'] ?? ''}',
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: spacing),
          
          // Info condensada en 2 filas
          Row(
            children: [
              Expanded(
                child: _buildCompactInfo(context, Icons.calendar_today, s['fecha_sesion'] ?? ''),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
              Expanded(
                child: _buildCompactInfo(context, Icons.access_time, '${s['hora_inicio_sesion'] ?? ''} - ${s['hora_fin'] ?? ''}'),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 6)),
          _buildCompactInfo(
            context,
            Icons.location_on,
            s['lugar_sesion'] ?? 'Sin ubicación',
          ),
          
          SizedBox(height: spacing),
          
          // Badge de estado - Siempre "Registrada" porque solo mostramos sesiones con asistencia
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: buttonVPadding, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(iconBorderRadius),
              border: Border.all(color: Colors.green, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: buttonIconSize),
                SizedBox(width: 8),
                Text(
                  'Asistencia Registrada',
                  style: TextStyle(
                    fontSize: buttonFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfo(BuildContext context, IconData icon, String value) {
    final iconSize = ResponsiveUtils.getIconSize(context, 14);
    final fontSize = ResponsiveUtils.getFontSize(context, 12);
    final spacing = ResponsiveUtils.getSpacing(context, 6);
    
    return Row(
      children: [
        Icon(icon, size: iconSize, color: AppColors.universityBlue),
        SizedBox(width: spacing),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              color: const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSesionPendienteCard(BuildContext context, Map<String, dynamic> sesion) {
    final cardPadding = ResponsiveUtils.getCardPadding(context);
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 12);
    final iconBorderRadius = ResponsiveUtils.getBorderRadius(context, 10);
    final iconSize = ResponsiveUtils.getIconSize(context, 20);
    final titleFontSize = ResponsiveUtils.getFontSize(context, 14);
    final infoFontSize = ResponsiveUtils.getFontSize(context, 12);
    final infoIconSize = ResponsiveUtils.getIconSize(context, 12);
    final spacing = ResponsiveUtils.getSpacing(context, 12);
    final iconBgPadding = context.isLandscape ? 6.0 : 8.0;
    
    return Container(
      padding: cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.orange.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icono de pendiente
              Container(
                padding: EdgeInsets.all(iconBgPadding),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(iconBorderRadius),
                ),
                child: Icon(
                  Icons.schedule,
                  color: Colors.orange.shade700,
                  size: iconSize,
                ),
              ),
              SizedBox(width: spacing),
              
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sesion['nombre_sesion'] ?? 'Sesión',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getSpacing(context, 4)),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: infoIconSize, color: Colors.grey.shade600),
                        SizedBox(width: ResponsiveUtils.getSpacing(context, 4)),
                        Text(
                          sesion['fecha_sesion'] ?? '',
                          style: TextStyle(
                            fontSize: infoFontSize,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Botón de verificar
              ElevatedButton.icon(
                onPressed: () => _mostrarDialogoVerificacion(sesion),
                icon: const Icon(Icons.verified, size: 16),
                label: const Text('Verificar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoVerificacion(Map<String, dynamic> sesion) {
    final TextEditingController codigoController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.universityBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock, color: AppColors.universityBlue, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Código de Verificación',
                style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sesion['nombre_sesion'] ?? 'Sesión',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codigoController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Código de 6 caracteres',
                hintText: 'ABC123',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.key),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.universityBlue, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Ingresa el código proporcionado por el profesor',
                      style: TextStyle(fontSize: 11, color: Color(0xFF1A1A1A)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            onPressed: () => _verificarYRegistrar(sesion, codigoController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.universityBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _verificarYRegistrar(Map<String, dynamic> sesion, String codigoIngresado) async {
    if (codigoIngresado.trim().isEmpty) {
      _mostrarMensaje('Error', 'Por favor ingresa el código de verificación', Icons.error, Colors.red);
      return;
    }

    // Verificar que el código coincida
    final String codigoEsperado = (sesion['codigo_acceso'] ?? '').toString().toUpperCase();
    final String codigoIngresadoUpper = codigoIngresado.trim().toUpperCase();

    if (codigoIngresadoUpper != codigoEsperado) {
      _mostrarMensaje('Código Incorrecto', 'El código ingresado no coincide', Icons.error, Colors.red);
      return;
    }

    // Cerrar diálogo de verificación
    Navigator.pop(context);

    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Registrando asistencia...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final userSession = context.read<UserSessionProvider>();
      final email = userSession.email;

      final asistenciaService = AsistenciaService('https://ga7a0b6c9043600-atpdb.adb.us-phoenix-1.oraclecloudapps.com/ords/ecoutb_workspace/asistencia_sesiones/');
      
      // Verificar si ya existe esta asistencia consultando al backend
      final asistenciasExistentes = await asistenciaService.getAsistenciasPorEstudiante(email);
      final yaRegistrada = asistenciasExistentes.any((a) => a['id_sesion'] == sesion['id']);
      
      if (yaRegistrada) {
        if (!mounted) return;
        Navigator.pop(context); // Cerrar diálogo de carga
        
        _mostrarMensaje(
          'Ya Registrada',
          'Esta asistencia ya fue registrada anteriormente',
          Icons.info,
          Colors.orange,
        );
        
        // Recargar para actualizar la vista
        await _refrescarDatos();
        return;
      }

      // Registrar asistencia
      final asistencia = {
        'id_sesiones': sesion['id'],
        'email_persona': email,
        'fecha_hora_asistencia': DateTime.now().toIso8601String(),
      };

      try {
        await asistenciaService.createAsistencia(asistencia);
      } catch (registroError) {
        // Si el error es ORA-00001 (duplicado), manejarlo apropiadamente
        final errorString = registroError.toString();
        if (errorString.contains('ORA-00001') || errorString.contains('unique constraint')) {
          if (!mounted) return;
          Navigator.pop(context); // Cerrar diálogo de carga
          
          _mostrarMensaje(
            'Ya Registrada',
            'Esta asistencia ya fue registrada anteriormente',
            Icons.info,
            Colors.orange,
          );
          
          // Recargar para actualizar la vista
          await _refrescarDatos();
          return;
        }
        // Si es otro tipo de error, lanzarlo de nuevo
        rethrow;
      }

      // Eliminar de pendientes
      final prefs = await SharedPreferences.getInstance();
      final String key = 'sesiones_pendientes_$email';
      _sesionesPendientes.removeWhere((s) => s['id'] == sesion['id']);
      await prefs.setString(key, jsonEncode(_sesionesPendientes));

      if (!mounted) return;
      Navigator.pop(context); // Cerrar diálogo de carga

      // Recargar sesiones para mostrar la nueva
      await _cargarSesiones();

      _mostrarMensaje(
        '¡Asistencia Registrada!',
        'Tu asistencia ha sido confirmada exitosamente',
        Icons.check_circle,
        Colors.green,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Cerrar diálogo de carga
      _mostrarMensaje('Error', 'Error al registrar asistencia: $e', Icons.error, Colors.red);
    }
  }

  void _mostrarMensaje(String titulo, String mensaje, IconData icono, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icono, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          mensaje,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
