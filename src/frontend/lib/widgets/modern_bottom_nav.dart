import 'package:flutter/material.dart';
import '../qr_scanner_screen.dart';
import '../utils/responsive_utils.dart';

class ModernBottomNav extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final Color primaryColor;
  final Color accentColor;
  final bool isStudent;

  const ModernBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.primaryColor,
    required this.accentColor,
    this.isStudent = false,
  });

  @override
  State<ModernBottomNav> createState() => _ModernBottomNavState();
}

class _ModernBottomNavState extends State<ModernBottomNav> with TickerProviderStateMixin {
  AnimationController? _scaleController;
  AnimationController? _glowController;
  int? _lastTappedIndex;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController?.dispose();
    _glowController?.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    setState(() {
      _lastTappedIndex = index;
    });

    _scaleController?.forward().then((_) {
      _scaleController?.reverse();
    });

    widget.onTap(index);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _lastTappedIndex = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final navHeight = ResponsiveUtils.getBottomNavHeight(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      // Sin padding lateral, directo al borde
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2C2C2E),
            Color(0xFF1C1C1E),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: widget.primaryColor.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, -8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      // Altura total = altura del nav + padding del sistema (barra de navegación Android)
      height: navHeight + bottomPadding,
      padding: EdgeInsets.only(
        bottom: bottomPadding, // Solo padding inferior para la barra del sistema
      ),
      child: widget.isStudent ? _buildStudentNav(context) : _buildTeacherNav(context),
    );
  }

  // Barra para ESTUDIANTES: Sesiones, QR, Asistencias
  Widget _buildStudentNav(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _buildNavItem(
            context: context,
            icon: Icons.star_outline_rounded,
            activeIcon: Icons.star_rounded,
            label: 'Sesiones',
            index: 0,
            color: const Color(0xFFEC4899),
          ),
        ),
        _buildQRButton(context),
        Expanded(
          child: _buildNavItem(
            context: context,
            icon: Icons.check_circle_outline,
            activeIcon: Icons.check_circle,
            label: 'Asistencias',
            index: 1,
            color: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  // Barra para PROFESORES: Servicios, Sesiones, Home, Asistencias, Dashboard
  Widget _buildTeacherNav(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _buildNavItem(
            context: context,
            icon: Icons.bookmark_outline,
            activeIcon: Icons.bookmark,
            label: 'Servicios',
            index: 0,
            color: const Color(0xFF6366F1),
          ),
        ),
        Expanded(
          child: _buildNavItem(
            context: context,
            icon: Icons.star_outline_rounded,
            activeIcon: Icons.star_rounded,
            label: 'Sesiones',
            index: 1,
            color: const Color(0xFFEC4899),
          ),
        ),
        _buildHomeButton(context),
        Expanded(
          child: _buildNavItem(
            context: context,
            icon: Icons.check_circle_outline,
            activeIcon: Icons.check_circle,
            label: 'Asistencias',
            index: 2,
            color: const Color(0xFF10B981),
          ),
        ),
        Expanded(
          child: _buildNavItem(
            context: context,
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics_rounded,
            label: 'Dashboard',
            index: 3,
            color: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required Color color,
  }) {
    final bool isSelected = index == widget.selectedIndex;
    final bool isTapped = _lastTappedIndex == index;
    final isLandscape = context.isLandscape;
    final iconPadding = isLandscape ? 4.0 : 5.0;
    final inactiveIconPadding = isLandscape ? 1.5 : 2.0;
    final iconSize = ResponsiveUtils.getIconSize(context, isSelected ? 23 : 21);
    final labelFontSize = ResponsiveUtils.getFontSize(context, isSelected ? 9.5 : 8.5);
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 10);
    
    return GestureDetector(
      onTap: () => _handleTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono con efectos
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.all(isSelected ? iconPadding : inactiveIconPadding),
              decoration: BoxDecoration(
                color: isSelected 
                  ? color.withValues(alpha: 0.15) 
                  : Colors.transparent,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ] : [],
              ),
              child: AnimatedBuilder(
                animation: _glowController ?? AnimationController(vsync: this, duration: Duration.zero),
                builder: (context, child) {
                  return AnimatedScale(
                    scale: isTapped ? 0.85 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      color: isSelected 
                        ? color 
                        : Colors.grey.shade500,
                      size: iconSize,
                      shadows: isSelected ? [
                        Shadow(
                          color: color.withValues(alpha: 0.5 + (_glowController?.value ?? 0) * 0.3),
                          blurRadius: 8 + (_glowController?.value ?? 0) * 4,
                        ),
                      ] : [],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 1),
            // Label con animación
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected 
                  ? color
                  : Colors.grey.shade600,
                fontSize: labelFontSize,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.1,
                shadows: isSelected ? [
                  Shadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 4,
                  ),
                ] : [],
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRButton(BuildContext context) {
    final buttonSize = context.isLandscape ? 58.0 : 64.0;
    final iconSize = ResponsiveUtils.getIconSize(context, 34);
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 20);
    final innerCircleSize = context.isLandscape ? 32.0 : 36.0;
    
    return GestureDetector(
      onTap: () {
        // Abrir escáner QR
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const QRScannerScreen(),
          ),
        );
        // Animación del botón
        setState(() {
          _lastTappedIndex = 999;
        });
        _scaleController?.forward().then((_) {
          _scaleController?.reverse();
        });
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _lastTappedIndex = null;
            });
          }
        });
      },
      child: AnimatedBuilder(
        animation: _scaleController ?? AnimationController(vsync: this, duration: Duration.zero),
        builder: (context, child) {
          final scale = 1.0 - ((_scaleController?.value ?? 0.0) * 0.12);
          return Transform.scale(
            scale: scale,
            child: AnimatedBuilder(
              animation: _glowController ?? AnimationController(vsync: this, duration: Duration.zero),
              builder: (context, child) {
                final glowValue = _glowController?.value ?? 0.0;
                return Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF6366F1),
                        Color(0xFF8B5CF6),
                        Color(0xFFEC4899),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.5 + glowValue * 0.3),
                        blurRadius: 24 + glowValue * 12,
                        offset: const Offset(0, 8),
                        spreadRadius: glowValue * 4,
                      ),
                      BoxShadow(
                        color: const Color(0xFFEC4899).withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Círculo de glow interno
                      Container(
                        width: innerCircleSize,
                        height: innerCircleSize,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15 + glowValue * 0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Ícono QR
                      Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: iconSize,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    final buttonSize = context.isLandscape ? 62.0 : 68.0;
    final iconSize = ResponsiveUtils.getIconSize(context, 36);
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 22);
    final innerCircleSize = context.isLandscape ? 38.0 : 42.0;
    
    return GestureDetector(
      onTap: () => _handleTap(999),
      child: AnimatedBuilder(
        animation: _scaleController ?? AnimationController(vsync: this, duration: Duration.zero),
        builder: (context, child) {
          final scale = 1.0 - ((_scaleController?.value ?? 0.0) * 0.12);
          return Transform.scale(
            scale: scale,
            child: AnimatedBuilder(
              animation: _glowController ?? AnimationController(vsync: this, duration: Duration.zero),
              builder: (context, child) {
                final glowValue = _glowController?.value ?? 0.0;
                return Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.primaryColor,
                        widget.accentColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: widget.primaryColor.withValues(alpha: 0.6 + glowValue * 0.3),
                        blurRadius: 28 + glowValue * 14,
                        offset: const Offset(0, 10),
                        spreadRadius: glowValue * 5,
                      ),
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.5),
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Efecto de brillo interno
                      Container(
                        width: innerCircleSize,
                        height: innerCircleSize,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2 + glowValue * 0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Ícono Home
                      Icon(
                        Icons.home_rounded,
                        color: Colors.white,
                        size: iconSize,
                        shadows: const [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}