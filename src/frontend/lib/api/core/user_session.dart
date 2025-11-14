class UserSession {
  final String name;
  final String email;
  final String uniqueName;
  final DateTime? expiration;
  final List<Map<String, dynamic>> persona;   // Datos desde el backend (APEX)

  UserSession({
    required this.name,
    required this.email,
    required this.uniqueName,
    required this.expiration,
    required this.persona
  });
}
