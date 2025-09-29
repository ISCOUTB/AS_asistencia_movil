// filepath: c:\REPOSITORIOS\AS_asistencia_movil\src\front\lib\servicios.dart
import 'package:flutter/material.dart';

class AsistenciasPage extends StatelessWidget {
  const AsistenciasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Asistencias"),
      ),
      body: const Center(
        child: Text("Página de Asistencias"),
      ),
    );
  }
}