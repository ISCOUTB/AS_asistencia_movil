import 'package:flutter/material.dart';
import 'servicios.dart';
import 'sesiones_profesor.dart';
import 'asistencias_profesor.dart';
import 'sesiones_estudiante.dart';
import 'asistencias_estudiante.dart';
import 'dashboard.dart';
import 'widgets/modern_bottom_nav.dart';

class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 137, 99, 207);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
  static const backgroundLight = Color(0xFFF3F4F6);
}

class MainScaffold extends StatefulWidget {
  final int initialIndex;
  final bool isStudent; // Nuevo parámetro para identificar tipo de usuario
  
  const MainScaffold({
    super.key,
    this.initialIndex = 0,
    this.isStudent = false, // Por defecto es profesor
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> with TickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _animationController;
  late AnimationController _homeAnimationController;
  final List<int> _navigationHistory = []; // Historial de navegación

  // Páginas para PROFESORES: Servicios, Sesiones, Asistencias, Dashboard
  final List<Widget> _teacherPages = [
    const ServiciosPageContent(),
    const TeacherSesionesPage(),
    const TeacherAsistenciasPage(),
    const DashboardPageContent(),
  ];

  // Páginas para ESTUDIANTES: Sesiones, Asistencias
  final List<Widget> _studentPages = [
    const StudentSesionesPage(),
    const StudentAsistenciasPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _navigationHistory.add(_currentIndex); // Agregar índice inicial al historial
    
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
    _animationController.dispose();
    _homeAnimationController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
        _navigationHistory.add(index); // Agregar al historial
      });
      
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_navigationHistory.length > 1) {
      // Hay historial, volver a la pestaña anterior
      setState(() {
        _navigationHistory.removeLast(); // Quitar el actual
        _currentIndex = _navigationHistory.last; // Ir al anterior
      });
      return false; // No salir de la app
    }
    return true; // Permitir salir (volver al HomeScreen)
  }

  void _navigateToHome() {
    _homeAnimationController.forward().then((_) {
      _homeAnimationController.reverse();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      // Volver al menú inicial (HomeScreen)
      Navigator.popUntil(context, (route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Seleccionar las páginas según el tipo de usuario
    final pages = widget.isStudent ? _studentPages : _teacherPages;
    
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: ModernBottomNav(
          selectedIndex: _currentIndex,
          primaryColor: const Color(0xFF667EEA),
          accentColor: const Color(0xFF764BA2),
          isStudent: widget.isStudent,
          onTap: (index) {
            if (index == 999) {
              _navigateToHome();
              return;
            }
            _onNavItemTapped(index);
          },
        ),
      ),
    );
  }
}
