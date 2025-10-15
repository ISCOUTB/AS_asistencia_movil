import 'package:flutter/material.dart';
import 'servicios.dart';
import 'sesiones.dart';
import 'asistencias.dart' hide SesionesPageContent;
import 'dashboard.dart';
import 'inicio_app.dart';
import 'widgets/modern_bottom_nav.dart';

class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 137, 99, 207);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
  static const backgroundLight = Color(0xFFF3F4F6);
}

class MainScaffold extends StatefulWidget {
  final int initialIndex;
  
  const MainScaffold({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> with TickerProviderStateMixin {
  late int _currentIndex;
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _homeAnimationController;
  int _animatingIndex = -1;

  final List<Widget> _pages = [
    const ServiciosPageContent(),
    SesionesPageContent(),
    const AsistenciasPageContent(),
    const DashboardPageContent(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _homeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _homeAnimationController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
        _animatingIndex = index;
      });
      
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
      
      _animationController.forward().then((_) {
        _animationController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _animatingIndex = -1;
            });
          }
        });
      });
    }
  }

  void _navigateToHome() {
    _homeAnimationController.forward().then((_) {
      _homeAnimationController.reverse();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0.0, -1.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: ModernBottomNav(
        selectedIndex: _currentIndex,
        primaryColor: const Color(0xFF667EEA),
        accentColor: const Color(0xFF764BA2),
        onTap: (index) {
          if (index == 999) {
            _navigateToHome();
            return;
          }
          _onNavItemTapped(index);
        },
      ),
    );
  }

  

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = index == _currentIndex;
    bool isAnimating = index == _animatingIndex;
    
    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: Container(
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Contenedor del ícono con animación centrada
            Container(
              width: 55,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: isSelected 
                    ? Border.all(color: Colors.white.withOpacity(0.3), width: 1.5)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: isAnimating 
                    ? AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          double scale = 1.0 + (_animationController.value * 0.3);
                          return Transform.scale(
                            scale: scale,
                            child: Icon(
                              _getSelectedIcon(icon),
                              color: Colors.white,
                              size: 26,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : AnimatedScale(
                        scale: isSelected ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isSelected ? _getSelectedIcon(icon) : icon,
                          color: Colors.white,
                          size: 26,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            // Texto centrado con ancho fijo
            Container(
              width: 70,
              height: 12,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSelected ? 10 : 9,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.4),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
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

  Widget _buildFloatingHomeButton() {
    return GestureDetector(
      onTap: _navigateToHome,
      child: Container(
        height: 80,
        child: Center( // Centrado vertical perfecto
          child: AnimatedBuilder(
            animation: _homeAnimationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_homeAnimationController.value * 0.15),
                child: Container(
                  width: 65, // Más grande que los otros contenedores
                  height: 65, // Más grande que los otros contenedores
                  decoration: BoxDecoration(
                    gradient: const RadialGradient(
                      center: Alignment.topLeft,
                      radius: 1.2,
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFF8F9FA),
                        Color(0xFFE9ECEF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(32.5), // Proporcional al tamaño
                    border: Border.all(
                      color: Colors.white.withOpacity(0.9),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.7),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: const Color(0xFF667EEA).withOpacity(0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.home_rounded,
                      color: const Color(0xFF667EEA),
                      size: 35, // Ícono mucho más grande
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}