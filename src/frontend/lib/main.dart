import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'inicio_app_facilitador.dart' as app_facilitador;
import 'package:provider/provider.dart';
import 'api/core/user_session_provider.dart';
import 'api/core/auth.dart';
import 'api/notificacion_service.dart';
import 'main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: "assets/.env");
  } catch (e) {
    debugPrint("Advertencia: No se pudo cargar .env - $e");
  }
  
  final authService = AuthService();
  await authService.init();

  if (authService.accessToken != null) {
    await authService.loadUserData();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),
        ChangeNotifierProvider(create: (_) => UserSessionProvider()),
        ChangeNotifierProvider(create: (_) => NotificacionService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTB Assists',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
    );
  }
}

/// Decide si mostrar login o home según estado de sesión
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    if (auth.accessToken == null) {
      return LoginPage();
    } else {
      final user = auth.currentUser;
      context.read<UserSessionProvider>().setSession(user);
      
      // Si el usuario está cargado, redirigir según su rol
      if (user != null && user.persona.isNotEmpty) {
        if (user.isFacilitador) {
          // Usuario es facilitador/profesor
          return app_facilitador.HomeScreen(
            userEmail: user.email,
            userID: user.id,
            userType: 'profesor',
          );
        } else {
          // Usuario es estudiante - usar MainScaffold con barra de navegación
          return const MainScaffold(
            initialIndex: 0,
            isStudent: true,
          );
        }
      }
      
      // Si aún no se ha cargado el usuario, mostrar pantalla de carga
      return const LoadingScreen();
    }
  }
}

/// Pantalla de carga mientras se obtienen los datos del usuario
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Cargando información del usuario...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
  
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final auth = Provider.of<AuthService>(context, listen: false);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo y título
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      size: 64,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  SizedBox(height: 32),
                  Text(
                    'UTB Assists',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sistema de Asistencias',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: 64),
                  
                  // Card de información
                  Card(
                    elevation: 0,
                    color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: colorScheme.onSecondaryContainer,
                            size: 24,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Inicia sesión con tu cuenta institucional de Microsoft 365',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSecondaryContainer,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Mensaje de error
                  if (_errorMessage != null) ...[
                    Card(
                      elevation: 0,
                      color: colorScheme.errorContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: colorScheme.onErrorContainer,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                  
                  // Botón de inicio de sesión
                  FilledButton.icon(
                    onPressed: _isLoading
                    ? null
                    : () async {
                        // ✅ OPTIMIZACIÓN: Actualizar UI INMEDIATAMENTE antes de cualquier operación
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        
                        // ✅ OPTIMIZACIÓN: Dar tiempo al UI para renderizar antes de bloquear con auth
                        await Future.delayed(const Duration(milliseconds: 50));

                        String? localError;
                        bool loginSuccess = false;
                        try {
                          loginSuccess = await auth.loginInteractive();

                          if (loginSuccess) {
                            // Carga datos del usuario
                            final user = await auth.loadUserData();
                            if (user == null) {
                              localError = 'No se pudo cargar los datos del usuario.';
                            }
                            // No necesitamos hacer nada más aquí,
                            // AuthWrapper se encargará de redirigir automáticamente
                          } else {
                            localError = 'No se pudo iniciar sesión.';
                          }
                        } catch (e, st) {
                          debugPrint('$e\n$st');
                          localError = 'Error inesperado: $e';
                        }

                        // Al terminar, sólo actualizar el estado si el widget sigue montado
                        if (!mounted) return;
                        setState(() {
                          _isLoading = false;
                          _errorMessage = localError;
                        });
                      },
                    icon: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.login_rounded),
                    label: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        _isLoading ? 'Iniciando sesión...' : 'Iniciar sesión con Microsoft 365',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                  ),

                  
                  SizedBox(height: 40),
                  
                  // Versión
                  Text(
                    'Versión 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}