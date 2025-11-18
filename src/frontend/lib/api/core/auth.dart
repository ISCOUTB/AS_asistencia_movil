import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'user_session.dart';
import '../routes/persona_service.dart';
import '../routes/facilitador_service.dart';


class AuthService extends ChangeNotifier {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  late PersonaService personaService;
  late FacilitadorService facilitadorService;


  String? _accessToken;
  String? _idToken;
  String? _refreshToken;
  UserSession? currentUser;
  Map<String, dynamic>? _decodedToken;
  Timer? _refreshTimer;
  
  // ✅ OPTIMIZACIÓN: Cachear configuración de autenticación
  String? _cachedDiscoveryUrl;
  String? _cachedClientId;
  String? _cachedRedirectUri;
  String? _cachedTenantId;

  String? get accessToken => _accessToken;
  Map<String, dynamic>? get decodedToken => _decodedToken;

  /// Inicializa AuthService (carga sesión previa si existe)
  Future<void> init() async {
    debugPrint("------ AppAuth Init ------");
    debugPrint("Mode: ${kReleaseMode ? 'RELEASE' : 'DEBUG'}");
    
    // ✅ OPTIMIZACIÓN: Cachear configuración de autenticación una sola vez
    _cachedClientId = dotenv.env["MICROSOFT_CLIENT_ID"]!;
    _cachedRedirectUri = dotenv.env["MICROSOFT_REDIRECT_URI"]!;
    _cachedTenantId = dotenv.env["MICROSOFT_TENANT_ID"]!;
    _cachedDiscoveryUrl = "https://login.microsoftonline.com/$_cachedTenantId/v2.0/.well-known/openid-configuration";

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
    // ✅ OPTIMIZACIÓN: Usar configuración cacheada en lugar de leer dotenv cada vez
    final clientId = _cachedClientId ?? dotenv.env["MICROSOFT_CLIENT_ID"]!;
    final redirectUri = _cachedRedirectUri ?? dotenv.env["MICROSOFT_REDIRECT_URI"]!;
    final tenantId = _cachedTenantId ?? dotenv.env["MICROSOFT_TENANT_ID"]!;
    final discoveryUrl = _cachedDiscoveryUrl ?? 
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
      // ✅ OPTIMIZACIÓN: Configuración adicional para mejorar rendimiento
      final AuthorizationTokenResponse? result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUri,
          discoveryUrl: discoveryUrl,
          scopes: useScopes,
          promptValues: ['login'],
          // ✅ Configuraciones adicionales para optimizar
          allowInsecureConnections: false, // Mantener seguridad
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
      
      // ✅ OPTIMIZACIÓN: Notificar listeners primero para UI inmediata
      notifyListeners();
      
      // ✅ OPTIMIZACIÓN: Guardar tokens en background sin bloquear
      _persistTokens(); // No await - se ejecuta en background
      _scheduleAutoRefresh();
    }
  }

  // Versión robusta de loadUserData para auth.dart
  Future<UserSession?> loadUserData() async {
    personaService = PersonaService(
      'https://ga7a0b6c9043600-atpdb.adb.us-phoenix-1.oraclecloudapps.com/ords/ecoutb_workspace/personas/',
    );
    facilitadorService = FacilitadorService(
      'https://ga7a0b6c9043600-atpdb.adb.us-phoenix-1.oraclecloudapps.com/ords/ecoutb_workspace/facilitadores/',
    );
    
    final decoded = _decodedToken;
    if (decoded == null) return null;

    final String name = decoded['name'] ?? 'Usuario';

    final dynamic uniqueName = decoded['unique_name'];
    if (uniqueName == null || uniqueName is! String) {
      debugPrint('loadUserData: unique_name ausente o inválido en token');
      return null;
    }
    final String email = uniqueName;

    // 🔥 NUEVA LÓGICA: Obtener el ID real desde el backend
    int? realId;
    List<Map<String, dynamic>> persona = [];
    bool isFacilitador = false;

    // Parse exp de forma segura (podría ser null, int, double, string)
    int? expSeconds;
    final dynamic rawExp = decoded['exp'];
    if (rawExp != null) {
      if (rawExp is num) {
        expSeconds = rawExp.toInt();
      } else {
        expSeconds = int.tryParse(rawExp.toString());
      }
    }
    final DateTime? expiration =
        expSeconds != null ? DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000) : null;

    // Intentar facilitador primero; si no hay resultados, intentar persona.
    try {
      final facilItems = await facilitadorService.getFacilitadorPorCorreo(email);
      if (facilItems.isNotEmpty) {
        isFacilitador = true;
        persona = facilItems
            .where((e) => e is Map)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        
        // 🔥 OBTENER EL ID REAL DEL FACILITADOR desde el backend
        if (persona.isNotEmpty) {
          final firstFacilitador = persona[0];
          // Intentar obtener el ID con diferentes nombres de campo posibles
          if (firstFacilitador.containsKey('id')) {
            final rawId = firstFacilitador['id'];
            realId = (rawId is int) ? rawId : int.tryParse(rawId.toString());
          } else if (firstFacilitador.containsKey('id_facilitador')) {
            final rawId = firstFacilitador['id_facilitador'];
            realId = (rawId is int) ? rawId : int.tryParse(rawId.toString());
          } else if (firstFacilitador.containsKey('correo_institucional')) {
            // Si no hay ID numérico, usar el email como identificador
            realId = null;
          }
          debugPrint('✅ ID del facilitador obtenido desde backend: $realId');
        }
      } else {
        // Si facilitador devuelve vacío, intentar persona
        try {
          final personaItems = await personaService.getPersonaPorCorreo(email);
          persona = personaItems
              .where((e) => e is Map)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          
          // 🔥 OBTENER EL ID REAL DE LA PERSONA desde el backend
          if (persona.isNotEmpty) {
            final firstPersona = persona[0];
            if (firstPersona.containsKey('id')) {
              final rawId = firstPersona['id'];
              realId = (rawId is int) ? rawId : int.tryParse(rawId.toString());
            } else if (firstPersona.containsKey('id_persona')) {
              final rawId = firstPersona['id_persona'];
              realId = (rawId is int) ? rawId : int.tryParse(rawId.toString());
            }
            debugPrint('✅ ID de la persona obtenido desde backend: $realId');
          }
        } catch (e, st) {
          debugPrint('loadUserData: error al obtener persona (fallback): $e\n$st');
          // dejamos persona vacía; puedes decidir return null si lo prefieres
        }
      }
    } catch (e, st) {
      debugPrint('loadUserData: error al obtener facilitador: $e\n$st');
      // Fallback: intentar persona si facilitador falló
      try {
        final personaItems = await personaService.getPersonaPorCorreo(email);
        persona = personaItems
            .where((e) => e is Map)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        
        // 🔥 OBTENER EL ID REAL DE LA PERSONA desde el backend
        if (persona.isNotEmpty) {
          final firstPersona = persona[0];
          if (firstPersona.containsKey('id')) {
            final rawId = firstPersona['id'];
            realId = (rawId is int) ? rawId : int.tryParse(rawId.toString());
          } else if (firstPersona.containsKey('id_persona')) {
            final rawId = firstPersona['id_persona'];
            realId = (rawId is int) ? rawId : int.tryParse(rawId.toString());
          }
          debugPrint('✅ ID de la persona obtenido desde backend (fallback): $realId');
        }
      } catch (e2, st2) {
        debugPrint('loadUserData: error al obtener persona tras fallo facilitador: $e2\n$st2');
        return null; // ambas llamadas fallaron -> no podemos cargar usuario
      }
    }

    currentUser = UserSession(
      id: realId,  // 🔥 AHORA TIENE EL ID REAL DEL BACKEND
      name: name,
      email: email,
      uniqueName: email,
      expiration: expiration,
      persona: persona,
      isFacilitador: isFacilitador,
    );

    debugPrint('🔐 UserSession creado - ID: $realId, Email: $email, Es Facilitador: $isFacilitador');
    
    notifyListeners();
    return currentUser;
  }


  /// Guarda los tokens cifrados en almacenamiento seguro
  Future<void> _persistTokens() async {
    // ✅ OPTIMIZACIÓN: Ejecutar escrituras en paralelo en lugar de secuencial
    await Future.wait([
      _secureStorage.write(key: 'accessToken', value: _accessToken),
      _secureStorage.write(key: 'refreshToken', value: _refreshToken),
      _secureStorage.write(key: 'idToken', value: _idToken),
    ]);
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
