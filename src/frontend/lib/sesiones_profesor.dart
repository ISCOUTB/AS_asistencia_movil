import 'package:flutter/material.dart';
import 'widgets/custom_header.dart';
import 'utils/responsive_utils.dart';

class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 137, 99, 207);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
  static const backgroundLight = Color(0xFFF3F4F6);
}

class TeacherSesionesPage extends StatefulWidget {
  const TeacherSesionesPage({super.key});

  @override
  State<TeacherSesionesPage> createState() => _TeacherSesionesPageState();
}

class _TeacherSesionesPageState extends State<TeacherSesionesPage> {
  final List<Map<String, dynamic>> _sesiones = List.generate(8, (i) => {
        'codigo': 'SES-${1000 + i}',
        'titulo': 'Sesión ${i + 1}',
        'fecha': '2025-0${(i % 9) + 1}-0${(i % 28) + 1}',
        'hora': '${8 + i % 5}:00 - ${9 + i % 5}:00',
        'salon': 'Sala ${101 + i}',
        'estado': ['Activa', 'Pendiente', 'Completada'][i % 3],
        'estudiantes': List.generate(5, (j) => {
          'codigo': 'EST-${2000 + j}',
          'nombre': 'Estudiante ${j + 1}',
          'asistencia': ['Presente', 'Ausente', 'Tardanza'][j % 3],
        }),
      });

  void _showStudentsList(BuildContext context, Map<String, dynamic> sesion) {
    final isLandscape = ResponsiveUtils.isLandscape(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext modalContext) => DraggableScrollableSheet(
        initialChildSize: isLandscape ? 0.85 : 0.7,
        minChildSize: isLandscape ? 0.7 : 0.5,
        maxChildSize: 0.95,
        builder: (BuildContext sheetContext, ScrollController scrollController) {
          final hPadding = ResponsiveUtils.getHorizontalPadding(modalContext);
          final titleSize = ResponsiveUtils.getFontSize(modalContext, 18);
          final subtitleSize = ResponsiveUtils.getFontSize(modalContext, 14);
          final nameSize = ResponsiveUtils.getFontSize(modalContext, 16);
          final codeSize = ResponsiveUtils.getFontSize(modalContext, 13);
          final badgeSize = ResponsiveUtils.getFontSize(modalContext, 13);
          final iconSize = ResponsiveUtils.getIconSize(modalContext, 24);
          final avatarSize = isLandscape ? 45.0 : 50.0;
          final spacing = ResponsiveUtils.getSpacing(modalContext, 10);
          
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle visual
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Título responsive
                Padding(
                  padding: EdgeInsets.all(hPadding),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isLandscape ? 8 : 10),
                        decoration: BoxDecoration(
                          color: AppColors.universityPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.people, color: AppColors.universityPurple, size: iconSize),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sesion['titulo'] ?? '',
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            Text(
                              'Lista de estudiantes',
                              style: TextStyle(
                                fontSize: subtitleSize,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(modalContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                
                // Lista de estudiantes responsive
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: spacing),
                    itemCount: (sesion['estudiantes'] as List).length,
                    separatorBuilder: (context, index) => SizedBox(height: spacing),
                    itemBuilder: (context, index) {
                      final estudiante = (sesion['estudiantes'] as List)[index];
                      final asistencia = estudiante['asistencia'] as String;
                      final codigo = estudiante['codigo'] ?? 'N/A';
                      final color = asistencia == 'Presente' 
                          ? Colors.green 
                          : asistencia == 'Ausente' 
                              ? Colors.red 
                              : Colors.orange;
                      
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isLandscape ? 10 : 14),
                          child: Row(
                            children: [
                              // Avatar responsive
                              Container(
                                width: avatarSize,
                                height: avatarSize,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      color.withValues(alpha: 0.2),
                                      color.withValues(alpha: 0.4),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
                                ),
                                child: Icon(
                                  asistencia == 'Presente' 
                                      ? Icons.check_circle 
                                      : asistencia == 'Ausente'
                                          ? Icons.cancel
                                          : Icons.access_time,
                                  color: color,
                                  size: avatarSize * 0.5,
                                ),
                              ),
                              
                              SizedBox(width: isLandscape ? 10 : 14),
                              
                              // Información responsive
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      estudiante['nombre'] ?? '',
                                      style: TextStyle(
                                        fontSize: nameSize,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1A1A1A),
                                        height: 1.2,
                                      ),
                                    ),
                                    SizedBox(height: isLandscape ? 2 : 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.badge,
                                          size: codeSize,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          codigo,
                                          style: TextStyle(
                                            fontSize: codeSize,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Badge responsive
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isLandscape ? 10 : 14,
                                  vertical: isLandscape ? 6 : 8,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: color, width: 1.5),
                                ),
                                child: Text(
                                  asistencia,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: badgeSize,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPadding = context.horizontalPadding;
    final vPadding = context.verticalPadding;
    final spacing = ResponsiveUtils.getSpacing(context, 12);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            const ProfessorHeader(title: "Sesiones - Gestión Completa"),
            
            Expanded(
              child: Container(
                color: AppColors.backgroundLight,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: vPadding),
                      
                      // Botones de acción responsive
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPadding),
                        child: _buildActionButtons(context),
                      ),
                      
                      SizedBox(height: vPadding),
                      
                      // Lista de sesiones responsive
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: hPadding),
                        itemCount: _sesiones.length,
                        separatorBuilder: (context, index) => SizedBox(height: spacing),
                        itemBuilder: (context, index) {
                          final sesion = _sesiones[index];
                          return _buildSessionCard(context, sesion);
                        },
                      ),
                      
                      SizedBox(height: ResponsiveUtils.getBottomNavHeight(context) + 10),
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

  Widget _buildActionButtons(BuildContext context) {
    final isLandscape = context.isLandscape;
    final buttonHeight = isLandscape ? 48.0 : 56.0;
    final fontSize = ResponsiveUtils.getFontSize(context, 16);
    final iconSize = ResponsiveUtils.getIconSize(context, 24);
    
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.add_circle, size: iconSize),
            label: Text(
              'Nueva Sesión',
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.universityPurple,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: buttonHeight * 0.28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 3,
              shadowColor: AppColors.universityPurple.withValues(alpha: 0.4),
            ),
          ),
        ),
        SizedBox(width: ResponsiveUtils.getSpacing(context, 12)),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Sesiones actualizadas'),
                  backgroundColor: AppColors.universityLightBlue,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.universityLightBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: buttonHeight * 0.28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
            ),
            child: Icon(Icons.refresh, size: iconSize),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(BuildContext context, Map<String, dynamic> sesion) {
    final Color statusColor = sesion['estado'] == 'Activa'
        ? Colors.green
        : sesion['estado'] == 'Pendiente'
            ? Colors.orange
            : Colors.grey;

    final padding = ResponsiveUtils.getCardPadding(context);
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 16);
    final titleSize = ResponsiveUtils.getFontSize(context, 18);
    final textSize = ResponsiveUtils.getFontSize(context, 14);
    final badgeSize = ResponsiveUtils.getFontSize(context, 12);
    final spacing = ResponsiveUtils.getSpacing(context, 8);
    
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  sesion['titulo'] ?? '',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.isLandscape ? 10 : 12,
                  vertical: context.isLandscape ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor, width: 1.5),
                ),
                child: Text(
                  sesion['estado'] ?? '',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: badgeSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing * 1.5),
          _buildInfoRow(context, Icons.code, 'Código', sesion['codigo'] ?? '', textSize),
          SizedBox(height: spacing),
          _buildInfoRow(context, Icons.calendar_today, 'Fecha', sesion['fecha'] ?? '', textSize),
          SizedBox(height: spacing),
          _buildInfoRow(context, Icons.access_time, 'Hora', sesion['hora'] ?? '', textSize),
          SizedBox(height: spacing),
          _buildInfoRow(context, Icons.room, 'Salón', sesion['salon'] ?? '', textSize),
          SizedBox(height: spacing * 2),
          
          // Botones de acción por sesión - responsive
          _buildSessionActions(context, sesion),
        ],
      ),
    );
  }

  Widget _buildSessionActions(BuildContext context, Map<String, dynamic> sesion) {
    final isLandscape = context.isLandscape;
    final iconSize = ResponsiveUtils.getIconSize(context, 18);
    final fontSize = ResponsiveUtils.getFontSize(context, 13);
    final spacing = ResponsiveUtils.getSpacing(context, 8);
    
    return Row(
      children: [
        // Botón Ver Estudiantes
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showStudentsList(context, sesion),
            icon: Icon(Icons.people, size: iconSize),
            label: Text('Estudiantes', style: TextStyle(fontSize: fontSize)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.universityPurple,
              side: BorderSide(color: AppColors.universityPurple.withValues(alpha: 0.5)),
              padding: EdgeInsets.symmetric(vertical: isLandscape ? 8 : 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        SizedBox(width: spacing),
        // Botón Editar
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Editando: ${sesion['titulo']}'),
                  backgroundColor: AppColors.universityBlue,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            icon: Icon(Icons.edit, size: iconSize),
            label: Text('Editar', style: TextStyle(fontSize: fontSize)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.universityBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: isLandscape ? 8 : 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 1,
            ),
          ),
        ),
        SizedBox(width: spacing),
        // Botón Eliminar
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Eliminar Sesión'),
                content: Text('¿Estás seguro de eliminar "${sesion['titulo']}"?'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sesión eliminada'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: EdgeInsets.all(isLandscape ? 8 : 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 1,
            minimumSize: Size(isLandscape ? 44 : 48, isLandscape ? 34 : 38),
          ),
          child: Icon(Icons.delete, size: iconSize),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, double textSize) {
    final iconSize = ResponsiveUtils.getIconSize(context, 16);
    
    return Row(
      children: [
        Icon(icon, size: iconSize, color: AppColors.universityPurple),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: textSize,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: textSize,
              color: const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
