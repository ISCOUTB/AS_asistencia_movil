import 'package:flutter/material.dart';
import 'servicios.dart';
import 'asistencias.dart';
import 'dashboard.dart';

class SesionesPage extends StatelessWidget {
  SesionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sesiones"),
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
          // Encabezado y contenido existente
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
                    "Sesiones de la Universidad Tecnológica de Bolívar",
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Acción para crear sesión
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Crear sesión"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.universityBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Acción para ver calendario
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text("Calendario"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.universityPurple,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Acción para administrar facilitadores
                  },
                  icon: const Icon(Icons.people),
                  label: const Text("Facilitadores"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.universityLightBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: sesiones.length,
                  itemBuilder: (context, index) {
                    final sesion = sesiones[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sesion["centro"] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text("Servicio: ${sesion["servicio"]}"),
                            Text("Fecha: ${sesion["fecha"]}"),
                            Text("Modalidad: ${sesion["modalidad"]}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Índice de la página actual
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ServiciosPage()),
              );
              break;
            case 1:
              // Ya estamos en Sesiones, no hacer nada
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AsistenciasPage()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              );
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.universityBlue,
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

  /// Lista de sesiones simulada
  final List<Map<String, String>> sesiones = [
    {
      "centro": "Centro de Cuidado Integral",
      "servicio": "Asesoría Psicológica",
      "fecha": "16/07/2025",
      "modalidad": "Híbrido",
    },
    {
      "centro": "Centro de Innovación",
      "servicio": "Hackathon",
      "fecha": "20/06/2025",
      "modalidad": "Presencial",
    },
    {
      "centro": "Centro de Apoyo Académico",
      "servicio": "Tutorías en Matemáticas",
      "fecha": "12/06/2025",
      "modalidad": "Remoto",
    },
  ];
}