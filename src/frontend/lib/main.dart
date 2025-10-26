import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'inicio_app.dart';
import 'api/core/auth.dart';
import 'api/services/user_session.dart';
import 'api/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Advertencia: No se pudo cargar .env - $e");
  }
  
  runApp(MyApp());
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
      home: FutureBuilder<bool>(
        future: UserSession.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.data == true) {
            return FutureBuilder<UserModel?>(
              future: UserSession.getCurrentUser(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                
                final user = userSnapshot.data;
                if (user != null) {
                  return InicioApp(
                    userEmail: user.email,
                    userType: user.rol,
                  );
                }
                
                return LoginPage();
              },
            );
          }
          
          return LoginPage();
        },
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

  Future<void> _loginWithMicrosoft() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = MicrosoftAuthService();
      final authResult = await authService.signInWithMicrosoft();

      if (authResult == null || !(authResult['success'] ?? false)) {
        throw Exception(authResult?['error'] ?? 'No se pudo autenticar con Microsoft 365');
      }

      final userData = authResult['user'];
      // Si no hay rol, asigna uno por defecto o según lógica de negocio
      userData['rol'] = userData['rol'] ?? 'usuario';
      final user = UserModel.fromJson(userData);

      await UserSession.saveSession(
        user: user,
        idToken: authResult['id_token'] ?? '',
        accessToken: authResult['access_token'] ?? '',
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InicioApp(
              userEmail: user.email,
              userType: user.rol,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.secondary.withOpacity(0.05),
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
                          color: colorScheme.primary.withOpacity(0.3),
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
                    color: colorScheme.secondaryContainer.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: colorScheme.outline.withOpacity(0.2),
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
                    onPressed: _isLoading ? null : _loginWithMicrosoft,
                    icon: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
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
                          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
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