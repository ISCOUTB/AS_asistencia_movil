import 'package:asistencia_movil/main_scaffold.dart';
import 'package:flutter/material.dart';

class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 137, 99, 207);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
  static const backgroundLight = Color(0xFFF3F4F6);
}

// Página de Asistencias con lista y filtros simples
class AsistenciasPage extends StatelessWidget {
  const AsistenciasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AsistenciasPageContent();
  }
}

class AsistenciasPageContent extends StatefulWidget {
  const AsistenciasPageContent({super.key});

  @override
  State<AsistenciasPageContent> createState() => _AsistenciasPageContentState();
}

class _AsistenciasPageContentState extends State<AsistenciasPageContent> {
  String _filter = 'Todas';

  final List<Map<String, String>> _asistencias = List.generate(10, (i) => {
        'titulo': 'Asistencia ${i + 1}',
        'materia': ['Matemáticas', 'Algoritmos', 'Redes', 'Bases'][i % 4],
        'fecha': '2025-0${(i % 9) + 1}-0${(i % 28) + 1}',
        'estado': ['Presente', 'Ausente', 'Justificada'][i % 3],
      });

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'Todas' ? _asistencias : _asistencias.where((a) => a['estado'] == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencias'),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.universityPurple, AppColors.universityBlue],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Expanded(child: Text('Historial de Asistencias', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _filter,
                  items: const [
                    DropdownMenuItem(value: 'Todas', child: Text('Todas')),
                    DropdownMenuItem(value: 'Presente', child: Text('Presente')),
                    DropdownMenuItem(value: 'Ausente', child: Text('Ausente')),
                    DropdownMenuItem(value: 'Justificada', child: Text('Justificada')),
                  ],
                  onChanged: (v) => setState(() => _filter = v ?? 'Todas'),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final a = filtered[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: CircleAvatar(backgroundColor: AppColors.universityBlue, child: const Icon(Icons.check, color: Colors.white)),
                    title: Text(a['titulo'] ?? ''),
                    subtitle: Text('${a['materia']} · ${a['fecha']}', style: const TextStyle(fontSize: 12)),
                    trailing: Chip(
                      label: Text(a['estado'] ?? ''),
                      backgroundColor: a['estado'] == 'Presente' ? Colors.green.shade50 : (a['estado'] == 'Ausente' ? Colors.red.shade50 : Colors.orange.shade50),
                    ),
                    onTap: () => _showDetalleAsistencia(context, a),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDetalleAsistencia(BuildContext context, Map<String, String> asistencia) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(asistencia['titulo'] ?? ''),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Materia: ${asistencia['materia']}'),
            const SizedBox(height: 8),
            Text('Fecha: ${asistencia['fecha']}'),
            const SizedBox(height: 8),
            Text('Estado: ${asistencia['estado']}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }
}

class SesionesPageContent extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  SesionesPageContent({super.key});

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
          // ...existing code... (contenido sin navbar)
        ],
      ),
      // Sin bottomNavigationBar
    );
  }
}

void navegarAMainScaffold(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const MainScaffold(initialIndex: 0), // 0=Servicios, 1=Sesiones, 2=Asistencias, 3=Dashboard
    ),
  );
}