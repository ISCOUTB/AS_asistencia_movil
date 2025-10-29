import 'package:flutter/material.dart';
import 'asistencias_estudiante.dart';

class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 137, 99, 207);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
  static const backgroundLight = Color(0xFFF3F4F6);
}

class AsistenciasPage extends StatelessWidget {
  const AsistenciasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentAsistenciasPage();
  }
}+

class AsistenciasPageContent extends StatelessWidget {
  const AsistenciasPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentAsistenciasPage();
  }
}
