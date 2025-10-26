import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'servicios.dart';
import 'sesiones.dart';
import 'asistencias.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ServiciosPage(),
    SesionesPage(),
    const AsistenciasPage(),
    const DashboardPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: "Servicios",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: "Sesiones",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: "Asistencias",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Dashboard",
          ),
        ],
      ),
    );
  }
}