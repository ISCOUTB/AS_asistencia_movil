import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/custom_header.dart';
import 'utils/responsive_utils.dart';

class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 137, 99, 207);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
  static const backgroundLight = Color(0xFFF3F4F6);
}

// Datos de ejemplo para sesiones
final List<Map<String, dynamic>> sesiones = [
  {
    "centro": "Centro de Innovación",
    "servicio": "Hackathon",
    "nombreSesion": "Sesiones P2 #1",
    "fechaInicio": "04/AGO/2025",
    "horaInicio": "10:00AM",
    "horaFin": "10:20AM",
    "modalidad": "Presencial",
    "lugar": "AULA A2-204",
  },
  {
    "centro": "Centro de Apoyo Académico",
    "servicio": "Tutorías",
    "nombreSesion": "Sesión de Tutoría",
    "fechaInicio": "28/ABR/2025",
    "horaInicio": "12:00PM",
    "horaFin": "02:00PM",
    "modalidad": "Remoto",
    "lugar": "Online",
  },
];

class StudentSesionesPage extends StatefulWidget {
  const StudentSesionesPage({super.key});

  @override
  State<StudentSesionesPage> createState() => _StudentSesionesPageState();
}

class _StudentSesionesPageState extends State<StudentSesionesPage> {
  final Map<int, String> _attendance = {};

  @override
  void initState() {
    super.initState();
    _loadAttendance();
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
                      color: AppColors.universityPurple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(modalContext, 12)),
                    ),
                    child: Icon(Icons.how_to_reg, color: AppColors.universityPurple, size: iconSize),
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
    final vPadding = context.verticalPadding;
    final spacing = ResponsiveUtils.getSpacing(context, 10);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight, // Fondo claro
      body: SafeArea(
        child: Column(
          children: [
            // Header discreto para estudiantes
            const StudentHeader(title: "Sesiones"),
            
            Expanded(
              child: Container(
                color: AppColors.backgroundLight,
                child: Column(
                  children: [
                    // Botón de actualizar pequeño y discreto
                    _buildUpdateButton(context),
                    
                    // Lista de sesiones
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: hPadding),
                        itemCount: sesiones.length,
                        separatorBuilder: (context, index) => SizedBox(height: spacing),
                        itemBuilder: (context, index) {
                          final s = sesiones[index];
                          final hasAttendance = _attendance.containsKey(index);
                          final attendanceStatus = _attendance[index];
                          
                          // Determinar color según estado
                          Color statusColor = Colors.grey;
                          IconData statusIcon = Icons.help_outline;
                          
                          if (attendanceStatus == 'Presente') {
                            statusColor = Colors.green;
                            statusIcon = Icons.check_circle;
                          } else if (attendanceStatus == 'Ausente') {
                            statusColor = Colors.red;
                            statusIcon = Icons.cancel;
                          } else if (attendanceStatus == 'Inasistencia Justificada') {
                            statusColor = Colors.orange;
                            statusIcon = Icons.assignment_turned_in;
                          } else if (attendanceStatus == 'Inasistencia No Justificada') {
                            statusColor = Colors.deepOrange;
                            statusIcon = Icons.assignment_late;
                          }
                          
                          return _buildSessionCard(
                            context, 
                            s, 
                            index, 
                            hasAttendance, 
                            statusColor, 
                            statusIcon
                          );
                        },
                      ),
                    ),
                    
                    SizedBox(height: vPadding),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    final iconSize = ResponsiveUtils.getIconSize(context, 16);
    final fontSize = ResponsiveUtils.getFontSize(context, 13);
    final isLandscape = context.isLandscape;
    final hPadding = isLandscape ? 12.0 : 14.0;
    final vPadding = isLandscape ? 6.0 : 8.0;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.horizontalPadding, 
        ResponsiveUtils.getSpacing(context, 12), 
        context.horizontalPadding, 
        ResponsiveUtils.getSpacing(context, 8)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context, 20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Sesiones actualizadas'),
                      backgroundColor: AppColors.universityPurple,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context, 20)),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, size: iconSize, color: AppColors.universityPurple),
                      SizedBox(width: ResponsiveUtils.getSpacing(context, 6)),
                      Text(
                        'Actualizar',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.universityPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    Map<String, dynamic> s,
    int index,
    bool hasAttendance,
    Color statusColor,
    IconData statusIcon,
  ) {
    final cardPadding = ResponsiveUtils.getCardPadding(context);
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 14);
    final titleFontSize = ResponsiveUtils.getFontSize(context, 15);
    final subtitleFontSize = ResponsiveUtils.getFontSize(context, 12);
    final iconSize = ResponsiveUtils.getIconSize(context, 20);
    final badgeIconSize = ResponsiveUtils.getIconSize(context, 16);
    final buttonIconSize = ResponsiveUtils.getIconSize(context, 16);
    final buttonFontSize = ResponsiveUtils.getFontSize(context, 13);
    final isLandscape = context.isLandscape;
    final iconBg = isLandscape ? 6.0 : 8.0;
    final iconBorderRadius = ResponsiveUtils.getBorderRadius(context, 10);
    final spacing = ResponsiveUtils.getSpacing(context, 10);
    final badgePadding = isLandscape ? 6.0 : 8.0;
    final badgeIconPadding = isLandscape ? 3.0 : 4.0;
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
                  color: AppColors.universityPurple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(iconBorderRadius),
                ),
                child: Icon(Icons.event_note, color: AppColors.universityPurple, size: iconSize),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s['nombreSesion'] ?? '',
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
                      s['servicio'] ?? '',
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
              // Estado de asistencia inline
              if (hasAttendance)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: badgePadding, vertical: badgeIconPadding),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context, 8)),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: badgeIconSize),
                ),
            ],
          ),
          
          SizedBox(height: spacing),
          
          // Info condensada en 2 filas
          Row(
            children: [
              Expanded(
                child: _buildCompactInfo(context, Icons.calendar_today, s['fechaInicio'] ?? ''),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
              Expanded(
                child: _buildCompactInfo(context, Icons.access_time, '${s['horaInicio']} - ${s['horaFin']}'),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 6)),
          _buildCompactInfo(
            context,
            s['modalidad'] == 'Presencial' ? Icons.meeting_room : Icons.videocam,
            '${s['modalidad']} - ${s['lugar']}',
          ),
          
          SizedBox(height: spacing),
          
          // Botón de acción compacto
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAttendanceModal(context, index),
              icon: Icon(
                hasAttendance ? Icons.edit : Icons.how_to_reg,
                size: buttonIconSize,
              ),
              label: Text(
                hasAttendance ? 'Cambiar' : 'Registrar',
                style: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasAttendance ? AppColors.universityBlue : AppColors.universityPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: buttonVPadding),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(iconBorderRadius)),
                elevation: 1,
              ),
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
        Icon(icon, size: iconSize, color: AppColors.universityPurple),
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
}
