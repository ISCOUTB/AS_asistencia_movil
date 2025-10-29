import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api/routes/servicio_service.dart';

class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 137, 99, 207);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
  static const backgroundLight = Color(0xFFF3F4F6);
}

class CrearServicioPage extends StatefulWidget {
  const CrearServicioPage({super.key});

  @override
  State<CrearServicioPage> createState() => _CrearServicioPageState();
}

class _CrearServicioPageState extends State<CrearServicioPage> {
  final _formKey = GlobalKey<FormState>();
  late ServicioService servicioService;
  bool isLoading = false;

  // Controladores de los campos
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _materiaController = TextEditingController();
  final _periodoController = TextEditingController();
  final _idDepartamentoController = TextEditingController();
  final _idPublicoController = TextEditingController();
  final _publicosController = TextEditingController();
  
  // Valores para switches
  bool _acumulaAsistencia = true;
  bool _permiteExternos = false;

  @override
  void initState() {
    super.initState();
    const baseUrl = 'https://ga7a0b6c9043600-atpdb.adb.us-phoenix-1.oraclecloudapps.com/ords/ecoutb_workspace/servicios/';
    servicioService = ServicioService(baseUrl);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _materiaController.dispose();
    _periodoController.dispose();
    _idDepartamentoController.dispose();
    _idPublicoController.dispose();
    _publicosController.dispose();
    super.dispose();
  }

  Future<void> _crearServicio() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Obtener información del usuario autenticado (simulado por ahora)
      // TODO: Obtener del UserSession cuando esté implementado
      const idResponsable = 'usuario@utb.edu.co';
      const nombreResponsableId = 1; // ID del responsable
      const jefeCentro = 'usuario@utb.edu.co';
      const jefeCentroNombre = 'Usuario Demo';

      // Construir el objeto servicio según la estructura de Oracle ORDS
      final nuevoServicio = {
        "id_departamento": int.parse(_idDepartamentoController.text),
        "nombre_servicio": _nombreController.text,
        "descripcion": _descripcionController.text.isNotEmpty ? _descripcionController.text : null,
        "fecha_creacion_servicio": DateTime.now().toUtc().toIso8601String().replaceAll('.000', 'Z'),
        "id_padre": null,
        "id_acumula_asistencia": _acumulaAsistencia ? 1 : 0,
        "id_email": null,
        "id_responsable": idResponsable,
        "materia": _materiaController.text.isNotEmpty ? _materiaController.text : null,
        "periodo": _periodoController.text.isNotEmpty ? int.parse(_periodoController.text) : null,
        "nombre_responsable_id": nombreResponsableId,
        "id_publico": int.parse(_idPublicoController.text),
        "publicos": _publicosController.text,
        "jefe_centro": jefeCentro,
        "jefe_centro_nombre": jefeCentroNombre,
        "nivel": 1,
        "permite_externos": _permiteExternos ? "S" : "N",
      };

      // Enviar al backend
      await servicioService.createServicio(nuevoServicio);
      
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Servicio creado exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Volver a la página anterior
        Navigator.pop(context, true); // true indica que se creó un servicio
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear servicio: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Crear Nuevo Servicio'),
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.universityPurple,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Información del formulario
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.universityBlue,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Complete los datos del nuevo servicio',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nombre del servicio (REQUERIDO)
                    _buildTextField(
                      controller: _nombreController,
                      label: 'Nombre del Servicio *',
                      icon: Icons.bookmark,
                      hint: 'Ej: Tutoría de Microeconomía',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    _buildTextField(
                      controller: _descripcionController,
                      label: 'Descripción',
                      icon: Icons.description,
                      hint: 'Describe el servicio...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Materia
                    _buildTextField(
                      controller: _materiaController,
                      label: 'Materia',
                      icon: Icons.book,
                      hint: 'Ej: Microeconomía I',
                    ),
                    const SizedBox(height: 16),

                    // Periodo
                    _buildTextField(
                      controller: _periodoController,
                      label: 'Periodo',
                      icon: Icons.calendar_today,
                      hint: 'Ej: 202110',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ID Departamento (REQUERIDO)
                    _buildTextField(
                      controller: _idDepartamentoController,
                      label: 'ID Departamento *',
                      icon: Icons.corporate_fare,
                      hint: 'Ej: 1',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El ID de departamento es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ID Público (REQUERIDO)
                    _buildTextField(
                      controller: _idPublicoController,
                      label: 'ID Público *',
                      icon: Icons.people,
                      hint: 'Ej: 23',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El ID de público es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Públicos
                    _buildTextField(
                      controller: _publicosController,
                      label: 'Públicos *',
                      icon: Icons.group,
                      hint: 'Ej: Estudiantes de pregrado',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El campo de públicos es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Switches
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Acumula asistencia
                            Row(
                              children: [
                                Icon(
                                  _acumulaAsistencia ? Icons.check_circle : Icons.cancel,
                                  color: _acumulaAsistencia ? Colors.green : Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Acumula asistencia',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Switch(
                                  value: _acumulaAsistencia,
                                  onChanged: (value) {
                                    setState(() {
                                      _acumulaAsistencia = value;
                                    });
                                  },
                                  activeColor: AppColors.universityBlue,
                                ),
                              ],
                            ),
                            const Divider(),
                            // Permite externos
                            Row(
                              children: [
                                Icon(
                                  _permiteExternos ? Icons.check_circle : Icons.cancel,
                                  color: _permiteExternos ? Colors.green : Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Permite externos',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Switch(
                                  value: _permiteExternos,
                                  onChanged: (value) {
                                    setState(() {
                                      _permiteExternos = value;
                                    });
                                  },
                                  activeColor: AppColors.universityBlue,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botón de crear
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _crearServicio,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.universityBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Crear Servicio',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campos requeridos
                    Text(
                      '* Campos requeridos',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.universityBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.universityBlue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }
}
