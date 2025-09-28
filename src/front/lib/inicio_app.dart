// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'servicios.dart';
import 'sesiones.dart';
import 'asistencias.dart';
import 'utils/custom_page_route.dart';

/// Colores institucionales
class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 137, 99, 207);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
  static const backgroundLight = Color(0xFFF3F4F6);
}

/// Página principal de la app
class InicioApp extends StatelessWidget {
  const InicioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asistencia Universitaria',
      theme: ThemeData(
        primaryColor: AppColors.universityBlue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

/// Pantalla de inicio
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

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
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
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
                child: Column(
                  children: [
                    // Logo de la universidad
                    Image.asset(
                      "assets/uni-logo.png",
                      height: 80,
                    ),
                    const SizedBox(height: 16),
                    isLandscape
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "William David Lozano Julio",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Estudiante de Ingeniería de Sistemas",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildProfilePicture(),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildProfilePicture(),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "William David Lozano Julio",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Estudiante de Ingeniería de Sistemas",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Fondo blanco para los botones
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (isLandscape) {
                          // Botones en modo horizontal (grid)
                          final crossAxisCount =
                              constraints.maxWidth > 600 ? 3 : 2;
                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.2,
                            ),
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              final buttons = getButtons();
                              final button = buttons[index];
                              return buildReactiveButton(
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
                          // Botones en modo vertical (list)
                          final buttons = getButtons();
                          return ListView.builder(
                            itemCount: buttons.length,
                            itemBuilder: (context, index) {
                              final button = buttons[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 30.0),
                                child: buildReactiveButton(
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
                                ),
                              );
                            },
                          );
                        }
                      },
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

  /// Construir foto de perfil con borde estilizado y más visible
Widget _buildProfilePicture() {
  return Container(
    padding: const EdgeInsets.all(6), // Espaciado entre el avatar y el borde
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
          color: Colors.black.withOpacity(0.6),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: const CircleAvatar(
      radius: 50, // Aumentamos el tamaño del avatar
      backgroundImage: AssetImage("assets/foto-estudiante.jpg"),
    ),
  );
}
  /// Botón reactivo con animación
  Widget buildReactiveButton(String title, Color color, IconData icon,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Lista de botones
  List<Map<String, dynamic>> getButtons() {
    return [
      {
        "title": "Servicios",
        "color": AppColors.universityBlue,
        "icon": Icons.bookmark,
        "page": const ServiciosPage(),
      },
      {
        "title": "Sesiones",
        "color": AppColors.universityPurple,
        "icon": Icons.star,
        "page": SesionesPage(),
      },
      {
        "title": "Asistencias",
        "color": AppColors.universityLightBlue,
        "icon": Icons.check_circle,
        "page": const AsistenciasPage(),
      },
      {
        "title": "Dashboard",
        "color": AppColors.universityBlue,
        "icon": Icons.bar_chart,
        "page": const DashboardPage(),
      },
    ];
  }
}
