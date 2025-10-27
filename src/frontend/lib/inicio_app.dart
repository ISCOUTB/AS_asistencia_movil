// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'utils/custom_page_route.dart';
import 'utils/responsive_utils.dart';
import 'main_scaffold.dart';
import 'widgets/modern_bottom_nav.dart';
import 'api/services/user_session.dart';
import 'main.dart';
import 'sesiones.dart' as sesiones;
import 'asistencias.dart' as asistencias;

/// Colores institucionales
class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 137, 99, 207);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
  static const backgroundLight = Color(0xFFF3F4F6);
}

/// Página principal de la app
class InicioApp extends StatelessWidget {
  final String userEmail;
  final String userType;
  
  const InicioApp({
    super.key,
    required this.userEmail,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTB Assists',
      theme: ThemeData(
        primaryColor: AppColors.universityBlue,
        useMaterial3: true,
      ),
      home: HomeScreen(userEmail: userEmail, userType: userType),
    );
  }
}

/// Pantalla de inicio
class HomeScreen extends StatefulWidget {
  final String userEmail;
  final String userType;
  
  const HomeScreen({
    super.key,
    this.userEmail = '',
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

  void _setRole(UserRole role) {
    setState(() {
      _role = role;
    });
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings, color: AppColors.universityBlue),
            SizedBox(width: 8),
            Text('Ajustes'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Deseas cerrar sesión?'),
            const SizedBox(height: 8),
            Text(
              'Correo: ${widget.userEmail}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar Sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    // Importar el servicio de sesión
    final navigator = Navigator.of(context);
    
    // Cerrar sesión
    await UserSession.logout();
    
    // Cerrar el diálogo
    navigator.pop();
    
    // Navegar al login
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = context.isLandscape;
    final logoHeight = ResponsiveUtils.getIconSize(context, 60);
    final hPadding = context.horizontalPadding;
    final vPadding = context.verticalPadding;
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 24);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.universityPurple,
              AppColors.universityBlue,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Parte superior con logo, avatar, nombre y carrera
              _buildHeader(context, isLandscape, logoHeight, hPadding, vPadding, borderRadius),

              SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),

              // Fondo blanco para el contenido (según rol)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(borderRadius),
                      topRight: Radius.circular(borderRadius),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(hPadding),
                    child: _role == UserRole.professor
                        ? _buildProfessorView(context, isLandscape)
                        : StudentView(
                            primaryColor: AppColors.universityBlue,
                            accentColor: AppColors.universityLightBlue,
                            userEmail: widget.userEmail,
                            userType: widget.userType,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isLandscape, double logoHeight,
      double hPadding, double vPadding, double borderRadius) {
    final iconSize = ResponsiveUtils.getIconSize(context, 24);
    final titleFontSize = ResponsiveUtils.getFontSize(context, 18);
    final subtitleFontSize = ResponsiveUtils.getFontSize(context, 14);
    final roleFontSize = ResponsiveUtils.getFontSize(context, 14);
    
    return Container(
      padding: EdgeInsets.all(hPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.universityPurple,
            AppColors.universityBlue,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      ),
      child: Column(
        children: [
          // Row superior: logo a la izquierda, selector de rol a la derecha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                "assets/uni-logo.png",
                height: logoHeight,
              ),
              // Selector de rol y botón de ajustes
              Row(
                children: [
                  // Botón de ajustes
                  IconButton(
                    icon: Icon(Icons.settings, color: Colors.white, size: iconSize),
                    onPressed: () => _showSettingsDialog(context),
                  ),
                  SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
                  // Selector de rol (Profesor / Estudiante)
                  Icon(Icons.person, color: Colors.white70, size: ResponsiveUtils.getIconSize(context, 20)),
                  SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
                  PopupMenuButton<UserRole>(
                    initialValue: _role,
                    color: Colors.white,
                    onSelected: _setRole,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: UserRole.professor,
                        child: Text('Profesor', style: TextStyle(fontSize: roleFontSize)),
                      ),
                      PopupMenuItem(
                        value: UserRole.student,
                        child: Text('Estudiante', style: TextStyle(fontSize: roleFontSize)),
                      ),
                    ],
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: isLandscape ? 4.0 : 6.0,
                        horizontal: isLandscape ? 10.0 : 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context, 20)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _role == UserRole.professor ? 'Profesor' : 'Estudiante',
                            style: TextStyle(color: Colors.white, fontSize: roleFontSize),
                          ),
                          SizedBox(width: ResponsiveUtils.getSpacing(context, 6)),
                          Icon(Icons.arrow_drop_down, color: Colors.white, size: iconSize),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
          isLandscape
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "William David Lozano Julio",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: ResponsiveUtils.getSpacing(context, 4)),
                          Text(
                            "Estudiante de Ingeniería de Sistemas",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: subtitleFontSize,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _buildProfilePicture(context),
                  ],
                )
              : Row(
                  children: [
                    _buildProfilePicture(context),
                    SizedBox(width: ResponsiveUtils.getSpacing(context, 16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "William David Lozano Julio",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(height: ResponsiveUtils.getSpacing(context, 4)),
                          Text(
                            "Estudiante de Ingeniería de Sistemas",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: subtitleFontSize,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
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
      scale: isPressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.white.withValues(alpha: 0.95),
              color.withValues(alpha: isPressed ? 0.08 : 0.03),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: color.withValues(alpha: isPressed ? 0.4 : 0.25),
            width: isPressed ? 3.0 : 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isPressed ? 0.3 : 0.5),
              blurRadius: isPressed ? 12.0 : 20.0,
              offset: Offset(0, isPressed ? 4.0 : 8.0),
              spreadRadius: isPressed ? -1 : 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isPressed ? 0.03 : 0.08),
              blurRadius: isPressed ? 8.0 : 16.0,
              offset: Offset(0, isPressed ? 2.0 : 4.0),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() => _tappedButtonIndex = title.hashCode);
              Future.delayed(const Duration(milliseconds: 150), () {
                if (mounted) {
                  setState(() => _tappedButtonIndex = null);
                }
                onTap();
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
                    // Contenedor del ícono con gradiente y animación
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: isPressed 
                        ? (Matrix4.rotationZ(0.15)..scale(1.1))
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
                            color: color.withValues(alpha: isPressed ? 0.7 : 0.5),
                            blurRadius: isPressed ? 20.0 : 16.0,
                            offset: Offset(0, isPressed ? 8.0 : 6.0),
                            spreadRadius: -2,
                          ),
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
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

  /// Construir foto de perfil con borde estilizado y más visible
  Widget _buildProfilePicture(BuildContext context) {
    final radius = context.isLandscape ? 35.0 : 40.0;
    final padding = context.isLandscape ? 3.0 : 4.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            AppColors.universityPurple,
            AppColors.universityBlue,
            AppColors.universityLightBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundImage: const AssetImage("assets/foto-estudiante.jpg"),
      ),
    );
  }
  
  /// Botón moderno con animaciones y efectos glassmorphism mejorados
  Widget buildReactiveButton(
    BuildContext context,
    String title,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    final iconSize = ResponsiveUtils.getIconSize(context, 34);
    final fontSize = ResponsiveUtils.getFontSize(context, 18);
    final vPadding = ResponsiveUtils.getSpacing(context, 20);
    final hPadding = ResponsiveUtils.getSpacing(context, 20);
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 24);
    final spacing = ResponsiveUtils.getSpacing(context, 16);
    final iconContainerSize = ResponsiveUtils.getIconSize(context, 60);
    
    final isPressed = _tappedButtonIndex == title.hashCode;
    
    return AnimatedScale(
      scale: isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: ResponsiveUtils.getSpacing(context, 6)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.white.withValues(alpha: 0.95),
                color.withValues(alpha: isPressed ? 0.08 : 0.03),
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: color.withValues(alpha: isPressed ? 0.4 : 0.25),
              width: isPressed ? 3.0 : 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isPressed ? 0.3 : 0.5),
                blurRadius: isPressed ? 12.0 : 20.0,
                offset: Offset(0, isPressed ? 4.0 : 8.0),
                spreadRadius: isPressed ? -1 : 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isPressed ? 0.03 : 0.08),
                blurRadius: isPressed ? 8.0 : 16.0,
                offset: Offset(0, isPressed ? 2.0 : 4.0),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() => _tappedButtonIndex = title.hashCode);
                Future.delayed(const Duration(milliseconds: 150), () {
                  if (mounted) {
                    setState(() => _tappedButtonIndex = null);
                  }
                  onTap();
                });
              },
              borderRadius: BorderRadius.circular(borderRadius),
              splashColor: color.withValues(alpha: 0.15),
              highlightColor: color.withValues(alpha: 0.1),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: vPadding,
                  horizontal: hPadding,
                ),
                child: Row(
                    children: [
                      // Contenedor del ícono con gradiente y animación
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.rotationZ(isPressed ? 0.1 : 0.0),
                        width: iconContainerSize,
                        height: iconContainerSize,
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
                              color: color.withValues(alpha: isPressed ? 0.7 : 0.5),
                              blurRadius: isPressed ? 20 : 16,
                              offset: Offset(0, isPressed ? 8 : 6),
                              spreadRadius: -2,
                            ),
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: iconSize,
                          shadows: const [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(width: spacing),
                      
                      // Título y descripción
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: const Color(0xFF1A1A1A),
                                fontWeight: FontWeight.bold,
                                fontSize: fontSize,
                                letterSpacing: 0.3,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: ResponsiveUtils.getSpacing(context, 6)),
                            Text(
                              _getButtonSubtitle(title),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: ResponsiveUtils.getFontSize(context, 13),
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      
                      // Flecha indicadora con animación
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        transform: Matrix4.translationValues(isPressed ? 8.0 : 0.0, 0, 0),
                        padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 10)),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withValues(alpha: isPressed ? 0.25 : 0.15),
                              color.withValues(alpha: isPressed ? 0.15 : 0.08),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: color,
                          size: ResponsiveUtils.getIconSize(context, 18),
                        ),
                      ),
                    ],
                  ),
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
        "color": AppColors.universityPurple,
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
      Navigator.pushAndRemoveUntil(
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
        (route) => false,
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