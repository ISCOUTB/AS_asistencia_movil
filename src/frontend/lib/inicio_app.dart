// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'utils/custom_page_route.dart';
import 'main_scaffold.dart';
import 'widgets/modern_bottom_nav.dart';
import 'api/services/user_session.dart';
import 'main.dart';

/// Colores institucionales
class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 137, 99, 207);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
  static const backgroundLight = Color(0xFFF3F4F6);
}

/// Página principal de la app
class InicioApp extends StatelessWidget {
  final String userEmail;
  final String userType;
  
  const InicioApp({
    super.key,
    required this.userEmail,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTB Assists',
      theme: ThemeData(
        primaryColor: AppColors.universityBlue,
        useMaterial3: true,
      ),
      home: HomeScreen(userEmail: userEmail, userType: userType),
    );
  }
}

/// Pantalla de inicio
class HomeScreen extends StatefulWidget {
  final String userEmail;
  final String userType;
  
  const HomeScreen({
    super.key,
    this.userEmail = '',
    this.userType = 'estudiante',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum UserRole { professor, student }

class _HomeScreenState extends State<HomeScreen> {
  late UserRole _role;

  @override
  void initState() {
    super.initState();
    // Establecer el rol según el tipo de usuario
    _role = widget.userType == 'profesor' ? UserRole.professor : UserRole.student;
  }

  void _setRole(UserRole role) {
    setState(() {
      _role = role;
    });
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings, color: AppColors.universityBlue),
            SizedBox(width: 8),
            Text('Ajustes'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Deseas cerrar sesión?'),
            const SizedBox(height: 8),
            Text(
              'Correo: ${widget.userEmail}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar Sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    // Importar el servicio de sesión
    final navigator = Navigator.of(context);
    
    // Cerrar sesión
    await UserSession.logout();
    
    // Cerrar el diálogo
    navigator.pop();
    
    // Navegar al login
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

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
                    // Row superior: logo a la izquierda, selector de rol a la derecha
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          "assets/uni-logo.png",
                          height: 60,
                        ),
                        // Selector de rol y botón de ajustes
                        Row(
                          children: [
                            // Botón de ajustes
                            IconButton(
                              icon: const Icon(Icons.settings, color: Colors.white),
                              onPressed: () => _showSettingsDialog(context),
                            ),
                            const SizedBox(width: 8),
                            // Selector de rol (Profesor / Estudiante)
                            const Icon(Icons.person, color: Colors.white70),
                            const SizedBox(width: 8),
                            PopupMenuButton<UserRole>(
                              initialValue: _role,
                              color: Colors.white,
                              onSelected: _setRole,
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: UserRole.professor,
                                  child: Text('Profesor'),
                                ),
                                const PopupMenuItem(
                                  value: UserRole.student,
                                  child: Text('Estudiante'),
                                ),
                              ],
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _role == UserRole.professor
                                          ? 'Profesor'
                                          : 'Estudiante',
                                      style: const TextStyle(
                                          color: Colors.white),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.arrow_drop_down,
                                        color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    // Ahora el resto del header: avatar y nombre
                    const SizedBox.shrink(),

                    const SizedBox(height: 4),

                    // ...seguimos con la UI original
                    
                    
                    
                    
                    
                    
                    // Logo de la universidad
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

              // Fondo blanco para el contenido (según rol)
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
                    child: _role == UserRole.professor
                        ? LayoutBuilder(
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
                                      padding:
                                          const EdgeInsets.only(bottom: 30.0),
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
                          )
                        : StudentView(
                            // Pasamos colores/estilos si queremos mantener la esencia
                            primaryColor: AppColors.universityBlue,
                            accentColor: AppColors.universityLightBlue,
                            userEmail: widget.userEmail,
                            userType: widget.userType,
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
        "page": const MainScaffold(initialIndex: 0), // Cambio aquí
      },
      {
        "title": "Sesiones",
        "color": AppColors.universityPurple,
        "icon": Icons.star,
        "page": const MainScaffold(initialIndex: 1), // Cambio aquí
      },
      {
        "title": "Asistencias",
        "color": AppColors.universityLightBlue,
        "icon": Icons.check_circle,
        "page": const MainScaffold(initialIndex: 2), // Cambio aquí
      },
      {
        "title": "Dashboard",
        "color": AppColors.universityBlue,
        "icon": Icons.bar_chart,
        "page": const MainScaffold(initialIndex: 3), // Cambio aquí
      },
    ];
  }
}

/// Vista para estudiantes: lista de asistencias y barra de navegación
class StudentView extends StatefulWidget {
  final Color primaryColor;
  final Color accentColor;
  final String userEmail;
  final String userType;

  const StudentView({
    super.key,
    required this.primaryColor,
    required this.accentColor,
    this.userEmail = '',
    this.userType = 'estudiante',
  });

  @override
  State<StudentView> createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
  int _selectedIndex = 0;
  late PageController _pageController;

  // Datos de ejemplo (en producción reemplazar con datos reales)
  final List<Map<String, String>> _asistencias = List.generate(
    8,
    (i) => {
      'title': 'Asistencia #${i + 1}',
      'subtitle': 'Materia ${['Matemáticas','Algoritmos','Bases de datos','Redes'][i%4]} - ${['Lun','Mar','Mie'][i%3]}',
      'time': '08:${(10+i)%60}'.padLeft(2, '0'),
    },
  );

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == 999) {
      // home action: volver a selector de rol
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, a1, a2) => HomeScreen(
            userEmail: widget.userEmail,
            userType: widget.userType,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        (route) => false,
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PageView con páginas de estudiante
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _selectedIndex = i),
            children: [
              // Asistencias list
              _buildAsistenciasList(),
              // Calendario (placeholder)
              Center(child: Text('Calendario - en desarrollo')),
              // Notificaciones (placeholder)
              Center(child: Text('Notificaciones - en desarrollo')),
              // Perfil (placeholder)
              Center(child: Text('Perfil de usuario - en desarrollo')),
            ],
          ),
        ),

        // Reutilizar ModernBottomNav para coherencia visual
        ModernBottomNav(
          selectedIndex: _selectedIndex,
          primaryColor: widget.primaryColor,
          accentColor: widget.accentColor,
          onTap: _onNavTap,
        ),
      ],
    );
  }

  Widget _buildAsistenciasList() {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      itemCount: _asistencias.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final a = _asistencias[index];
        final gradient = LinearGradient(
          colors: [
            widget.primaryColor.withOpacity(0.12 + (index % 3) * 0.05),
            widget.accentColor.withOpacity(0.08 + (index % 4) * 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

        return InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Abriendo ${a['title']}')));
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: widget.primaryColor.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: widget.primaryColor.withOpacity(0.12), width: 1),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              leading: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [widget.accentColor, widget.primaryColor]),
                  boxShadow: [BoxShadow(color: widget.accentColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: const Icon(Icons.check, color: Colors.white),
              ),
              title: Text(a['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Row(children: [Expanded(child: Text(a['subtitle']!)), const SizedBox(width: 8), Chip(label: Text(a['time']!), backgroundColor: widget.primaryColor.withOpacity(0.12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))]),
              trailing: Icon(Icons.chevron_right, color: widget.primaryColor),
            ),
          ),
        );
      },
    );
  }
}
