import 'package:asistencia_movil/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'sesiones.dart';
import 'asistencias.dart';
import 'dashboard.dart';
import 'inicio_app.dart';

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
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
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
  final List<Map<String, dynamic>> dadoresDeServicios = [
    {
      "nombre": "Centro de Cuidado Integral",
      "correo": "cuidado@utb.edu.co",
      "servicios": [
        {
          "nombre": "Asesoría Psicológica",
          "fecha": "05/06/2025",
          "correoResponsable": "kgaravito@utb.edu.co",
          "admiteExternos": "Solo personas con cuenta UTB",
          "acumulaAsistencia": "Sí",
        },
        {
          "nombre": "Taller de Bienestar",
          "fecha": "15/07/2025",
          "correoResponsable": "lpulello@utb.edu.co",
          "admiteExternos": "Personas con y sin cuenta UTB",
          "acumulaAsistencia": "Sí",
        },
      ],
    },
    {
      "nombre": "Centro de Excelencia Docente",
      "correo": "docente@utb.edu.co",
      "servicios": [
        {
          "nombre": "Capacitación en TIC",
          "fecha": "10/06/2025",
          "correoResponsable": "rariza@utb.edu.co",
          "admiteExternos": "No",
          "acumulaAsistencia": "No",
        },
        {
          "nombre": "Taller de Pedagogía",
          "fecha": "05/06/2025",
          "correoResponsable": "hteran@utb.edu.co",
          "admiteExternos": "No",
          "acumulaAsistencia": "No",
        },
      ],
    },
    {
      "nombre": "Centro de Apoyo Académico",
      "correo": "academico@utb.edu.co",
      "servicios": [
        {
          "nombre": "Tutorías en Matemáticas",
          "fecha": "12/06/2025",
          "correoResponsable": "mgomez@utb.edu.co",
          "admiteExternos": "Sí",
          "acumulaAsistencia": "Sí",
        },
        {
          "nombre": "Tutorías en Física",
          "fecha": "15/06/2025",
          "correoResponsable": "yatencia@utb.edu.co",
          "admiteExternos": "No",
          "acumulaAsistencia": "No",
        },
      ],
    },
    {
      "nombre": "Centro de Innovación",
      "correo": "innovacion@utb.edu.co",
      "servicios": [
        {
          "nombre": "Hackathon",
          "fecha": "20/06/2025",
          "correoResponsable": "vega@utb.edu.co",
          "admiteExternos": "Sí",
          "acumulaAsistencia": "Sí",
        },
        {
          "nombre": "Taller de Creatividad",
          "fecha": "25/06/2025",
          "correoResponsable": "vega@utb.edu.co",
          "admiteExternos": "No",
          "acumulaAsistencia": "No",
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Servicios"),
        automaticallyImplyLeading: false,
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
      body: Column(
        children: [
          // Encabezado con logo y título
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.universityPurple,
                  AppColors.universityBlue,
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Image.asset(
                  "assets/uni-logo.png",
                  height: 50,
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    "Servicios de la Universidad Tecnológica de Bolívar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Lista de dadores de servicios con menú desplegable
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20), // Menos espacio para la barra persistente
              decoration: const BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: ListView.builder(
                itemCount: dadoresDeServicios.length,
                itemBuilder: (context, index) {
                  final dador = dadoresDeServicios[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: ExpansionTile(
                      title: Text(
                        dador["nombre"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text("Correo: ${dador["correo"]}"),
                      children: [
                        ...dador["servicios"].map<Widget>((servicio) {
                          return ListTile(
                            title: Text(servicio["nombre"]),
                            leading: const Icon(
                              Icons.info_outline,
                              color: AppColors.universityBlue,
                            ),
                            onTap: () {
                              _mostrarDetalleServicio(context, servicio);
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDetalleServicio(BuildContext context, Map<String, dynamic> servicio) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            servicio["nombre"],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.universityBlue,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Fecha de creación: ${servicio["fecha"]}"),
              Text("Correo del responsable: ${servicio["correoResponsable"]}"),
              Text("Admite externos: ${servicio["admiteExternos"]}"),
              Text("Acumula asistencia: ${servicio["acumulaAsistencia"]}"),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.universityBlue,
              ),
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
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