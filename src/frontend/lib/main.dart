import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'api/core/auth.dart';
import 'api/universal_class.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno (.env)
  await dotenv.load(fileName: "assets/.env");

  // Inicializar AuthService
  final authService = AuthService();
  await authService.init();

  // Inicializar BackendApi
  final baseUrl = dotenv.env["URL_MAIN"];
  if (baseUrl == null) {
    throw Exception("La variable URL_MAIN no se pudo cargar. Revisa el archivo .env");
  } 
  final backendApi = BackendApi(baseUrl);

  // si ya hay sesión cargada (token válido), cargamos info del usuario
  if (authService.accessToken != null) {
    await authService.loadUserData(backendApi);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),
        Provider<BackendApi>.value(value: backendApi),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asistencias UTB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
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
      return const LoginScreen();
    } else {
      return const HomeScreen();
    }
  }
}

/// Pantalla de Login
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final backend = Provider.of<BackendApi>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Inicio de Sesión")),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text("Iniciar sesión con Microsoft"),
          onPressed: () async {
            final success = await auth.loginInteractive();
            if (success && context.mounted) {
              // 👉 Cargar datos desde backend una vez autenticado
              await auth.loadUserData(backend);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Error al iniciar sesión.")),
              );
            }
          },
        ),
      ),
    );
  }
}

/// Pantalla principal (Home)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final backend = Provider.of<BackendApi>(context, listen: false);
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bienvenido a Asistencias UTB"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: user == null
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_user,
                        size: 80, color: Colors.indigo),
                    const SizedBox(height: 16),
                    Text(
                      "Hola, ${user.name} 👋",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),

                    // 👉 Mostrar datos desde Oracle APEX (persona)
                    if (user.persona.isNotEmpty)
                      Text(
                        "Codigo_Banner: ${user.persona.first["codigo_banner"]}",
                        style: const TextStyle(fontSize: 16),
                      )
                    else
                      const Text(
                        "No se encontró información en el backend.",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}