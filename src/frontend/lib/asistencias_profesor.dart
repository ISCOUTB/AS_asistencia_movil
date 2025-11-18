import 'package:flutter/material.dart';
import 'widgets/custom_header.dart';
import 'utils/responsive_utils.dart';
import 'api/routes/asistencia_service.dart';
import 'detalle_sesion_profesor.dart';

class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 137, 99, 207);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
  static const backgroundLight = Color(0xFFF3F4F6);
}

class TeacherAsistenciasPage extends StatefulWidget {
  const TeacherAsistenciasPage({super.key});

  @override
  State<TeacherAsistenciasPage> createState() => _TeacherAsistenciasPageState();
}

class _TeacherAsistenciasPageState extends State<TeacherAsistenciasPage> {
  late AsistenciaService asistenciaService;
  List<Map<String, dynamic>> _sesiones = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    asistenciaService = AsistenciaService(
      'https://ga7a0b6c9043600-atpdb.adb.us-phoenix-1.oraclecloudapps.com/ords/ecoutb_workspace/asistencia_sesiones/',
    );
    _cargarSesiones();
  }

  Future<void> _cargarSesiones() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sesiones = await asistenciaService.getSesionesConAsistencias();
      if (mounted) {
        setState(() {
          _sesiones = sesiones;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Si el error es 404, simplemente no hay datos aún
          _sesiones = [];
          _isLoading = false;
          _error = null; // No mostramos error para 404
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPadding = context.horizontalPadding;
    final cardSpacing = ResponsiveUtils.getSpacing(context, 12);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            const ProfessorHeader(title: "Gestión de Asistencias"),
            
            // Lista de sesiones con pull-to-refresh
            Expanded(
              child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.universityBlue),
                    ),
                  )
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _cargarSesiones,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.universityBlue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : _sesiones.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay sesiones con asistencias',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _cargarSesiones,
                    color: AppColors.universityBlue,
                    child: ListView.separated(
                      padding: EdgeInsets.only(
                        left: hPadding,
                        right: hPadding,
                        top: hPadding,
                        bottom: MediaQuery.of(context).padding.bottom + 20, // Espacio para botones de navegación
                      ),
                      itemCount: _sesiones.length,
                      separatorBuilder: (context, index) => SizedBox(height: cardSpacing),
                      itemBuilder: (context, index) {
                        final sesion = _sesiones[index];
                        return _buildSesionCard(context, sesion);
                      },
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSesionCard(BuildContext context, Map<String, dynamic> sesion) {
    final cardPadding = ResponsiveUtils.getCardPadding(context);
    final cardSpacing = ResponsiveUtils.getSpacing(context, 12);
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 16);
    final titleFontSize = ResponsiveUtils.getFontSize(context, 16);
    final subtitleFontSize = ResponsiveUtils.getFontSize(context, 14);
    final iconSize = ResponsiveUtils.getIconSize(context, 24);
    
    // Calcular estadísticas de asistencia
    final estudiantes = sesion['estudiantes'] as List;
    final totalEstudiantes = estudiantes.length;
    final presentes = estudiantes.where((e) => e['estado'] == 'Presente').length;
    final ausentes = estudiantes.where((e) => e['estado'] == 'Ausente').length;
    final tardanzas = estudiantes.where((e) => e['estado'] == 'Tardanza').length;
    
    return Container(
      margin: EdgeInsets.only(bottom: cardSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.universityBlue.withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.universityBlue.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            // Navegar a la pantalla de detalle
            final resultado = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetalleSesionProfesorPage(sesion: sesion),
              ),
            );
            
            // Si se eliminó la sesión, recargar lista
            if (resultado == true) {
              _cargarSesiones();
            }
          },
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppColors.universityBlue.withValues(alpha: 0.05),
          child: Padding(
            padding: cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header de la sesión
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.universityBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        color: AppColors.universityBlue,
                        size: iconSize,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sesion['nombreSesion'],
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A202C),
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.universityBlue.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  sesion['servicio'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.universityBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 14),
                
                // Info de fecha y hora con diseño mejorado
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        sesion['fecha'],
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${sesion['horaInicio']} - ${sesion['horaFin']}',
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 14),
                
                // Estadísticas de asistencia con diseño mejorado
                Row(
                  children: [
                    Expanded(
                      child: _buildStatChip('Total', totalEstudiantes, const Color(0xFF3B82F6), Icons.people_rounded),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatChip('Presentes', presentes, const Color(0xFF10B981), Icons.check_circle_rounded),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatChip('Ausentes', ausentes, const Color(0xFFEF4444), Icons.cancel_rounded),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatChip('Tardanzas', tardanzas, const Color(0xFFF59E0B), Icons.schedule_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _mostrarModalEstudiantes(BuildContext context, Map<String, dynamic> sesion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final estudiantes = sesion['estudiantes'] as List;
            
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Header del modal
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.universityBlue, AppColors.universityBlue],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Barra de arrastre
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sesion['nombreSesion'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${estudiantes.length} estudiantes inscritos',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Lista de estudiantes
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: estudiantes.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final estudiante = estudiantes[index];
                        return _buildEstudianteItem(
                          context,
                          estudiante,
                          (nuevoEstado) {
                            setModalState(() {
                              estudiante['estado'] = nuevoEstado;
                            });
                            setState(() {}); // Actualizar también el widget principal
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEstudianteItem(
    BuildContext context,
    Map<String, dynamic> estudiante,
    Function(String) onEstadoChanged,
  ) {
    final String estadoActual = estudiante['estado'];
    final Map<String, dynamic> estadoConfig = _getEstadoConfig(estadoActual);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: (estadoConfig['color'] as Color).withValues(alpha: 0.1),
              child: Text(
                estudiante['nombre'].toString().substring(0, 1),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: estadoConfig['color'],
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Info del estudiante
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    estudiante['nombre'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    estudiante['email'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Dropdown de estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (estadoConfig['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (estadoConfig['color'] as Color).withValues(alpha: 0.3),
                ),
              ),
              child: DropdownButton<String>(
                value: estadoActual,
                underline: const SizedBox(),
                isDense: true,
                icon: Icon(Icons.arrow_drop_down, color: estadoConfig['color'], size: 20),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: estadoConfig['color'],
                ),
                items: [
                  _buildDropdownItem('Presente', Colors.green.shade400, Icons.check_circle),
                  _buildDropdownItem('Ausente', Colors.red.shade400, Icons.cancel),
                  _buildDropdownItem('Tardanza', Colors.orange.shade400, Icons.schedule),
                  _buildDropdownItem('Justificada', Colors.blue.shade400, Icons.info),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    onEstadoChanged(newValue);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String label, Color color, IconData icon) {
    return DropdownMenuItem<String>(
      value: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }

  Map<String, dynamic> _getEstadoConfig(String estado) {
    switch (estado) {
      case 'Presente':
        return {'color': Colors.green.shade400, 'icon': Icons.check_circle};
      case 'Ausente':
        return {'color': Colors.red.shade400, 'icon': Icons.cancel};
      case 'Tardanza':
        return {'color': Colors.orange.shade400, 'icon': Icons.schedule};
      case 'Justificada':
        return {'color': Colors.blue.shade400, 'icon': Icons.info};
      default:
        return {'color': Colors.grey.shade400, 'icon': Icons.help};
    }
  }

  // Métodos antiguos eliminados - Ahora usamos pull-to-refresh y modal de estudiantes
}
