import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'api/core/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga las variables de entorno (.env)
  await dotenv.load(fileName: "assets/.env");

  // Inicializa el servicio de autenticación
  final authService = AuthService();
  await authService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => authService,
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

/// Pantalla de Login con Microsoft
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Inicio de Sesión")),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text("Iniciar sesión con Microsoft"),
          onPressed: () async {
            final success = await auth.loginInteractive();
            if (success && context.mounted) {
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

/// Pantalla principal después del login
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    final decoded = auth.decodedToken;
    final name = decoded?['name'] ?? 'Usuario desconocido';
    final email = decoded?['preferred_username'] ?? 'Sin correo';
    final exp = decoded?['exp'] != null
        ? DateTime.fromMillisecondsSinceEpoch(decoded!['exp'] * 1000)
        : null;

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
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user, size: 80, color: Colors.indigo),
              const SizedBox(height: 16),
              Text(
                "Hola, $name 👋",
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (exp != null)
                Text(
                  "⏳ Token expira el:\n${exp.toLocal()}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                "Access Token (recortado):\n${auth.accessToken?.substring(0, 40)}...",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
