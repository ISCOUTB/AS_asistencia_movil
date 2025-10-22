class UserModel {
  final int id;
  final String nombre;
  final String email;
  final String? identificacion;
  final String? codigoBanner;
  final String? tipoIdentificacion;
  final String rol;
  final int? facilitadorId;
  final String? telefono;
  final String? departamento;

  UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    this.identificacion,
    this.codigoBanner,
    this.tipoIdentificacion,
    required this.rol,
    this.facilitadorId,
    this.telefono,
    this.departamento,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      identificacion: json['identificacion'],
      codigoBanner: json['codigo_banner'],
      tipoIdentificacion: json['tipo_identificacion'],
      rol: json['rol'] ?? 'estudiante',
      facilitadorId: json['facilitador_id'],
      telefono: json['telefono'],
      departamento: json['departamento'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'identificacion': identificacion,
      'codigo_banner': codigoBanner,
      'tipo_identificacion': tipoIdentificacion,
      'rol': rol,
      'facilitador_id': facilitadorId,
      'telefono': telefono,
      'departamento': departamento,
    };
  }

  bool get esProfesor => rol == 'profesor';
  bool get esEstudiante => rol == 'estudiante';
}
