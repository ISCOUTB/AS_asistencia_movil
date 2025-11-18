class Notificacion {
  final String id;
  final String tipo; // 'sesion_asignada', 'sesion_cancelada', 'recordatorio'
  final String titulo;
  final String mensaje;
  final DateTime fecha;
  final bool leida;
  final Map<String, dynamic>? datos; // Datos adicionales (id_sesion, etc.)

  Notificacion({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.fecha,
    this.leida = false,
    this.datos,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'].toString(),
      tipo: json['tipo'] ?? 'general',
      titulo: json['titulo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
      leida: json['leida'] == true || json['leida'] == 1,
      datos: json['datos'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'titulo': titulo,
      'mensaje': mensaje,
      'fecha': fecha.toIso8601String(),
      'leida': leida ? 1 : 0,
      'datos': datos,
    };
  }

  Notificacion copyWith({bool? leida}) {
    return Notificacion(
      id: id,
      tipo: tipo,
      titulo: titulo,
      mensaje: mensaje,
      fecha: fecha,
      leida: leida ?? this.leida,
      datos: datos,
    );
  }
}
