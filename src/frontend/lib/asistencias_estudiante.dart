import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/custom_header.dart';
import 'utils/responsive_utils.dart';
import 'api/routes/asistencia_service.dart';
import 'api/core/user_session_provider.dart';
import 'api/notificacion_service.dart';
import 'notificaciones.dart';

class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 137, 99, 207);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
  static const backgroundLight = Color(0xFFF3F4F6);
}

class StudentAsistenciasPage extends StatefulWidget {
  const StudentAsistenciasPage({super.key});

  @override
  State<StudentAsistenciasPage> createState() => _StudentAsistenciasPageState();
}

class _StudentAsistenciasPageState extends State<StudentAsistenciasPage> {
  List<Map<String, dynamic>> _asistencias = [];
  bool _isLoadingAsistencias = true;

  @override
  void initState() {
    super.initState();
    _cargarAsistencias();
    
    // Cargar notificaciones del usuario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userEmail = context.read<UserSessionProvider>().email;
      if (userEmail.isNotEmpty) {
        context.read<NotificacionService>().cargarNotificaciones(userEmail);
      }
    });
  }

  Future<void> _cargarAsistencias() async {
    setState(() {
      _isLoadingAsistencias = true;
    });

    try {
      final userSession = context.read<UserSessionProvider>();
      final email = userSession.email;

      if (email.isEmpty) {
        setState(() {
          _isLoadingAsistencias = false;
        });
        return;
      }

      final asistenciaService = AsistenciaService(
        'https://ga7a0b6c9043600-atpdb.adb.us-phoenix-1.oraclecloudapps.com/ords/ecoutb_workspace/asistencia_sesiones/',
      );

      final asistencias = await asistenciaService.getAsistenciasPorEstudiante(email);

      setState(() {
        _asistencias = asistencias;
        _isLoadingAsistencias = false;
      });
    } catch (e) {
      debugPrint('Error cargando asistencias: $e');
      setState(() {
        _isLoadingAsistencias = false;
      });
    }
  }

  Future<void> _refrescarDatos() async {
    await _cargarAsistencias();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPadding = context.horizontalPadding;
    final spacing = ResponsiveUtils.getSpacing(context, 8);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight, // Fondo claro
      body: SafeArea(
        child: Column(
          children: [
            // Header discreto para estudiantes
            Consumer<NotificacionService>(
              builder: (context, notifService, child) {
                return StudentHeader(
                  title: "Asistencias",
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
                  child: _isLoadingAsistencias
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          padding: EdgeInsets.only(
                            left: hPadding,
                            right: hPadding,
                            top: ResponsiveUtils.getSpacing(context, 16),
                            bottom: MediaQuery.of(context).padding.bottom + 20,
                          ),
                          children: [
                            // Título del historial de asistencias
                            Padding(
                              padding: EdgeInsets.only(bottom: ResponsiveUtils.getSpacing(context, 12)),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Historial de Asistencias',
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.getFontSize(context, 16),
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Lista de asistencias
                            if (_asistencias.isEmpty)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getSpacing(context, 32)),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.event_busy,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
                                      Text(
                                        'No hay asistencias registradas',
                                        style: TextStyle(
                                          fontSize: ResponsiveUtils.getFontSize(context, 16),
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ..._asistencias.asMap().entries.map((entry) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: spacing),
                                  child: _buildAsistenciaCard(context, entry.value),
                                );
                              }),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                style: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(mensaje),
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

  Widget _buildAsistenciaCard(BuildContext context, Map<String, dynamic> asistencia) {
    // Determinar color según el estado
    final String estado = asistencia['estado']?.toString() ?? 'Presente';
    final Color statusColor = estado == 'Presente'
        ? Colors.green
        : estado.contains('Ausente') || estado.contains('Falta')
            ? Colors.red
            : Colors.orange;

    final cardPadding = ResponsiveUtils.getCardPadding(context);
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 12);
    final iconBorderRadius = ResponsiveUtils.getBorderRadius(context, 10);
    final badgeBorderRadius = ResponsiveUtils.getBorderRadius(context, 8);
    final iconSize = ResponsiveUtils.getIconSize(context, 20);
    final titleFontSize = ResponsiveUtils.getFontSize(context, 14);
    final infoFontSize = ResponsiveUtils.getFontSize(context, 12);
    final infoIconSize = ResponsiveUtils.getIconSize(context, 12);
    final badgeFontSize = ResponsiveUtils.getFontSize(context, 11);
    final spacing = ResponsiveUtils.getSpacing(context, 12);
    final iconBgPadding = context.isLandscape ? 6.0 : 8.0;
    final badgeHPadding = context.isLandscape ? 8.0 : 10.0;
    final badgeVPadding = context.isLandscape ? 4.0 : 6.0;
    
    return Container(
      padding: cardPadding,
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
      child: Row(
        children: [
          // Icono de estado
          Container(
            padding: EdgeInsets.all(iconBgPadding),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(iconBorderRadius),
            ),
            child: Icon(
              estado == 'Presente' ? Icons.check_circle : 
              estado.contains('Ausente') || estado.contains('Falta') ? Icons.cancel : Icons.access_time,
              color: statusColor,
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
                  asistencia['nombre_sesion']?.toString() ?? 'Sesión',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 4)),
                Row(
                  children: [
                    Icon(Icons.location_on, size: infoIconSize, color: Colors.grey.shade600),
                    SizedBox(width: ResponsiveUtils.getSpacing(context, 4)),
                    Flexible(
                      child: Text(
                        asistencia['lugar']?.toString() ?? 'Sin ubicación',
                        style: TextStyle(
                          fontSize: infoFontSize,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 2)),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: infoIconSize, color: Colors.grey.shade600),
                    SizedBox(width: ResponsiveUtils.getSpacing(context, 4)),
                    Text(
                      asistencia['fecha_sesion']?.toString() ?? '',
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
          
          // Badge de estado
          Container(
            padding: EdgeInsets.symmetric(horizontal: badgeHPadding, vertical: badgeVPadding),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(badgeBorderRadius),
              border: Border.all(color: statusColor, width: 1),
            ),
            child: Text(
              estado,
              style: TextStyle(
                color: statusColor,
                fontSize: badgeFontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
