import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/notificacion.dart';

class NotificacionService extends ChangeNotifier {
  List<Notificacion> _notificaciones = [];
  int _noLeidas = 0;

  List<Notificacion> get notificaciones => _notificaciones;
  int get noLeidas => _noLeidas;

  // Cargar notificaciones desde SharedPreferences
  Future<void> cargarNotificaciones(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'notificaciones_$email';
      final String? data = prefs.getString(key);

      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data);
        _notificaciones = jsonList
            .map((json) => Notificacion.fromJson(json))
            .toList()
          ..sort((a, b) => b.fecha.compareTo(a.fecha)); // Más recientes primero

        _calcularNoLeidas();
        notifyListeners();
        debugPrint('✅ Notificaciones cargadas: ${_notificaciones.length} (${_noLeidas} no leídas)');
      } else {
        debugPrint('ℹ️ No hay notificaciones guardadas para $email');
      }
    } catch (e) {
      debugPrint('❌ Error cargando notificaciones: $e');
    }
  }

  // Guardar notificaciones
  Future<void> _guardarNotificaciones(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'notificaciones_$email';
      final jsonList = _notificaciones.map((n) => n.toJson()).toList();
      await prefs.setString(key, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('❌ Error guardando notificaciones: $e');
    }
  }

  // Agregar notificación
  Future<void> agregarNotificacion({
    required String email,
    required String tipo,
    required String titulo,
    required String mensaje,
    Map<String, dynamic>? datos,
  }) async {
    final notificacion = Notificacion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tipo: tipo,
      titulo: titulo,
      mensaje: mensaje,
      fecha: DateTime.now(),
      leida: false,
      datos: datos,
    );

    _notificaciones.insert(0, notificacion);
    _calcularNoLeidas();
    await _guardarNotificaciones(email);
    notifyListeners();

    debugPrint('🔔 Nueva notificación: $titulo');
  }

  // Marcar como leída
  Future<void> marcarComoLeida(String email, String idNotificacion) async {
    final index = _notificaciones.indexWhere((n) => n.id == idNotificacion);
    if (index != -1) {
      _notificaciones[index] = _notificaciones[index].copyWith(leida: true);
      _calcularNoLeidas();
      await _guardarNotificaciones(email);
      notifyListeners();
    }
  }

  // Marcar todas como leídas
  Future<void> marcarTodasComoLeidas(String email) async {
    _notificaciones = _notificaciones.map((n) => n.copyWith(leida: true)).toList();
    _calcularNoLeidas();
    await _guardarNotificaciones(email);
    notifyListeners();
  }

  // Eliminar notificación
  Future<void> eliminarNotificacion(String email, String idNotificacion) async {
    _notificaciones.removeWhere((n) => n.id == idNotificacion);
    _calcularNoLeidas();
    await _guardarNotificaciones(email);
    notifyListeners();
  }

  // Limpiar todas
  Future<void> limpiarTodas(String email) async {
    _notificaciones.clear();
    _noLeidas = 0;
    await _guardarNotificaciones(email);
    notifyListeners();
  }

  void _calcularNoLeidas() {
    _noLeidas = _notificaciones.where((n) => !n.leida).length;
  }

  // Crear notificación de sesión cancelada
  Future<void> notificarSesionCancelada({
    required String email,
    required String nombreSesion,
    required int idSesion,
  }) async {
    await agregarNotificacion(
      email: email,
      tipo: 'sesion_cancelada',
      titulo: 'Sesión Cancelada',
      mensaje: 'La sesión "$nombreSesion" ha sido cancelada por el profesor.',
      datos: {'id_sesion': idSesion},
    );
  }

  // Crear notificación de nueva sesión
  Future<void> notificarNuevaSesion({
    required String email,
    required String nombreSesion,
    required int idSesion,
    required String fecha,
  }) async {
    await agregarNotificacion(
      email: email,
      tipo: 'sesion_asignada',
      titulo: 'Nueva Sesión Disponible',
      mensaje: 'Tienes una nueva sesión: "$nombreSesion" el $fecha',
      datos: {'id_sesion': idSesion},
    );
  }
}
