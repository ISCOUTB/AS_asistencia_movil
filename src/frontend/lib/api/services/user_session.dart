import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserSession {
  static const String _userKey = 'current_user';
  static const String _idTokenKey = 'id_token';
  static const String _accessTokenKey = 'access_token';
  
  /// Guardar sesión de usuario
  static Future<void> saveSession({
    required UserModel user,
    required String idToken,
    required String accessToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setString(_idTokenKey, idToken);
    await prefs.setString(_accessTokenKey, accessToken);
  }
  
  /// Obtener usuario actual
  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson != null) {
      final userData = jsonDecode(userJson);
      // Asegurar que el rol esté presente
      userData['rol'] = userData['rol'] ?? 'estudiante';
      return UserModel.fromJson(userData);
    }
    
    return null;
  }
  
  /// Verificar si hay sesión activa
  static Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }
  
  /// Obtener rol del usuario
  static Future<String?> getUserRole() async {
    final user = await getCurrentUser();
    return user?.rol;
  }
  
  /// Obtener ID del usuario
  static Future<int?> getUserId() async {
    final user = await getCurrentUser();
    return user?.id;
  }
  
  /// Obtener email del usuario
  static Future<String?> getUserEmail() async {
    final user = await getCurrentUser();
    return user?.email;
  }
  
  /// Obtener tokens
  static Future<Map<String, String?>> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'idToken': prefs.getString(_idTokenKey),
      'accessToken': prefs.getString(_accessTokenKey),
    };
  }
  
  /// Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_idTokenKey);
    await prefs.remove(_accessTokenKey);
  }
  
  /// Actualizar usuario (por ejemplo, después de editar perfil)
  static Future<void> updateUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
}
