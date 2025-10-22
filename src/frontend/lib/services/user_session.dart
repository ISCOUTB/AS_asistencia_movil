import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserSession {
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'access_token';
  static const String _isLoggedInKey = 'is_logged_in';
  
  // Guardar usuario en sesión
  static Future<void> saveUser(UserModel user, String? accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
    
    if (accessToken != null) {
      await prefs.setString(_tokenKey, accessToken);
    }
  }
  
  // Obtener usuario actual
  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }
  
  // Obtener token de acceso
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  // Verificar si hay sesión activa
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }
  
  // Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
    await prefs.setBool(_isLoggedInKey, false);
  }
  
  // Obtener rol del usuario
  static Future<String?> getUserRole() async {
    final user = await getCurrentUser();
    return user?.rol;
  }
}
