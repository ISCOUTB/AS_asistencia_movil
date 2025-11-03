import 'package:flutter/material.dart';
import 'widgets/custom_header.dart';
import 'utils/responsive_utils.dart';
import 'api/routes/asistencia_service.dart';

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
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      child: InkWell(
        onTap: () => _mostrarModalEstudiantes(context, sesion),
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de la sesión
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.universityBlue, AppColors.universityBlue],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.school, color: Colors.white, size: iconSize),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sesion['nombreSesion'],
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sesion['servicio'],
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: const Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              // Info de fecha y hora
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    sesion['fecha'],
                    style: TextStyle(fontSize: subtitleFontSize, color: Colors.grey.shade700),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    '${sesion['horaInicio']} - ${sesion['horaFin']}',
                    style: TextStyle(fontSize: subtitleFontSize, color: Colors.grey.shade700),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Estadísticas de asistencia
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatChip('Total', totalEstudiantes, Colors.blue.shade400, Icons.people),
                  _buildStatChip('Presentes', presentes, Colors.green.shade400, Icons.check_circle),
                  _buildStatChip('Ausentes', ausentes, Colors.red.shade400, Icons.cancel),
                  _buildStatChip('Tardanzas', tardanzas, Colors.orange.shade400, Icons.schedule),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 2),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade700,
            ),
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
