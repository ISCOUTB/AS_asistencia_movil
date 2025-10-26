class UserModel {
  final String email;
  final String nombre;
  final String? carrera;
  final String? departamento;
  final String rol; // 'estudiante' o 'profesor'
  final int? personaId;
  final int? facilitadorId;
  final String? identificacion;
  
  UserModel({
    required this.email,
    required this.nombre,
    this.carrera,
    this.departamento,
    required this.rol,
    this.personaId,
    this.facilitadorId,
    this.identificacion,
  });
  
  Map<String, dynamic> toJson() => {
    'email': email,
    'nombre': nombre,
    'carrera': carrera,
    'departamento': departamento,
    'rol': rol,
    'personaId': personaId,
    'facilitadorId': facilitadorId,
    'identificacion': identificacion,
  };
  
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    email: json['email'],
    nombre: json['nombre'],
    carrera: json['carrera'],
    departamento: json['departamento'],
    rol: json['rol'],
    personaId: json['personaId'],
    facilitadorId: json['facilitadorId'],
    identificacion: json['identificacion'],
  );
}