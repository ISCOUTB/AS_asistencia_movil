import 'package:flutter/material.dart';
import 'widgets/custom_header.dart';
import 'utils/responsive_utils.dart';
import 'api/routes/sesion_service.dart';
import 'crear_sesion.dart';

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
  late SesionService sesionService;
  List<dynamic> sesiones = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    const baseUrl = 'https://ga7a0b6c9043600-atpdb.adb.us-phoenix-1.oraclecloudapps.com/ords/ecoutb_workspace/sesiones/';
    sesionService = SesionService(baseUrl);
    _cargarSesiones();
  }

  Future<void> _cargarSesiones() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await sesionService.getSesiones();
      setState(() {
        sesiones = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar sesiones: $e';
        isLoading = false;
      });
      print('Error cargando sesiones: $e');
    }
  }

  void _navegarCrearSesion(BuildContext context) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CrearSesionPage(),
      ),
    );

    // Si se creó una sesión, recargar la lista
    if (resultado == true) {
      _cargarSesiones();
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
            // Header profesor
            const ProfessorHeader(
              title: "Sesiones",
            ),

            // Lista de sesiones desde el backend
            Expanded(
              child: Container(
                color: AppColors.backgroundLight,
                margin: const EdgeInsets.only(bottom: 0),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.universityBlue),
                      )
                    : errorMessage != null
                        ? _buildErrorView(context)
                        : sesiones.isEmpty
                            ? _buildEmptyView(context)
                            : RefreshIndicator(
                                onRefresh: _cargarSesiones,
                                child: ListView.builder(
                                  padding: EdgeInsets.only(
                                    left: hPadding,
                                    right: hPadding,
                                    top: hPadding,
                                    bottom: MediaQuery.of(context).padding.bottom + 80, // Espacio para botones de navegación
                                  ),
                                  itemCount: sesiones.length,
                                  itemBuilder: (context, index) {
                                    final sesion = sesiones[index];
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: cardSpacing),
                                      child: _buildSesionCard(context, sesion),
                                    );
                                  },
                                ),
                              ),
              ),
            ),
          ],
        ),
      ),
      // Botón flotante para crear sesión
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navegarCrearSesion(context),
        backgroundColor: AppColors.universityBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Crear Sesión',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    final iconSize = ResponsiveUtils.getIconSize(context, 60);
    final fontSize = ResponsiveUtils.getFontSize(context, 14);
    final buttonFontSize = ResponsiveUtils.getFontSize(context, 16);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: iconSize, color: Colors.red),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding * 2),
            child: Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: fontSize),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
          ElevatedButton(
            onPressed: _cargarSesiones,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.universityBlue,
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getSpacing(context, 24),
                vertical: ResponsiveUtils.getSpacing(context, 12),
              ),
            ),
            child: Text('Reintentar', style: TextStyle(fontSize: buttonFontSize)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    final fontSize = ResponsiveUtils.getFontSize(context, 16);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay sesiones disponibles',
            style: TextStyle(fontSize: fontSize, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera sesión presionando el botón inferior',
            style: TextStyle(fontSize: fontSize - 2, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSesionCard(BuildContext context, Map<String, dynamic> sesion) {
    final cardPadding = ResponsiveUtils.getCardPadding(context);
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 20);
    final iconSize = ResponsiveUtils.getIconSize(context, 24);
    final titleFontSize = ResponsiveUtils.getFontSize(context, 17);
    final subtitleFontSize = ResponsiveUtils.getFontSize(context, 13);
    final detailFontSize = ResponsiveUtils.getFontSize(context, 12);

    // Determinar el icono y color según la modalidad
    IconData modalidadIcon;
    Color modalidadColor;
    String modalidadTexto;
    final modalidad = sesion['id_modalidad'];
    if (modalidad == 1) {
      modalidadIcon = Icons.location_on;
      modalidadColor = const Color(0xFF10B981); // Verde
      modalidadTexto = 'Presencial';
    } else if (modalidad == 2) {
      modalidadIcon = Icons.computer;
      modalidadColor = AppColors.universityBlue;
      modalidadTexto = 'Virtual';
    } else {
      modalidadIcon = Icons.language;
      modalidadColor = const Color(0xFFF59E0B); // Naranja
      modalidadTexto = 'Híbrida';
    }

    // Formatear fecha y hora
    String fecha = sesion['fecha']?.toString().substring(0, 10) ?? 'Sin fecha';
    String horaInicio = sesion['hora_inicio_sesion'] ?? '';
    String horaFin = sesion['hora_fin']?.toString().substring(11, 16) ?? '';
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.universityBlue.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: () => _mostrarDetalleSesion(context, sesion),
          child: Padding(
            padding: cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con nombre y badge de modalidad
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icono de sesión
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.universityBlue,
                            AppColors.universityBlue.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.universityBlue.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.school,
                        color: Colors.white,
                        size: iconSize,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Nombre de la sesión
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sesion['nombre_sesion']?.toString() ?? 'Sin nombre',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: titleFontSize,
                              color: const Color(0xFF1A202C),
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Badge de modalidad
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: modalidadColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: modalidadColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  modalidadIcon,
                                  size: 14,
                                  color: modalidadColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  modalidadTexto,
                                  style: TextStyle(
                                    color: modalidadColor,
                                    fontSize: detailFontSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Icono de flecha
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Información de fecha, hora y lugar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Fecha
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppColors.universityBlue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            fecha,
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: const Color(0xFF4A5568),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          // Hora
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppColors.universityBlue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$horaInicio - $horaFin',
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: const Color(0xFF4A5568),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Lugar
                      Row(
                        children: [
                          Icon(
                            Icons.place,
                            size: 16,
                            color: AppColors.universityBlue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              sesion['lugar_sesion']?.toString() ?? 'Sin lugar',
                              style: TextStyle(
                                fontSize: subtitleFontSize,
                                color: const Color(0xFF4A5568),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDetalleSesion(BuildContext context, Map<String, dynamic> sesion) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final borderRadius = ResponsiveUtils.getBorderRadius(dialogContext, 20);
        final headerPadding = ResponsiveUtils.getCardPadding(dialogContext);
        final contentPadding = ResponsiveUtils.getCardPadding(dialogContext);
        final iconSize = ResponsiveUtils.getIconSize(dialogContext, 28);
        final titleFontSize = ResponsiveUtils.getFontSize(dialogContext, 20);
        final buttonFontSize = ResponsiveUtils.getFontSize(dialogContext, 16);
        final spacing = ResponsiveUtils.getSpacing(dialogContext, 16);
        final iconBg = dialogContext.isLandscape ? 10.0 : 12.0;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Color(0xFFF8F9FA),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header con gradiente
                  Container(
                    padding: headerPadding,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.universityBlue,
                          AppColors.universityBlue,
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(borderRadius),
                        topRight: Radius.circular(borderRadius),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(iconBg),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(dialogContext, 12)),
                          ),
                          child: Icon(
                            Icons.star,
                            color: Colors.white,
                            size: iconSize,
                          ),
                        ),
                        SizedBox(width: spacing),
                        Expanded(
                          child: Text(
                            sesion['nombre_sesion']?.toString() ?? 'Sin nombre',
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Contenido
                  Padding(
                    padding: contentPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (sesion['descripcion'] != null && sesion['descripcion'].toString().isNotEmpty)
                          _buildInfoSection(
                            dialogContext,
                            icon: Icons.description,
                            title: 'Descripción',
                            content: sesion['descripcion'].toString(),
                            color: AppColors.universityBlue,
                          ),
                        if (sesion['descripcion'] != null && sesion['descripcion'].toString().isNotEmpty)
                          SizedBox(height: spacing),

                        if (sesion['lugar_sesion'] != null)
                          _buildInfoSection(
                            dialogContext,
                            icon: Icons.place,
                            title: 'Lugar',
                            content: sesion['lugar_sesion'].toString(),
                            color: AppColors.universityBlue,
                          ),
                        if (sesion['lugar_sesion'] != null)
                          SizedBox(height: spacing),

                        if (sesion['fecha'] != null)
                          _buildInfoSection(
                            dialogContext,
                            icon: Icons.calendar_today,
                            title: 'Fecha',
                            content: sesion['fecha'].toString().substring(0, 10),
                            color: AppColors.universityLightBlue,
                          ),
                        if (sesion['fecha'] != null)
                          SizedBox(height: spacing),

                        _buildAdditionalInfo(dialogContext, sesion),
                      ],
                    ),
                  ),

                  // Botones de acción
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      contentPadding.left,
                      0,
                      contentPadding.right,
                      contentPadding.bottom,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(
                            'Cerrar',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: buttonFontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    final padding = ResponsiveUtils.getCardPadding(context);
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 12);
    final iconBorderRadius = ResponsiveUtils.getBorderRadius(context, 8);
    final iconSize = ResponsiveUtils.getIconSize(context, 20);
    final titleFontSize = ResponsiveUtils.getFontSize(context, 14);
    final contentFontSize = ResponsiveUtils.getFontSize(context, 14);
    final iconPadding = context.isLandscape ? 6.0 : 8.0;
    final spacing = ResponsiveUtils.getSpacing(context, 12);
    final vSpacing = ResponsiveUtils.getSpacing(context, 4);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(iconPadding),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(iconBorderRadius),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: iconSize,
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize,
                    color: color,
                  ),
                ),
                SizedBox(height: vSpacing),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: contentFontSize,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo(BuildContext context, Map<String, dynamic> sesion) {
    final fontSize = ResponsiveUtils.getFontSize(context, 14);
    final iconSize = ResponsiveUtils.getIconSize(context, 20);
    final padding = ResponsiveUtils.getCardPadding(context);
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 12);
    final spacing = ResponsiveUtils.getSpacing(context, 8);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.people, color: Colors.grey, size: iconSize),
              SizedBox(width: spacing),
              Text(
                'Máximo: ',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: fontSize),
              ),
              Text(
                '${sesion['n_maximo_asistentes'] ?? 'N/A'} asistentes',
                style: TextStyle(fontSize: fontSize),
              ),
            ],
          ),
          SizedBox(height: spacing),
          Row(
            children: [
              Icon(
                sesion['gestiona_asis'] == 'S' ? Icons.check_circle : Icons.cancel,
                color: sesion['gestiona_asis'] == 'S' ? Colors.green : Colors.red,
                size: iconSize,
              ),
              SizedBox(width: spacing),
              Text(
                'Gestiona asistencia: ',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: fontSize),
              ),
              Text(
                sesion['gestiona_asis'] == 'S' ? 'Sí' : 'No',
                style: TextStyle(fontSize: fontSize),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
