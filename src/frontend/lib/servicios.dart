import 'package:flutter/material.dart';
import 'sesiones.dart';
import 'asistencias.dart';
import 'dashboard.dart';

class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 137, 99, 207);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
  static const backgroundLight = Color(0xFFF3F4F6);
}

class ServiciosPage extends StatefulWidget {
  const ServiciosPage({super.key});

  @override
  State<ServiciosPage> createState() => _ServiciosPageState();
}

class _ServiciosPageState extends State<ServiciosPage> {
  // Lista de dadores de servicios
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
                // Logo de la universidad
                Image.asset(
                  "assets/uni-logo.png",
                  height: 50,
                ),
                const SizedBox(width: 16),
                // Título
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Índice de la página actual
        onTap: (index) {
          switch (index) {
            case 0:
              // Ya estamos en Servicios, no hacer nada
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SesionesPage()),
              );
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

  /// Mostrar detalle del servicio en un menú emergente centrado
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