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
      debugShowCheckedModeBanner: false, // QUITAR BANNER ROJO
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header del modal
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.universityPurple, AppColors.universityBlue],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.settings, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Configuración',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Información del usuario
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.universityBlue.withValues(alpha: 0.2),
                          child: Icon(
                            _role == UserRole.professor ? Icons.school : Icons.person,
                            color: AppColors.universityBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.userEmail,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _role == UserRole.professor ? 'Profesor' : 'Estudiante',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Selector de perfil
              const Text(
                'Cambiar perfil',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildRoleOption(
                      context,
                      'Profesor',
                      Icons.school,
                      UserRole.professor,
                      _role == UserRole.professor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildRoleOption(
                      context,
                      'Estudiante',
                      Icons.person,
                      UserRole.student,
                      _role == UserRole.student,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Botón de cerrar sesión
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleLogout(context),
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text(
                    'Cerrar sesión',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildRoleOption(
    BuildContext context,
    String label,
    IconData icon,
    UserRole role,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _setRole(role);
        });
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.universityPurple, AppColors.universityBlue],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.universityBlue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
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
    final titleFontSize = ResponsiveUtils.getFontSize(context, isLandscape ? 18 : 20);
    final roleBadgeFontSize = ResponsiveUtils.getFontSize(context, 11);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: hPadding,
        vertical: ResponsiveUtils.getSpacing(context, isLandscape ? 12 : 16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row superior: badge, nombre y foto
          Row(
            children: [
              // Badge de rol compacto
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _role == UserRole.professor ? Icons.school : Icons.person,
                      color: Colors.white,
                      size: ResponsiveUtils.getIconSize(context, 14),
                    ),
                    SizedBox(width: ResponsiveUtils.getSpacing(context, 4)),
                    Text(
                      _role == UserRole.professor ? 'Profesor' : 'Estudiante',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: roleBadgeFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Foto de perfil clickeable con diseño bonito
              GestureDetector(
                onTap: () => _showSettingsDialog(context),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: ResponsiveUtils.getIconSize(context, isLandscape ? 20 : 24),
                    backgroundImage: const AssetImage('assets/foto-estudiante.jpg'),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.getSpacing(context, isLandscape ? 8 : 12)),
          
          // Nombre del usuario
          Text(
            'William David Lozano Julio',
            style: TextStyle(
              color: Colors.white,
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context, 8)),
          
          // Subtítulo con información de rol
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: ResponsiveUtils.getIconSize(context, 14),
                ),
                SizedBox(width: ResponsiveUtils.getSpacing(context, 6)),
                Text(
                  'Universidad Tecnológica de Bolívar',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: ResponsiveUtils.getFontSize(context, 11),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
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

  /// Construir foto de perfil con borde estilizado y más visible
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
        scale: isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: ResponsiveUtils.getSpacing(context, 8)),
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
                padding: EdgeInsets.symmetric(
                  vertical: vPadding,
                  horizontal: hPadding,
                ),
                child: Row(
                    children: [
                      // Contenedor del ícono - SIMPLIFICADO
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        transform: Matrix4.rotationZ(isPressed ? 0.08 : 0.0),
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
                              color: color.withValues(alpha: isPressed ? 0.5 : 0.35),
                              blurRadius: isPressed ? 12 : 10,
                              offset: Offset(0, isPressed ? 4 : 3),
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
                      
                      // Flecha indicadora - SIMPLIFICADA
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        transform: Matrix4.translationValues(isPressed ? 8.0 : 0.0, 0, 0),
                        padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 12)),
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
                          size: ResponsiveUtils.getIconSize(context, 20),
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