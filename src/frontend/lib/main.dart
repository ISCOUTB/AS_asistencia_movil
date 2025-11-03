import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api/core/auth.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Microsoft Auth Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final MicrosoftAuthService _authService = MicrosoftAuthService();
  String status = "Esperando autenticación...";

  void _signIn() async {
    setState(() => status = "Abriendo inicio de sesión...");
    final result = await _authService.signInWithMicrosoft();
    setState(() => status = result?["success"] == true
        ? "✅ Bienvenido: ${result!["user"]["name"]}"
        : "❌ Error: ${result?["error"]}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login con Microsoft 365")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _signIn,
              child: Text("Iniciar sesión con Microsoft"),
            ),
            SizedBox(height: 20),
            Text(status, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
