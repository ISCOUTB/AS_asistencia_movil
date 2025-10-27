// filepath: c:\REPOSITORIOS\AS_asistencia_movil\src\front\lib\servicios.dart
import 'package:asistencia_movil/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'servicios.dart';
import 'sesiones.dart';
import 'asistencias.dart';
import 'inicio_app.dart';
import 'widgets/custom_header.dart';
import 'utils/responsive_utils.dart';
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
    // Obtener configuraciones responsive
    final isLandscape = context.isLandscape;
    final hPadding = context.horizontalPadding;
    final vPadding = context.verticalPadding;
    final spacing = ResponsiveUtils.getSpacing(context, 16);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header profesor
            const ProfessorHeader(title: "Dashboard - Estadísticas"),
            
            Expanded(
              child: Container(
                color: AppColors.backgroundLight,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: hPadding,
                    vertical: vPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título de sección responsive
                      _buildSectionHeader(
                        context,
                        'Resumen General',
                        AppColors.universityPurple,
                      ),
                      SizedBox(height: spacing),
                      
                      // Grid de tarjetas responsive
                      GridView.count(
                        crossAxisCount: isLandscape ? 3 : (context.screenWidth > 600 ? 3 : 2),
                        shrinkWrap: true,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: ResponsiveUtils.getCardAspectRatio(context),
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStatCard(
                            context,
                            'Sesiones hoy',
                            '3',
                            Icons.event,
                            AppColors.universityBlue,
                          ),
                          _buildStatCard(
                            context,
                            'Asistencias',
                            '24',
                            Icons.check_circle,
                            Colors.green,
                          ),
                          _buildStatCard(
                            context,
                            'Ausencias',
                            '2',
                            Icons.cancel,
                            Colors.red,
                          ),
                        ],
                      ),
                      
                      SizedBox(height: spacing * 1.75),
                      
                      // Sección de tendencia responsive
                      _buildTrendHeader(context),
                      SizedBox(height: spacing),
                      
                      // Gráfico responsive
                      _buildResponsiveChart(context),
                      
                      SizedBox(height: spacing * 1.75),
                      
                      // Actividad reciente
                      _buildSectionHeader(
                        context,
                        'Actividad Reciente',
                        AppColors.universityLightBlue,
                      ),
                      SizedBox(height: spacing * 0.75),
                      
                      // Lista de actividad responsive
                      _buildActivityList(context),
                      
                      SizedBox(height: ResponsiveUtils.getBottomNavHeight(context) + 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, Color color) {
    final fontSize = ResponsiveUtils.getFontSize(context, 19);
    
    return Row(
      children: [
        Container(
          width: context.isLandscape ? 3 : 4,
          height: fontSize + 2,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: context.isLandscape ? 8 : 12),
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendHeader(BuildContext context) {
    final fontSize = ResponsiveUtils.getFontSize(context, 19);
    final isLandscape = context.isLandscape;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isLandscape ? 3 : 4,
                height: fontSize + 2,
                decoration: BoxDecoration(
                  color: AppColors.universityBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: isLandscape ? 8 : 12),
              Flexible(
                child: Text(
                  'Tendencia de Sesiones',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: isLandscape ? 12 : 8),
        _buildRangeSelector(context),
      ],
    );
  }

  Widget _buildRangeSelector(BuildContext context) {
    final buttonSize = ResponsiveUtils.getFontSize(context, 11);
    final isSmall = context.screenWidth < 360;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ToggleButtons(
        isSelected: [_range == 'today', _range == '7d', _range == '30d'],
        onPressed: (i) {
          setState(() {
            _range = (i == 0) ? 'today' : (i == 1) ? '7d' : '30d';
          });
        },
        borderRadius: BorderRadius.circular(10),
        selectedBorderColor: AppColors.universityPurple,
        selectedColor: Colors.white,
        fillColor: AppColors.universityPurple,
        color: Colors.grey.shade700,
        constraints: BoxConstraints(
          minHeight: isSmall ? 28 : 32,
          minWidth: isSmall ? 40 : 50,
        ),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmall ? 6 : 10),
            child: Text(
              'Hoy',
              style: TextStyle(
                fontSize: buttonSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmall ? 6 : 10),
            child: Text(
              '7d',
              style: TextStyle(
                fontSize: buttonSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmall ? 6 : 10),
            child: Text(
              '30d',
              style: TextStyle(
                fontSize: buttonSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveChart(BuildContext context) {
    final chartHeight = context.isLandscape ? 200.0 : 240.0;
    final fontSize = ResponsiveUtils.getFontSize(context, 10);
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 16);
    final padding = ResponsiveUtils.getCardPadding(context);
    
    return Container(
      height: chartHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: _range == '30d'
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: _currentData.length * 25.0,
                  child: _buildBarChart(context, fontSize),
                ),
              )
            : _buildBarChart(context, fontSize),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, double fontSize) {
    final barWidth = context.isLandscape ? 10.0 : (_range == 'today' ? 20.0 : 16.0);
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (_currentData.reduce((a, b) => a > b ? a : b)).toDouble() + 2,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _range == '30d' ? 5 : null,
              getTitlesWidget: (v, meta) {
                final idx = v.toInt();
                if (_range == '30d' && idx % 5 != 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '${idx + 1}',
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Colors.grey.shade600,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.grey.shade600,
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          _currentData.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: _currentData[i].toDouble(),
                color: AppColors.universityBlue,
                width: barWidth,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(context.isLandscape ? 3 : 4),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityList(BuildContext context) {
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 16);
    final iconSize = ResponsiveUtils.getIconSize(context, 22);
    final titleSize = ResponsiveUtils.getFontSize(context, 15);
    final subtitleSize = ResponsiveUtils.getFontSize(context, 13);
    final timeSize = ResponsiveUtils.getFontSize(context, 12);
    final isLandscape = context.isLandscape;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: isLandscape ? 4 : 6, // Menos items en horizontal
        separatorBuilder: (_, __) => Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.shade100,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.horizontalPadding * 0.8,
              vertical: isLandscape ? 4 : 8,
            ),
            leading: Container(
              width: isLandscape ? 40 : 44,
              height: isLandscape ? 40 : 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.universityPurple, AppColors.universityBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.person, color: Colors.white, size: iconSize),
            ),
            title: Text(
              'Usuario ${index + 1}',
              style: TextStyle(
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w600,
                fontSize: titleSize,
              ),
            ),
            subtitle: Text(
              'Registró asistencia en Sesión ${index + 1}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: subtitleSize,
              ),
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isLandscape ? 8 : 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.universityLightBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'hace ${index + 1}h',
                style: TextStyle(
                  fontSize: timeSize,
                  color: AppColors.universityLightBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
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
          color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.3),
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

Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
  final padding = ResponsiveUtils.getCardPadding(context);
  final iconSize = ResponsiveUtils.getIconSize(context, 28);
  final valueSize = ResponsiveUtils.getFontSize(context, 28);
  final titleSize = ResponsiveUtils.getFontSize(context, 13);
  final borderRadius = ResponsiveUtils.getBorderRadius(context, 16);
  
  return Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: Colors.grey.shade200, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Icono más grande en contenedor
        Container(
          padding: EdgeInsets.all(context.isLandscape ? 10 : 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: iconSize),
        ),
        
        // Valor y título más claros
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: valueSize,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1.1,
              ),
            ),
            SizedBox(height: context.isLandscape ? 2 : 4),
            Text(
              title,
              style: TextStyle(
                fontSize: titleSize,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    ),
  );
}