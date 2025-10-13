import 'dart:convert';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

/// Servicio para manejar la autenticación con Microsoft 365 (Azure AD v2.0)
class MicrosoftAuthService {
  final String clientId = dotenv.env['MICROSOFT_CLIENT_ID'] ?? '';
  final String tenantId = dotenv.env['MICROSOFT_TENANT_ID'] ?? '';
  final String clientSecret = dotenv.env['MICROSOFT_CLIENT_SECRET'] ?? '';
  final String redirectUri = dotenv.env['MICROSOFT_REDIRECT_URI'] ?? '';
  final String scopes = dotenv.env['MICROSOFT_SCOPES'] ?? 'openid profile email';

  String get authority => "https://login.microsoftonline.com/$tenantId";
  String get tokenUrl => "$authority/oauth2/v2.0/token";
  String get jwksUri => "$authority/discovery/v2.0/keys";

  /// Inicia el flujo de autenticación de Microsoft 365
  Future<Map<String, dynamic>?> signInWithMicrosoft() async {
    try {
      final url =
          "$authority/oauth2/v2.0/authorize?client_id=$clientId&response_type=code"
          "&redirect_uri=$redirectUri&response_mode=query&scope=$scopes";

      // Abre el navegador para el inicio de sesión
      final result = await FlutterWebAuth2.authenticate(
        url: url,
        callbackUrlScheme: Uri.parse(redirectUri).scheme,
      );

      // Extrae el código de autorización
      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) throw Exception('No se recibió el código de autorización.');

      // Intercambia el código por los tokens
      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
          'scope': scopes,
        },
      );

      final data = jsonDecode(response.body);
      if (data['id_token'] == null) {
        throw Exception("Error al obtener el id_token: ${data.toString()}");
      }

      // Decodifica el token JWT
      final claims = JwtDecoder.decode(data['id_token']);

      return {
        "success": true,
        "access_token": data['access_token'],
        "id_token": data['id_token'],
        "user": {
          "name": claims["name"],
          "email": claims["preferred_username"],
          "oid": claims["oid"],
        },
        "claims": claims,
      };
    } catch (e) {
      print("Error en signInWithMicrosoft: $e");
      return {"success": false, "error": e.toString()};
    }
  }

  /// Verifica localmente un token JWT
  Future<Map<String, dynamic>> validateToken(String idToken) async {
    try {
      final jwksResponse = await http.get(Uri.parse(jwksUri));
      if (jwksResponse.statusCode != 200) {
        throw Exception('Error al obtener las claves públicas de Microsoft');
      }

      // Decodificar sin validación criptográfica (validación básica cliente)
      final claims = JwtDecoder.decode(idToken);

      // Verifica expiración
      if (JwtDecoder.isExpired(idToken)) {
        throw Exception("El token ha expirado.");
      }

      return {
        "valid": true,
        "claims": claims,
      };
    } catch (e) {
      return {
        "valid": false,
        "error": e.toString(),
      };
    }
  }
}
