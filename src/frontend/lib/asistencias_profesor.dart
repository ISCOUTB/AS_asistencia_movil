import 'package:flutter/material.dart';
import 'widgets/custom_header.dart';
import 'utils/responsive_utils.dart';

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
  final List<Map<String, String>> _asistencias = List.generate(10, (i) => {
        'titulo': 'Asistencia ${i + 1}',
        'materia': ['Matemáticas', 'Algoritmos', 'Redes', 'Bases'][i % 4],
        'fecha': '2025-0${(i % 9) + 1}-0${(i % 28) + 1}',
        'estado': ['Presente', 'Ausente', 'Justificada'][i % 3],
        'estudiante': 'Estudiante ${i + 1}',
      });

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
            const ProfessorHeader(title: "Asistencias - Gestión"),
            
            Expanded(
              child: Container(
                color: AppColors.backgroundLight,
                child: Column(
                  children: [
                    SizedBox(height: vPadding),
                    
                    // Botón actualizar responsive
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPadding),
                      child: _buildUpdateButton(context),
                    ),
                    
                    SizedBox(height: vPadding),
                    
                    // Lista de asistencias responsive
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: hPadding),
                        itemCount: _asistencias.length,
                        separatorBuilder: (context, index) => SizedBox(height: spacing),
                        itemBuilder: (context, index) {
                          final asistencia = _asistencias[index];
                          return _buildAsistenciaCard(context, asistencia);
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
    final iconSize = ResponsiveUtils.getIconSize(context, 24);
    final fontSize = ResponsiveUtils.getFontSize(context, 16);
    final isLandscape = context.isLandscape;
    
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Asistencias actualizadas'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.universityLightBlue,
          ),
        );
      },
      icon: Icon(Icons.refresh, size: iconSize),
      label: Text(
        'Actualizar Lista',
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.universityLightBlue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: isLandscape ? 14 : 16,
          horizontal: isLandscape ? 20 : 24,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 3,
        shadowColor: AppColors.universityLightBlue.withValues(alpha: 0.4),
        minimumSize: const Size(double.infinity, 0),
      ),
    );
  }

  Widget _buildAsistenciaCard(BuildContext context, Map<String, String> asistencia) {
    final Color statusColor = asistencia['estado'] == 'Presente'
        ? Colors.green
        : asistencia['estado'] == 'Ausente'
            ? Colors.red
            : Colors.orange;

    final padding = ResponsiveUtils.getCardPadding(context);
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 16);
    final titleSize = ResponsiveUtils.getFontSize(context, 18);
    final badgeSize = ResponsiveUtils.getFontSize(context, 12);
    final textSize = ResponsiveUtils.getFontSize(context, 14);
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
                  asistencia['titulo'] ?? '',
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
                  asistencia['estado'] ?? '',
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
          _buildInfoRow(context, Icons.person, 'Estudiante', asistencia['estudiante'] ?? '', textSize),
          SizedBox(height: spacing),
          _buildInfoRow(context, Icons.book, 'Materia', asistencia['materia'] ?? '', textSize),
          SizedBox(height: spacing),
          _buildInfoRow(context, Icons.calendar_today, 'Fecha', asistencia['fecha'] ?? '', textSize),
        ],
      ),
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
