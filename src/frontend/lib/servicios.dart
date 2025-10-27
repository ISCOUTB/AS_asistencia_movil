import 'package:flutter/material.dart';
import 'sesiones.dart';
import 'asistencias.dart';
import 'dashboard.dart';
import 'inicio_app.dart';
import 'api/routes/servicio_service.dart';
import 'main_scaffold.dart';

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
  late ServicioService servicioService;
  List<dynamic> servicios = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Usar URL directa del backend Oracle ORDS
    const baseUrl = 'https://ga7a0b6c9043600-atpdb.adb.us-phoenix-1.oraclecloudapps.com/ords/ecoutb_workspace/servicios/';
    servicioService = ServicioService(baseUrl);
    _cargarServicios();
  }

  Future<void> _cargarServicios() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await servicioService.getServicios();
      setState(() {
        servicios = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar servicios: $e';
        isLoading = false;
      });
      print('Error cargando servicios: $e');
    }
  }

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

          // Lista de servicios desde el backend
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: const BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 60, color: Colors.red),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                child: Text(
                                  errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _cargarServicios,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.universityBlue,
                                ),
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        )
                      : servicios.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay servicios disponibles',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _cargarServicios,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: servicios.length,
                                itemBuilder: (context, index) {
                                  final servicio = servicios[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () => _mostrarDetalleServicio(context, servicio),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    AppColors.universityPurple,
                                                    AppColors.universityBlue,
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.bookmark,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                servicio['nombre_servicio'] ?? 'Sin nombre',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Icon(
                                              Icons.chevron_right,
                                              color: Colors.grey[400],
                                              size: 28,
                                            ),
                                          ],
                                        ),
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
    );
  }

  void _mostrarDetalleServicio(BuildContext context, Map<String, dynamic> servicio) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Color(0xFFF8F9FA),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header con gradiente
                  Container(
                    padding: const EdgeInsets.all(20),
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
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.bookmark,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            servicio['nombre_servicio'] ?? 'Sin nombre',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Contenido
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Descripción - solo mostrar si existe
                        if (servicio['descripcion'] != null && servicio['descripcion'].toString().isNotEmpty)
                          _buildInfoSection(
                            icon: Icons.description,
                            title: 'Descripción',
                            content: servicio['descripcion'].toString(),
                            color: AppColors.universityBlue,
                          ),
                        if (servicio['descripcion'] != null && servicio['descripcion'].toString().isNotEmpty)
                          const SizedBox(height: 16),

                        // Materia - solo mostrar si existe
                        if (servicio['materia'] != null && servicio['materia'].toString().isNotEmpty)
                          _buildInfoSection(
                            icon: Icons.book,
                            title: 'Materia',
                            content: servicio['materia'].toString(),
                            color: AppColors.universityPurple,
                          ),
                        if (servicio['materia'] != null && servicio['materia'].toString().isNotEmpty)
                          const SizedBox(height: 16),

                        // Periodo - solo mostrar si existe
                        if (servicio['periodo'] != null && servicio['periodo'].toString().isNotEmpty)
                          _buildInfoSection(
                            icon: Icons.calendar_today,
                            title: 'Periodo',
                            content: servicio['periodo'].toString(),
                            color: AppColors.universityLightBlue,
                          ),
                        if (servicio['periodo'] != null && servicio['periodo'].toString().isNotEmpty)
                          const SizedBox(height: 16),

                        // Información adicional
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    servicio['permite_externos'] == 'S'
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: servicio['permite_externos'] == 'S'
                                        ? Colors.green
                                        : Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Permite externos: ',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(servicio['permite_externos'] == 'S' ? 'Sí' : 'No'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    servicio['acumula_asistencia'] == 'S'
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: servicio['acumula_asistencia'] == 'S'
                                        ? Colors.green
                                        : Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Acumula asistencia: ',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(servicio['acumula_asistencia'] == 'S' ? 'Sí' : 'No'),
                                ],
                              ),
                              if (servicio['fecha_creacion'] != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Fecha de creación: ',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Expanded(
                                      child: Text(
                                        servicio['fecha_creacion'].toString(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Botones de acción
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cerrar',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
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