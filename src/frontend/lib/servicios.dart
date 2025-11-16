import 'package:flutter/material.dart';
import 'sesiones.dart';
import 'asistencias.dart';
import 'dashboard.dart';
import 'api/routes/servicio_service.dart';
import 'main_scaffold.dart';
import 'widgets/custom_header.dart';
import 'utils/responsive_utils.dart';
// import 'crear_servicio.dart'; - Eliminado: Los profesores no crean servicios

class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 137, 99, 207);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
  static const backgroundLight = Color(0xFFF3F4F6);
}

// Clase original para navegación directa (mantener para compatibilidad)
class ServiciosPage extends StatefulWidget {
  const ServiciosPage({super.key});

  @override
  State<ServiciosPage> createState() => _ServiciosPageState();
}

class _ServiciosPageState extends State<ServiciosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const ServiciosPageContent(),
      bottomNavigationBar: _buildModernBottomNavBar(context),
    );
  }

  Widget _buildModernBottomNavBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 10,
        top: 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
            ],
          ),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.bookmark_border, "Servicios", 0, 0, context),
            _buildNavItem(Icons.star_border, "Sesiones", 1, 0, context),
            _buildFloatingHomeButton(context),
            _buildNavItem(Icons.check_circle_outline, "Asistencias", 2, 0, context),
            _buildNavItem(Icons.bar_chart_outlined, "Dashboard", 3, 0, context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, int currentIndex, BuildContext context) {
    bool isSelected = index == currentIndex;
    return GestureDetector(
      onTap: () => _navigateWithAnimation(context, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(
          vertical: isSelected ? 12 : 8,
          horizontal: isSelected ? 16 : 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              transform: Matrix4.identity()..scale(isSelected ? 1.2 : 1.0),
              child: Icon(
                isSelected ? _getSelectedIcon(icon) : icon,
                color: Colors.white,
                size: isSelected ? 26 : 22,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSelected ? 11 : 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSelectedIcon(IconData originalIcon) {
    switch (originalIcon) {
      case Icons.bookmark_border:
        return Icons.bookmark;
      case Icons.star_border:
        return Icons.star;
      case Icons.check_circle_outline:
        return Icons.check_circle;
      case Icons.bar_chart_outlined:
        return Icons.bar_chart;
      default:
        return originalIcon;
    }
  }

  Widget _buildFloatingHomeButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToHome(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.home,
          color: Color(0xFF667EEA),
          size: 26,
        ),
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    // Volver al inicio preservando el historial
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _navigateWithAnimation(BuildContext context, int index) {
    Widget destination;
    switch (index) {
      case 0:
        return; // Ya estamos en Servicios
      case 1:
        destination = SesionesPage();
        break;
      case 2:
        destination = const AsistenciasPage();
        break;
      case 3:
        destination = const DashboardPage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

// Nuevo widget solo con contenido para usar en MainScaffold
class ServiciosPageContent extends StatefulWidget {
  const ServiciosPageContent({super.key});

  @override
  State<ServiciosPageContent> createState() => _ServiciosPageContentState();
}

class _ServiciosPageContentState extends State<ServiciosPageContent> {
  late ServicioService servicioService;
  List<dynamic> servicios = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Usar URL directa del backend Oracle ORDS
    const baseUrl = 'https://ga7a0b6c9043600-atpdb.adb.us-phoenix-1.oraclecloudapps.com/ords/ecoutb_workspace/servicios/';
    servicioService = ServicioService(baseUrl);
    _cargarServicios();
  }

  Future<void> _cargarServicios() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await servicioService.getServicios();
      setState(() {
        servicios = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar servicios: $e';
        isLoading = false;
      });
      print('Error cargando servicios: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPadding = context.horizontalPadding;
    final cardSpacing = ResponsiveUtils.getSpacing(context, 12);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight, // Fondo claro
      body: SafeArea(
        child: Column(
          children: [
            // Header profesor
            const ProfessorHeader(
              title: "Servicios de la Universidad Tecnológica de Bolívar",
            ),

            // Lista de servicios desde el backend
            Expanded(
              child: Container(
                color: AppColors.backgroundLight, // Mismo color que el fondo
                margin: const EdgeInsets.only(bottom: 0),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.universityBlue),
                      )
                  : errorMessage != null
                      ? _buildErrorView(context)
                      : servicios.isEmpty
                          ? _buildEmptyView(context)
                          : RefreshIndicator(
                              onRefresh: _cargarServicios,
                              child: ListView.builder(
                                padding: EdgeInsets.only(
                                  left: hPadding,
                                  right: hPadding,
                                  top: hPadding,
                                  bottom: MediaQuery.of(context).padding.bottom + 20, // Espacio para botones de navegación
                                ),
                                itemCount: servicios.length,
                                itemBuilder: (context, index) {
                                  final servicio = servicios[index];
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: cardSpacing),
                                    child: _buildServiceCard(context, servicio),
                                  );
                                },
                              ),
                            ),
              ),
            ),
          ],
        ),
      ),
      // Botón de crear servicio eliminado - Solo administradores pueden crear servicios
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
            onPressed: _cargarServicios,
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
      child: Text(
        'No hay servicios disponibles',
        style: TextStyle(fontSize: fontSize, color: Colors.grey),
      ),
    );
  }

  // Método eliminado - Los profesores no pueden crear servicios

  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> servicio) {
    final cardPadding = ResponsiveUtils.getCardPadding(context);
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 16);
    final iconSize = ResponsiveUtils.getIconSize(context, 28);
    final iconContainerSize = context.isLandscape ? 45.0 : 50.0;
    final iconBorderRadius = ResponsiveUtils.getBorderRadius(context, 12);
    final titleFontSize = ResponsiveUtils.getFontSize(context, 16);
    final chevronSize = ResponsiveUtils.getIconSize(context, 28);
    final spacing = ResponsiveUtils.getSpacing(context, 16);
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: () => _mostrarDetalleServicio(context, servicio),
        child: Padding(
          padding: cardPadding,
          child: Row(
            children: [
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.universityBlue,
                      AppColors.universityBlue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(iconBorderRadius),
                ),
                child: Icon(
                  Icons.bookmark,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: Text(
                  servicio['nombre_servicio'] ?? 'Sin nombre',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: chevronSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalleServicio(BuildContext context, Map<String, dynamic> servicio) {
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
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(dialogContext, 12)),
                          ),
                          child: Icon(
                            Icons.bookmark,
                            color: Colors.white,
                            size: iconSize,
                          ),
                        ),
                        SizedBox(width: spacing),
                        Expanded(
                          child: Text(
                            servicio['nombre_servicio'] ?? 'Sin nombre',
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
                        // Descripción - solo mostrar si existe
                        if (servicio['descripcion'] != null && servicio['descripcion'].toString().isNotEmpty)
                          _buildInfoSection(
                            dialogContext,
                            icon: Icons.description,
                            title: 'Descripción',
                            content: servicio['descripcion'].toString(),
                            color: AppColors.universityBlue,
                          ),
                        if (servicio['descripcion'] != null && servicio['descripcion'].toString().isNotEmpty)
                          SizedBox(height: spacing),

                        // Materia - solo mostrar si existe
                        if (servicio['materia'] != null && servicio['materia'].toString().isNotEmpty)
                          _buildInfoSection(
                            dialogContext,
                            icon: Icons.book,
                            title: 'Materia',
                            content: servicio['materia'].toString(),
                            color: AppColors.universityBlue,
                          ),
                        if (servicio['materia'] != null && servicio['materia'].toString().isNotEmpty)
                          SizedBox(height: spacing),

                        // Periodo - solo mostrar si existe
                        if (servicio['periodo'] != null && servicio['periodo'].toString().isNotEmpty)
                          _buildInfoSection(
                            dialogContext,
                            icon: Icons.calendar_today,
                            title: 'Periodo',
                            content: servicio['periodo'].toString(),
                            color: AppColors.universityLightBlue,
                          ),
                        if (servicio['periodo'] != null && servicio['periodo'].toString().isNotEmpty)
                          SizedBox(height: spacing),

                        // Información adicional
                        _buildAdditionalInfo(dialogContext, servicio),
                      ],
                    ),
                  ),

                  // Botones de acción
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      contentPadding.left, 
                      0, 
                      contentPadding.right, 
                      contentPadding.bottom
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

  Widget _buildAdditionalInfo(BuildContext context, Map<String, dynamic> servicio) {
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
              Icon(
                servicio['permite_externos'] == 'S'
                    ? Icons.check_circle
                    : Icons.cancel,
                color: servicio['permite_externos'] == 'S'
                    ? Colors.green
                    : Colors.red,
                size: iconSize,
              ),
              SizedBox(width: spacing),
              Text(
                'Permite externos: ',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: fontSize),
              ),
              Text(
                servicio['permite_externos'] == 'S' ? 'Sí' : 'No',
                style: TextStyle(fontSize: fontSize),
              ),
            ],
          ),
          SizedBox(height: spacing),
          Row(
            children: [
              Icon(
                servicio['acumula_asistencia'] == 'S'
                    ? Icons.check_circle
                    : Icons.cancel,
                color: servicio['acumula_asistencia'] == 'S'
                    ? Colors.green
                    : Colors.red,
                size: iconSize,
              ),
              SizedBox(width: spacing),
              Text(
                'Acumula asistencia: ',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: fontSize),
              ),
              Text(
                servicio['acumula_asistencia'] == 'S' ? 'Sí' : 'No',
                style: TextStyle(fontSize: fontSize),
              ),
            ],
          ),
          if (servicio['fecha_creacion'] != null) ...[
            SizedBox(height: spacing),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.grey,
                  size: iconSize,
                ),
                SizedBox(width: spacing),
                Text(
                  'Fecha de creación: ',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: fontSize),
                ),
                Expanded(
                  child: Text(
                    servicio['fecha_creacion'].toString(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: fontSize),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
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
}

void navegarAMainScaffold(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const MainScaffold(initialIndex: 0), // 0=Servicios, 1=Sesiones, 2=Asistencias, 3=Dashboard
    ),
  );
}
