// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'utils/custom_page_route.dart';
import 'utils/responsive_utils.dart';
import 'main_scaffold.dart';
import 'widgets/modern_bottom_nav.dart';
import 'sesiones.dart' as sesiones;
import 'asistencias.dart' as asistencias;
import 'widgets/custom_header.dart';

/// Colores institucionales
class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 51, 4, 138);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
  static const backgroundLight = Color(0xFFF3F4F6);
}

/// Pantalla de inicio
class HomeScreen extends StatefulWidget {

  final String userEmail;
  final String userType;
  final int? userID;
  
  const HomeScreen({
    super.key,
    this.userEmail = '',
    this.userID=0,
    this.userType = 'estudiante',
  });

  @override
  
  State<HomeScreen> createState() => _HomeScreenState();
}

enum UserRole { professor, student }

class _HomeScreenState extends State<HomeScreen> {
  late UserRole _role;
  int? _tappedButtonIndex;

  @override
  void initState() {  
    super.initState();
    // Establecer el rol según el tipo de usuario
    _role = widget.userType == 'profesor' ? UserRole.professor : UserRole.student;
  }


  @override
  Widget build(BuildContext context) {
    final isLandscape = context.isLandscape;
    final hPadding = context.horizontalPadding;
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 24);

    return Scaffold(
      body: Column(
        children: [
          // Header unificado
          const ProfessorHeader(title: 'Inicio'),
          
          // Contenido (según rol)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius),
                  topRight: Radius.circular(borderRadius),
                ),
              ),
              // SIN PADDING para estudiantes - el padding lo manejan las páginas individuales
              child: _role == UserRole.professor
                  ? Padding(
                      padding: EdgeInsets.only(
                        left: hPadding,
                        right: hPadding,
                        top: hPadding,
                        bottom: MediaQuery.of(context).padding.bottom + hPadding + 20,
                      ),
                      child: _buildProfessorView(context, isLandscape),
                    )
                  : StudentView(
                      primaryColor: AppColors.universityBlue,
                      accentColor: AppColors.universityLightBlue,
                      userEmail: widget.userEmail,
                      userType: widget.userType,
                    ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProfessorView(BuildContext context, bool isLandscape) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isLandscape) {
          // Botones en modo horizontal (grid) con diseño compacto tipo card
          final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
          return GridView.builder(
            padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 8)),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: ResponsiveUtils.getSpacing(context, 12),
              mainAxisSpacing: ResponsiveUtils.getSpacing(context, 12),
              childAspectRatio: 1.1,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              final buttons = getButtons();
              final button = buttons[index];
              return _buildGridButton(
                context,
                button["title"] as String,
                button["color"] as Color,
                button["icon"] as IconData,
                () {
                  Navigator.push(
                    context,
                    CustomPageRoute(
                      page: button["page"] as Widget,
                    ),
                  );
                },
              );
            },
          );
        } else {
          // Botones en modo vertical (list) con diseño completo
          final buttons = getButtons();
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getSpacing(context, 8)),
            itemCount: buttons.length,
            itemBuilder: (context, index) {
              final button = buttons[index];
              return buildReactiveButton(
                context,
                button["title"] as String,
                button["color"] as Color,
                button["icon"] as IconData,
                () {
                  Navigator.push(
                    context,
                    CustomPageRoute(
                      page: button["page"] as Widget,
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  /// Botón tipo card para vista grid (horizontal)
  Widget _buildGridButton(
    BuildContext context,
    String title,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    final iconSize = ResponsiveUtils.getIconSize(context, 36);
    final fontSize = ResponsiveUtils.getFontSize(context, 15);
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 20);
    
    final isPressed = _tappedButtonIndex == title.hashCode;
    
    return AnimatedScale(
      scale: isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.white.withValues(alpha: 0.97),
              color.withValues(alpha: isPressed ? 0.1 : 0.04),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: color.withValues(alpha: isPressed ? 0.4 : 0.25),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isPressed ? 0.3 : 0.2),
              blurRadius: isPressed ? 12.0 : 20.0,
              offset: Offset(0, isPressed ? 3.0 : 6.0),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: isPressed ? 10.0 : 18.0,
              offset: Offset(0, isPressed ? 2.0 : 4.0),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() => _tappedButtonIndex = title.hashCode);
              // Navegación inmediata
              onTap();
              // Reset de animación rápido
              Future.delayed(const Duration(milliseconds: 180), () {
                if (mounted) {
                  setState(() => _tappedButtonIndex = null);
                }
              });
            },
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: color.withValues(alpha: 0.15),
            highlightColor: color.withValues(alpha: 0.1),
            child: Padding(
                padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 16)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Contenedor del ícono - SIMPLIFICADO
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      transform: isPressed 
                        ? (Matrix4.rotationZ(0.1)..scale(1.05))
                        : Matrix4.identity(),
                      width: ResponsiveUtils.getIconSize(context, 64),
                      height: ResponsiveUtils.getIconSize(context, 64),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color,
                            color.withValues(alpha: 0.85),
                            color.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context, 18)),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: isPressed ? 0.5 : 0.35),
                            blurRadius: isPressed ? 12.0 : 10.0,
                            offset: Offset(0, isPressed ? 4.0 : 3.0),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: iconSize,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.26),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),
                    
                    // Título
                    Text(
                      title,
                      style: TextStyle(
                        color: const Color(0xFF1A1A1A),
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: ResponsiveUtils.getSpacing(context, 4)),
                    
                    // Subtítulo más pequeño
                    Text(
                      _getButtonSubtitle(title),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: ResponsiveUtils.getFontSize(context, 11),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }

  /// Botón minimalista estilo Pinterest - Simple y elegante
  Widget buildReactiveButton(
    BuildContext context,
    String title,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    final iconSize = ResponsiveUtils.getIconSize(context, 28);
    final fontSize = ResponsiveUtils.getFontSize(context, 16);
    final vPadding = ResponsiveUtils.getSpacing(context, 18);
    final hPadding = ResponsiveUtils.getSpacing(context, 20);
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 16);
    final spacing = ResponsiveUtils.getSpacing(context, 14);
    final iconContainerSize = ResponsiveUtils.getIconSize(context, 50);
    
    final isPressed = _tappedButtonIndex == title.hashCode;
    
    // Animación suave y sutil
    return AnimatedScale(
      scale: isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: ResponsiveUtils.getSpacing(context, 6)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isPressed ? 0.08 : 0.05),
              blurRadius: isPressed ? 8 : 12,
              offset: Offset(0, isPressed ? 2 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() => _tappedButtonIndex = title.hashCode);
              onTap();
              Future.delayed(const Duration(milliseconds: 150), () {
                if (mounted) setState(() => _tappedButtonIndex = null);
              });
            },
            borderRadius: BorderRadius.circular(borderRadius),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
              child: Row(
                children: [
                  // Ícono minimalista
                  Container(
                    width: iconContainerSize,
                    height: iconContainerSize,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: iconSize),
                  ),
                  
                  SizedBox(width: spacing),
                  
                  // Texto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: const Color(0xFF2D3748),
                            fontWeight: FontWeight.w600,
                            fontSize: fontSize,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.getSpacing(context, 4)),
                        Text(
                          _getButtonSubtitle(title),
                          style: TextStyle(
                            color: const Color(0xFF718096),
                            fontSize: ResponsiveUtils.getFontSize(context, 12),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Flecha simple
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: const Color(0xFFCBD5E0),
                    size: ResponsiveUtils.getIconSize(context, 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Obtener subtítulo según el botón
  String _getButtonSubtitle(String title) {
    switch (title) {
      case 'Servicios':
        return 'Gestiona servicios académicos';
      case 'Sesiones':
        return 'Administra sesiones de clase';
      case 'Asistencias':
        return 'Controla asistencia estudiantil';
      case 'Dashboard':
        return 'Estadísticas y reportes';
      default:
        return 'Ver más detalles';
    }
  }

  /// Lista de botones
  List<Map<String, dynamic>> getButtons() {
    // PROFESORES ven todos los botones
    return [
      {
        "title": "Servicios",
        "color": AppColors.universityBlue,
        "icon": Icons.bookmark,
        "page": const MainScaffold(initialIndex: 0, isStudent: false),
      },
      {
        "title": "Sesiones",
        "color": AppColors.universityBlue,
        "icon": Icons.star,
        "page": const MainScaffold(initialIndex: 1, isStudent: false),
      },
      {
        "title": "Asistencias",
        "color": AppColors.universityLightBlue,
        "icon": Icons.check_circle,
        "page": const MainScaffold(initialIndex: 2, isStudent: false),
      },
      {
        "title": "Dashboard",
        "color": AppColors.universityBlue,
        "icon": Icons.bar_chart,
        "page": const MainScaffold(initialIndex: 3, isStudent: false),
      },
    ];
  }
}

/// Vista para estudiantes: lista de asistencias y barra de navegación
class StudentView extends StatefulWidget {
  final Color primaryColor;
  final Color accentColor;
  final String userEmail;
  final String userType;

  const StudentView({
    super.key,
    required this.primaryColor,
    required this.accentColor,
    this.userEmail = '',
    this.userType = 'estudiante',
  });

  @override
  State<StudentView> createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == 999) {
      // home action: volver a selector de rol
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, a1, a2) => HomeScreen(
            userEmail: widget.userEmail,
            userType: widget.userType,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
      return;
    }

    // Validar que el índice sea válido
    if (index >= 0 && index < 2) {
      setState(() {
        _selectedIndex = index;
      });
      _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PageView con páginas de estudiante: SOLO Sesiones y Asistencias
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _selectedIndex = i),
            children: [
              // 0: Sesiones
              sesiones.SesionesPageContent(),
              // 1: Asistencias
              const asistencias.AsistenciasPageContent(),
            ],
          ),
        ),

        // Reutilizar ModernBottomNav para coherencia visual
        ModernBottomNav(
          selectedIndex: _selectedIndex,
          primaryColor: widget.primaryColor,
          accentColor: widget.accentColor,
          isStudent: true, // CRUCIAL: Marcar como estudiante
          onTap: _onNavTap,
        ),
      ],
    );
  }
}
