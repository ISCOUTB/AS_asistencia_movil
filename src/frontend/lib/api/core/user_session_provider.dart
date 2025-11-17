import 'package:flutter/material.dart';
import 'user_session.dart';

class UserSessionProvider extends ChangeNotifier {
  UserSession? _session;

  UserSession? get session => _session;

  int? get id => _session?.id;
  String get nombre => _session?.name ?? "";
  String get email => _session?.email ?? "";
  bool get esFacilitador => _session?.isFacilitador ?? false;

  List<Map<String, dynamic>> get persona => _session?.persona ?? [];

  void setSession(UserSession? session) {
    _session = session;
    notifyListeners();
  }

  void clearSession() {
    _session = null;
    notifyListeners();
  }
}
