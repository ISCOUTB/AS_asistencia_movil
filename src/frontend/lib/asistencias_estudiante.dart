import 'package:flutter/material.dart';
import 'widgets/custom_header.dart';
import 'utils/responsive_utils.dart';

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
  final List<Map<String, String>> _asistencias = List.generate(10, (i) => {
        'titulo': 'Asistencia ${i + 1}',
        'materia': ['Matemáticas', 'Algoritmos', 'Redes', 'Bases'][i % 4],
        'fecha': '2025-0${(i % 9) + 1}-0${(i % 28) + 1}',
        'estado': ['Presente', 'Ausente', 'Justificada'][i % 3],
      });

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
            const StudentHeader(title: "Asistencias"),
            
            Expanded(
              child: Container(
                color: AppColors.backgroundLight,
                child: Column(
                  children: [
                    // Botón de actualizar pequeño y discreto
                    _buildUpdateButton(context),
                    
                    // Lista de asistencias con scroll
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
                    
                    SizedBox(height: context.verticalPadding),
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
                      content: const Text('Asistencias actualizadas'),
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

  Widget _buildAsistenciaCard(BuildContext context, Map<String, String> asistencia) {
    final Color statusColor = asistencia['estado'] == 'Presente'
        ? Colors.green
        : asistencia['estado'] == 'Ausente'
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
              asistencia['estado'] == 'Presente' ? Icons.check_circle : 
              asistencia['estado'] == 'Ausente' ? Icons.cancel : Icons.access_time,
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
                  asistencia['titulo'] ?? '',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 4)),
                Row(
                  children: [
                    Icon(Icons.book, size: infoIconSize, color: Colors.grey.shade600),
                    SizedBox(width: ResponsiveUtils.getSpacing(context, 4)),
                    Text(
                      asistencia['materia'] ?? '',
                      style: TextStyle(
                        fontSize: infoFontSize,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
                    Icon(Icons.calendar_today, size: infoIconSize, color: Colors.grey.shade600),
                    SizedBox(width: ResponsiveUtils.getSpacing(context, 4)),
                    Text(
                      asistencia['fecha'] ?? '',
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
              asistencia['estado'] ?? '',
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
