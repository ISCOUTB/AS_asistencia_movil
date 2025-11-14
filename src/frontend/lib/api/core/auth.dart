import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'user_session.dart';
import '../universal_class.dart';


class AuthService extends ChangeNotifier {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? _accessToken;
  String? _idToken;
  String? _refreshToken;
  UserSession? currentUser;
  Map<String, dynamic>? _decodedToken;
  Timer? _refreshTimer;

  String? get accessToken => _accessToken;
  Map<String, dynamic>? get decodedToken => _decodedToken;

  /// Inicializa AuthService (carga sesión previa si existe)
  Future<void> init() async {
    debugPrint("------ AppAuth Init ------");
    debugPrint("Mode: ${kReleaseMode ? 'RELEASE' : 'DEBUG'}");

    _accessToken = await _secureStorage.read(key: 'accessToken');
    _refreshToken = await _secureStorage.read(key: 'refreshToken');
    _idToken = await _secureStorage.read(key: 'idToken');

    if (_accessToken != null) {
      // Verifica si aún es válido
      final expired = JwtDecoder.isExpired(_accessToken!);
      if (!expired) {
        _decodedToken = JwtDecoder.decode(_accessToken!);
        debugPrint("🔐 Sesión restaurada desde almacenamiento seguro.");
        _scheduleAutoRefresh();
      } else {
        debugPrint("⚠️ Token expirado, intentando loginSilent...");
        await loginSilent();
      }
    } else {
      debugPrint("ℹ️ No hay sesión previa guardada.");
    }

    debugPrint("--------------------------");
  }

  /// Login interactivo con Microsoft
  Future<bool> loginInteractive({List<String>? scopes}) async {
    final clientId = dotenv.env["MICROSOFT_CLIENT_ID"]!;
    final redirectUri = dotenv.env["MICROSOFT_REDIRECT_URI"]!;
    final tenantId = dotenv.env["MICROSOFT_TENANT_ID"]!;
    final discoveryUrl =
        "https://login.microsoftonline.com/$tenantId/v2.0/.well-known/openid-configuration";

    final useScopes = scopes ??
        [
          'openid',
          'profile',
          'email',
          'offline_access',
          'User.Read',
        ];

    try {
      final AuthorizationTokenResponse? result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUri,
          discoveryUrl: discoveryUrl,
          scopes: useScopes,
          promptValues: ['login'],
        ),
      );

      if (result != null) {
        await _saveTokens(result);
        debugPrint("✅ Login interactivo exitoso");
        return true;
      } else {
        debugPrint("⚠️ Login cancelado o sin respuesta.");
        return false;
      }
    } catch (e, s) {
      debugPrint("❌ Error en login interactivo: $e");
      debugPrint("Stack trace:\n$s");
      return false;
    }
  }

  /// Login silencioso usando refresh token
  Future<bool> loginSilent({List<String>? scopes}) async {
    final clientId = dotenv.env["MICROSOFT_CLIENT_ID"]!;
    final redirectUri = dotenv.env["MICROSOFT_REDIRECT_URI"]!;
    final tenantId = dotenv.env["MICROSOFT_TENANT_ID"]!;
    final discoveryUrl =
        "https://login.microsoftonline.com/$tenantId/v2.0/.well-known/openid-configuration";

    final useScopes = scopes ??
        [
          'openid',
          'profile',
          'email',
          'offline_access',
          'User.Read',
        ];

    if (_refreshToken == null) {
      debugPrint("⚠️ No hay refresh token. Debes iniciar sesión primero.");
      return false;
    }

    try {
      final TokenResponse? result = await _appAuth.token(
        TokenRequest(
          clientId,
          redirectUri,
          discoveryUrl: discoveryUrl,
          refreshToken: _refreshToken,
          scopes: useScopes,
        ),
      );

      if (result != null) {
        await _saveTokens(result);
        debugPrint("✅ Login silencioso exitoso");
        return true;
      } else {
        debugPrint("⚠️ Login silencioso fallido.");
        return false;
      }
    } catch (e, s) {
      debugPrint("❌ Error en login silencioso: $e");
      debugPrint("Stack trace:\n$s");
      return false;
    }
  }

  /// Guarda los tokens en memoria y en almacenamiento seguro
  Future<void> _saveTokens(TokenResponse result) async {
    _accessToken = result.accessToken;
    _idToken = result.idToken;
    _refreshToken = result.refreshToken ?? _refreshToken;

    if (_accessToken != null) {
      _decodedToken = JwtDecoder.decode(_accessToken!);
      debugPrint("🧩 Token decodificado: $_decodedToken");
      await _persistTokens();
      _scheduleAutoRefresh();
    }

    notifyListeners();
  }
  Future<UserSession?> loadUserData(BackendApi backend) async {
    final decoded = _decodedToken;
    if (decoded == null) return null;

    final name = decoded["name"] ?? "Usuario";
    final email = decoded["unique_name"];

    // Traer datos desde el backend
    final response = await backend.persona.getPersonaPorCorreo(email);

    final persona = response
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    currentUser = UserSession(
      name: name,
      email: email,
      uniqueName: email,
      expiration: decoded["exp"] != null
          ? DateTime.fromMillisecondsSinceEpoch(decoded["exp"] * 1000)
          : null,
      persona: persona,
    );
    
    notifyListeners();
    return currentUser;
  }


  /// Guarda los tokens cifrados en almacenamiento seguro
  Future<void> _persistTokens() async {
    await _secureStorage.write(key: 'accessToken', value: _accessToken);
    await _secureStorage.write(key: 'refreshToken', value: _refreshToken);
    await _secureStorage.write(key: 'idToken', value: _idToken);
  }

  /// Programa la renovación automática del token antes de expirar
  void _scheduleAutoRefresh() {
    _refreshTimer?.cancel();

    if (_accessToken == null) return;

    final expiration = JwtDecoder.getExpirationDate(_accessToken!);
    final now = DateTime.now();
    final duration = expiration.difference(now) - const Duration(minutes: 1);

    if (duration.isNegative) return;

    debugPrint("⏰ Token expira en ${duration.inMinutes} min, programando refresh automático.");

    _refreshTimer = Timer(duration, () async {
      debugPrint("🔄 Renovando token automáticamente...");
      await loginSilent();
    });
  }

  /// Logout local y limpieza del almacenamiento seguro
  Future<void> logout() async {
    _refreshTimer?.cancel();
    _accessToken = null;
    _idToken = null;
    _refreshToken = null;
    _decodedToken = null;

    await _secureStorage.deleteAll();
    notifyListeners();

    debugPrint("✅ Logout local y limpieza de tokens segura");
  }
}
