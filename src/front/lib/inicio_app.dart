// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

/// Colores institucionales
class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212); // Azul más claro
  static const universityPurple = Color.fromARGB(255, 137, 99, 207); // Morado más claro
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165); // Azul claro adicional
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight, // Degradado horizontal
            colors: [
              AppColors.universityPurple, // Lado izquierdo morado claro
              AppColors.universityBlue,   // Lado derecho azul claro
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
                    end: Alignment.centerRight, // Degradado horizontal
                    colors: [
                      AppColors.universityPurple, // Lado izquierdo morado claro
                      AppColors.universityBlue,   // Lado derecho azul claro
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo de la universidad sin fondo
                        Image.asset(
                          "assets/uni-logo.png", // Asegúrate de que el logo esté en esta ruta
                          height: 100, // Tamaño ajustado
                        ),
                        // Avatar del usuario
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage("assets/foto-estudiante.jpg"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4), // Espacio reducido entre logo y nombre
                    // Nombre y carrera del estudiante
                    const Text(
                      "William David Lozano Julio",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Estudiante de Ingeniería de Sistemas",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Column(
                      children: [
                        buildReactiveButton("Servicios", AppColors.universityBlue, Icons.bookmark),
                        const SizedBox(height: 24),
                        buildReactiveButton("Sesiones", AppColors.universityPurple, Icons.star),
                        const SizedBox(height: 24),
                        buildReactiveButton("Asistencias", AppColors.universityLightBlue, Icons.check_circle),
                        const SizedBox(height: 24),
                        buildReactiveButton("Admin", AppColors.universityPurple, Icons.settings),
                        const SizedBox(height: 24),
                        buildReactiveButton("Dashboard", AppColors.universityBlue, Icons.bar_chart),
                      ],
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

  /// Botón reactivo con animación
  Widget buildReactiveButton(String title, Color color, IconData icon) {
    return GestureDetector(
      onTapDown: (_) => setState(() {}),
      onTapUp: (_) => setState(() {}),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 95,
        decoration: BoxDecoration(
          color: color.withOpacity(0.3), // Transparencia manteniendo el color
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26, // Sombra más pronunciada
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.5), // Borde tipo vidrio
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
