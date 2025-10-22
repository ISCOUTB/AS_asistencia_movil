// filepath: c:\REPOSITORIOS\AS_asistencia_movil\src\front\lib\servicios.dart
import 'package:asistencia_movil/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'servicios.dart';
import 'sesiones.dart';
import 'asistencias.dart';
import 'inicio_app.dart';
// ignore: depend_on_referenced_packages
import 'package:fl_chart/fl_chart.dart';

class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 137, 99, 207);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
  static const backgroundLight = Color(0xFFF3F4F6);
}

// Clase original para navegación directa
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardPageContent();
  }
}

// Nuevo widget solo con contenido para usar en MainScaffold
class DashboardPageContent extends StatefulWidget {
  const DashboardPageContent({super.key});

  @override
  State<DashboardPageContent> createState() => _DashboardPageContentState();
}

class _DashboardPageContentState extends State<DashboardPageContent> {
  String _range = '7d';

  // Mock data for chart (sesiones per day)
  Map<String, List<int>> _mockData = {
    'today': [3],
    '7d': [1,2,3,2,4,3,1],
    '30d': List.generate(30, (i) => (i % 5) + 1),
  };

  List<int> get _currentData => _range == 'today' ? _mockData['today']! : _mockData[_range]!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.universityPurple,
                AppColors.universityBlue,
              ],
            ),
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Grid de tarjetas
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard('Sesiones hoy', '3', Icons.event, Colors.blue),
                _buildStatCard('Asistencias', '24', Icons.check_circle, Colors.green),
                _buildStatCard('Ausencias', '2', Icons.cancel, Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tendencia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ToggleButtons(
                  isSelected: [_range=='today', _range=='7d', _range=='30d'],
                  onPressed: (i) {
                    setState(() {
                      _range = (i==0)?'today':(i==1)?'7d':'30d';
                    });
                  },
                  children: const [Padding(padding: EdgeInsets.symmetric(horizontal:12), child: Text('Hoy')), Padding(padding: EdgeInsets.symmetric(horizontal:12), child: Text('7d')), Padding(padding: EdgeInsets.symmetric(horizontal:12), child: Text('30d'))],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (_currentData.reduce((a,b)=>a>b?a:b)).toDouble() + 2,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) { 
                          final idx = v.toInt();
                          return Text('${idx+1}');
                        })),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(_currentData.length, (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: _currentData[i].toDouble(), color: AppColors.universityBlue)])),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Actividad reciente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: 6,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(backgroundColor: AppColors.universityPurple, child: const Icon(Icons.person, color: Colors.white)),
                    title: Text('Usuario ${index + 1}'),
                    subtitle: Text('Registró asistencia en Sesión ${index + 1}'),
                    trailing: Text('hace ${index + 1}h', style: const TextStyle(fontSize: 12)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Renamed to ModernDashboardPage to avoid duplicate class name
class ModernDashboardPage extends StatelessWidget {
  const ModernDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.universityPurple,
                AppColors.universityBlue,
              ],
            ),
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(bottom: 100), // Espacio para nav bar
        child: const Center(
          child: Text(
            "Página de Dashboard",
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
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
            Colors.white.withOpacity(0.9),
            Colors.white,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              color: const Color(0xFF667EEA).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.bookmark_border, "Servicios", 0, 3, context),
            _buildNavItem(Icons.star_border, "Sesiones", 1, 3, context),
            _buildFloatingHomeButton(context),
            _buildNavItem(Icons.check_circle_outline, "Asistencias", 2, 3, context),
            _buildNavItem(Icons.bar_chart_outlined, "Dashboard", 3, 3, context),
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
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
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
                shadows: isSelected
                    ? [
                        const Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ]
                    : [],
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
              color: Colors.white.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
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
      (route) => false,
    );
  }

  void _navigateWithAnimation(BuildContext context, int index) {
    Widget destination;
    switch (index) {
      case 0:
        destination = const ServiciosPage();
        break;
      case 1:
        destination = SesionesPage();
        break;
      case 2:
        destination = const AsistenciasPage();
        break;
      case 3:
        return; // Ya estamos en Dashboard
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

void navegarAMainScaffold(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const MainScaffold(initialIndex: 0), // 0=Servicios, 1=Sesiones, 2=Asistencias, 3=Dashboard
    ),
  );
}

Widget _buildStatCard(String title, String value, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ],
    ),
  );
}