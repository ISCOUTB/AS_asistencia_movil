import 'package:asistencia_movil/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
// No additional page imports required here; mantener solo lo necesario

class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 137, 99, 207);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
  static const backgroundLight = Color(0xFFF3F4F6);
}

// Datos de ejemplo para sesiones (temporal, puede reemplazarse por fuente real)
final List<Map<String, dynamic>> sesiones = [
  {
    "centro": "Centro de Innovación",
    "servicio": "Hackathon",
    "nombreSesion": "Sesiones P2 #1",
    "fecha": "04/AGO/2025",
    "horaInicio": "10:00AM",
    "horaFin": "10:20AM",
    "modalidad": "Presencial",
    "lugar": "AULA A2-204",
    "responsable": "mgomez@utb.edu.co",
    "facilitador": "Victoria Galvis",
  },
  {
    "centro": "Centro de Apoyo Académico",
    "servicio": "Tutorías",
    "nombreSesion": "Sesión de Tutoría",
    "fecha": "28/ABR/2025",
    "horaInicio": "12:00PM",
    "horaFin": "02:00PM",
    "modalidad": "Remoto",
    "lugar": "Online",
    "responsable": "medina@utb.edu.co",
    "facilitador": "jormercado@utb.edu.co",
  },
];

// Clase original para navegación directa (mantener para compatibilidad)
class SesionesPage extends StatelessWidget {
  SesionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SesionesPageContent();
  }
}

// Nuevo widget solo con contenido para usar en MainScaffold
class SesionesPageContent extends StatefulWidget {
  SesionesPageContent({super.key});

  @override
  State<SesionesPageContent> createState() => _SesionesPageContentState();
}

class _SesionesPageContentState extends State<SesionesPageContent> {
  // Mantener estado de asistencias aplicadas por índice
  final Map<int, String> _attendance = {};

  static const String _prefsKey = 'attendance_map';

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null && raw.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(raw);
        // Convert keys back to int
        _attendance.clear();
        decoded.forEach((k, v) {
          final intKey = int.tryParse(k);
          if (intKey != null && v is String) {
            _attendance[intKey] = v;
          }
        });
        if (mounted) setState(() {});
      }
    } catch (e) {
      // ignore errors silently for now but could log
    }
  }

  Future<void> _saveAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Map<int,String> -> Map<String,String>
      final Map<String, String> toStore = {};
      _attendance.forEach((k, v) => toStore[k.toString()] = v);
      await prefs.setString(_prefsKey, jsonEncode(toStore));
    } catch (e) {
      // ignore for now
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Sesiones"),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.universityPurple,
                AppColors.universityBlue,
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Encabezado
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.universityPurple,
                  AppColors.universityBlue,
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Image.asset(
                  "assets/uni-logo.png",
                  height: 50,
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    "Mis Sesiones Asignadas",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Botones de acción superiores
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildActionButton(
                  icon: Icons.visibility,
                  label: "Ver",
                  color: AppColors.universityLightBlue,
                  onPressed: () {},
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.refresh,
                  label: "Actualizar",
                  color: AppColors.universityPurple,
                  onPressed: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Lista de sesiones (tarjetas) — reemplaza la tabla por cards más amigables
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20), // Menos espacio para la barra persistente
                  child: _buildSessionList(context),
            ),
          ),

          // Botones de acción inferiores
          Container(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20), // Menos espacio para la barra persistente
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.edit,
                  label: "Editar",
                  color: AppColors.universityBlue,
                  onPressed: () {},
                ),
                _buildActionButton(
                  icon: Icons.delete,
                  label: "Eliminar",
                  color: Colors.red,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper para colores según la modalidad
  Color _getModalidadColor(String modalidad) {
    final m = modalidad.toLowerCase();
    if (m.contains('presencial')) return Colors.green.shade600;
    if (m.contains('remoto') || m.contains('virtual') || m.contains('online')) return Colors.blue.shade600;
    return Colors.grey.shade600;
  }

  /// Botón de acción estilizado
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  

  /// Lista reemplazo para sesiones: tarjetas interactivas
  Widget _buildSessionList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      itemCount: sesiones.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final s = sesiones[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.universityLightBlue,
              child: const Icon(Icons.event_note, color: Colors.white),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    s['nombreSesion'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (_attendance.containsKey(index))
                  Chip(
                    label: Text(_attendance[index]!, overflow: TextOverflow.ellipsis),
                    backgroundColor: AppColors.universityBlue.withOpacity(0.12),
                    labelStyle: const TextStyle(color: AppColors.universityBlue),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  '${s['servicio']} · ${s['centro']}',
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Use Wrap so small screens don't overflow horizontally
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getModalidadColor(s['modalidad'] ?? ''),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(s['modalidad'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    Text(
                      '${s['fecha']} • ${s['horaInicio']} - ${s['horaFin']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if ((s['lugar'] ?? '').isNotEmpty)
                      Chip(
                        label: Text(s['lugar'] ?? '', style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.grey.shade100,
                      ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.qr_code_2_outlined),
                  color: AppColors.universityBlue,
                  onPressed: () {
                    // Generar QR con datos de la sesión (ejemplo: nombre + fecha)
                    final qrData = '${s['nombreSesion'] ?? ''} | ${s['fecha'] ?? ''}';
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Código QR de la sesión'),
                        content: SizedBox(
                          width: 200,
                          height: 200,
                          child: Center(
                            child: QrImageView(
                              data: qrData,
                              size: 180.0,
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
                        ],
                      ),
                    );
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'llenar') {
                      _showFillAttendanceDialog(context, index);
                    } else if (value == 'detalles') {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Detalles de ${s['nombreSesion']}')));
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'llenar', child: Text('Llenar asistencia')),
                    const PopupMenuItem(value: 'detalles', child: Text('Ver detalles')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Dialogo similar al mockup para llenar asistencia
  void _showFillAttendanceDialog(BuildContext context, int sessionIndex) {
    String? _selected = _attendance[sessionIndex];
    showDialog(
      context: context,
      builder: (context) {
        // Use dialogSetState to avoid shadowing the parent setState
        return StatefulBuilder(builder: (context, dialogSetState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text('Llenar Asistencia', style: TextStyle(color: AppColors.universityBlue)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Seleccionar tipo de asistencia'),
                const SizedBox(height: 8),
                RadioListTile<String>(
                  title: const Text('Presente'),
                  value: 'Presente',
                  groupValue: _selected,
                  onChanged: (v) => setState(() => _selected = v),
                ),
                RadioListTile<String>(
                  title: const Text('Ausente'),
                  value: 'Ausente',
                  groupValue: _selected,
                  onChanged: (v) => setState(() => _selected = v),
                ),
                RadioListTile<String>(
                  title: const Text('Falta Justificada'),
                  value: 'Falta Justificada',
                  groupValue: _selected,
                  onChanged: (v) => dialogSetState(() => _selected = v),
                ),
                RadioListTile<String>(
                  title: const Text('Falta Injustificada'),
                  value: 'Falta Injustificada',
                  groupValue: _selected,
                  onChanged: (v) => dialogSetState(() => _selected = v),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Cancelar'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (_selected == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione una opción')));
                    return;
                  }
                  // Actualizar el estado del padre y persistir
                  setState(() {
                    _attendance[sessionIndex] = _selected!;
                  });
                  _saveAttendance();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Asistencia registrada: $_selected')));
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Aplicar'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.universityBlue),
              ),
            ],
          );
        });
      },
    );
  }
}

// En lugar de navegar a páginas individuales:
// Utiliza esta función para navegar desde un callback, por ejemplo en un botón.
void navegarAMainScaffold(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const MainScaffold(initialIndex: 0), // 0=Servicios, 1=Sesiones, 2=Asistencias, 3=Dashboard
    ),
  );
}