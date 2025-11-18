import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api/routes/sesion_service.dart';
import 'api/routes/servicio_service.dart';

class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 137, 99, 207);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
  static const backgroundLight = Color(0xFFF3F4F6);
}

class CrearSesionPage extends StatefulWidget {
  const CrearSesionPage({super.key});

  @override
  State<CrearSesionPage> createState() => _CrearSesionPageState();
}

class _CrearSesionPageState extends State<CrearSesionPage> {
  final _formKey = GlobalKey<FormState>();
  late SesionService sesionService;
  late ServicioService servicioService;
  bool isLoading = false;
  bool loadingServicios = true;
  List<dynamic> servicios = [];
  Map<String, List<dynamic>> serviciosPorTipo = {};

  // Controladores de los campos (sin ID servicio ni período)
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _lugarController = TextEditingController();
  final _maxAsistentesController = TextEditingController();
  final _antesSesionController = TextEditingController();
  final _despuesSesionController = TextEditingController();
  
  // Valores seleccionados para dropdowns
  int? _idServicioSeleccionado;
  int? _idPeriodoSeleccionado;
  int _idModalidad = 1; // 1=Presencial, 2=Virtual, 3=Híbrida
  int _idTipo = 1; // 1=Tutoría, 2=Taller, 3=Seminario
  int _idSemana = 1;
  DateTime _fechaSesion = DateTime.now();
  TimeOfDay _horaInicio = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _horaFin = const TimeOfDay(hour: 16, minute: 0);
  
  // Switches
  bool _gestionaAsistencia = true;
  bool _facilitadorExterno = false;
  
  // Datos para dropdowns
  final List<Map<String, dynamic>> _periodos = [
    {'id': 1, 'nombre': '2024-1'},
    {'id': 2, 'nombre': '2024-2'},
    {'id': 3, 'nombre': '2025-1'},
    {'id': 4, 'nombre': '2025-2'},
  ];

  @override
  void initState() {
    super.initState();
    const baseUrlSesiones = 'https://ga7a0b6c9043600-atpdb.adb.us-phoenix-1.oraclecloudapps.com/ords/ecoutb_workspace/sesiones/';
    const baseUrlServicios = 'https://ga7a0b6c9043600-atpdb.adb.us-phoenix-1.oraclecloudapps.com/ords/ecoutb_workspace/servicios/';
    sesionService = SesionService(baseUrlSesiones);
    servicioService = ServicioService(baseUrlServicios);
    
    // Valores por defecto
    _maxAsistentesController.text = '30';
    _antesSesionController.text = '10';
    _despuesSesionController.text = '5';
    
    // Cargar servicios
    _cargarServicios();
  }
  
  Future<void> _cargarServicios() async {
    try {
      final resultado = await servicioService.getServicios();
      setState(() {
        servicios = resultado;
        loadingServicios = false;
        // Agrupar servicios por departamento o tipo inferido del nombre
        serviciosPorTipo = {};
        for (var servicio in servicios) {
          // Inferir tipo del nombre del servicio
          String nombreServicio = (servicio['nombre_servicio'] ?? '').toString().toLowerCase();
          String tipo;
          
          if (nombreServicio.contains('tutoría') || nombreServicio.contains('tutoria')) {
            tipo = 'Tutorías';
          } else if (nombreServicio.contains('taller')) {
            tipo = 'Talleres';
          } else if (nombreServicio.contains('seminario')) {
            tipo = 'Seminarios';
          } else {
            tipo = 'Otros Servicios';
          }
          
          if (!serviciosPorTipo.containsKey(tipo)) {
            serviciosPorTipo[tipo] = [];
          }
          serviciosPorTipo[tipo]!.add(servicio);
        }
      });
    } catch (e) {
      print('Error al cargar servicios: $e');
      setState(() {
        loadingServicios = false;
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _lugarController.dispose();
    _maxAsistentesController.dispose();
    _antesSesionController.dispose();
    _despuesSesionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSesion,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.universityPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _fechaSesion) {
      setState(() {
        _fechaSesion = picked;
      });
    }
  }

  Future<void> _seleccionarHoraInicio() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaInicio,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.universityPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _horaInicio) {
      setState(() {
        _horaInicio = picked;
      });
    }
  }

  Future<void> _seleccionarHoraFin() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaFin,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.universityPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _horaFin) {
      setState(() {
        _horaFin = picked;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  DateTime _combinarFechaHora(DateTime fecha, TimeOfDay hora) {
    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      hora.hour,
      hora.minute,
    );
  }

  Future<void> _crearSesion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_idServicioSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un servicio')),
      );
      return;
    }
    
    if (_idPeriodoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un período')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Obtener información del facilitador (simulado por ahora)
      // TODO: Obtener del UserSession cuando esté implementado
      const idFacilitador = 'usuario@utb.edu.co';

      // Combinar fecha con horas
      final horaInicioCompleta = _combinarFechaHora(_fechaSesion, _horaInicio);
      final horaFinCompleta = _combinarFechaHora(_fechaSesion, _horaFin);

      // Construir el objeto sesión según la estructura de Oracle ORDS
      final nuevaSesion = {
        "id_servicio": _idServicioSeleccionado!,
        "id_periodo": _idPeriodoSeleccionado!,
        "id_tipo": _idTipo,
        "descripcion": _descripcionController.text.isNotEmpty ? _descripcionController.text : null,
        "hora_inicio_sesion": _formatTimeOfDay(_horaInicio),
        "fecha_fin": horaFinCompleta.toUtc().toIso8601String().replaceAll('.000', 'Z'),
        "nombre_sesion": _nombreController.text,
        "id_modalidad": _idModalidad,
        "lugar_sesion": _lugarController.text,
        "fecha": _fechaSesion.toUtc().toIso8601String().replaceAll('.000', 'Z'),
        "id_semana": _idSemana,
        "hora_inicio": horaInicioCompleta.toUtc().toIso8601String().replaceAll('.000', 'Z'),
        "hora_fin": horaFinCompleta.toUtc().toIso8601String().replaceAll('.000', 'Z'),
        "id_faciltiador": idFacilitador, // Nota: typo intencional en BD
        "n_maximo_asistentes": int.parse(_maxAsistentesController.text),
        "inscritos_actuales": 0,
        "antes_sesion": int.parse(_antesSesionController.text),
        "despues_sesion": int.parse(_despuesSesionController.text),
        "gestiona_asis": _gestionaAsistencia ? "S" : "N",
        "facilitador_externo": _facilitadorExterno ? "S" : "N",
      };

      // Enviar al backend
      await sesionService.createSesion(nuevaSesion);
      
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesión creada exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Volver a la página anterior
        Navigator.pop(context, true); // true indica que se creó una sesión
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear sesión: $e'),
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
        title: const Text(
          'Crear Nueva Sesión',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.universityPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.universityPurple,
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: MediaQuery.of(context).padding.bottom + 16.0 + 20, // Espacio para botones de navegación
              ),
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
                              color: AppColors.universityPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Complete los datos de la nueva sesión',
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

                    // Información básica
                    Text(
                      'INFORMACIÓN BÁSICA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Nombre de la sesión (REQUERIDO)
                    _buildTextField(
                      controller: _nombreController,
                      label: 'Nombre de la Sesión *',
                      icon: Icons.star,
                      hint: 'Ej: Tutoría Microeconomía - Grupo A',
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
                      hint: 'Describe la sesión...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Dropdown de Servicio (REQUERIDO)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<int>(
                        value: _idServicioSeleccionado,
                        decoration: InputDecoration(
                          labelText: 'Servicio *',
                          labelStyle: const TextStyle(color: AppColors.universityPurple),
                          prefixIcon: const Icon(Icons.bookmark, color: AppColors.universityPurple),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        hint: const Text('Selecciona un servicio'),
                        isExpanded: true,
                        items: loadingServicios
                            ? []
                            : serviciosPorTipo.entries.expand((entry) {
                                List<DropdownMenuItem<int>> items = [];
                                // Items del tipo de servicio (sin header)
                                items.addAll(entry.value.map((servicio) {
                                  return DropdownMenuItem<int>(
                                    value: servicio['id'], // Usar 'id' no 'id_servicio'
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            color: AppColors.universityPurple,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${servicio['nombre_servicio'] ?? 'Sin nombre'} (${entry.key})',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList());
                                return items;
                              }).toList(),
                        onChanged: loadingServicios
                            ? null
                            : (value) {
                                setState(() {
                                  _idServicioSeleccionado = value;
                                });
                              },
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor selecciona un servicio';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dropdown de Periodo (REQUERIDO)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<int>(
                        value: _idPeriodoSeleccionado,
                        decoration: InputDecoration(
                          labelText: 'Período Académico *',
                          labelStyle: const TextStyle(color: AppColors.universityPurple),
                          prefixIcon: const Icon(Icons.calendar_month, color: AppColors.universityPurple),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        hint: const Text('Selecciona el período'),
                        isExpanded: true,
                        items: _periodos.map((periodo) {
                          return DropdownMenuItem<int>(
                            value: periodo['id'],
                            child: Text(periodo['nombre']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _idPeriodoSeleccionado = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor selecciona un período';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tipo y Modalidad
                    Text(
                      'TIPO Y MODALIDAD',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tipo de sesión
                    _buildDropdownField(
                      value: _idTipo,
                      label: 'Tipo de Sesión *',
                      icon: Icons.category,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Tutoría')),
                        DropdownMenuItem(value: 2, child: Text('Taller')),
                        DropdownMenuItem(value: 3, child: Text('Seminario')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _idTipo = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Modalidad
                    _buildDropdownField(
                      value: _idModalidad,
                      label: 'Modalidad *',
                      icon: Icons.location_on,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Presencial')),
                        DropdownMenuItem(value: 2, child: Text('Virtual')),
                        DropdownMenuItem(value: 3, child: Text('Híbrida')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _idModalidad = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Lugar
                    _buildTextField(
                      controller: _lugarController,
                      label: 'Lugar de la Sesión *',
                      icon: Icons.place,
                      hint: _idModalidad == 2 
                          ? 'Ej: Plataforma Zoom - Link enviado por correo'
                          : 'Ej: Edificio E, Salón 301',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El lugar es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Fecha y hora
                    Text(
                      'FECHA Y HORA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Fecha
                    InkWell(
                      onTap: _seleccionarFecha,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Fecha de la Sesión *',
                          prefixIcon: const Icon(Icons.calendar_today, color: AppColors.universityPurple),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_fechaSesion.day}/${_fechaSesion.month}/${_fechaSesion.year}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hora inicio
                    InkWell(
                      onTap: _seleccionarHoraInicio,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Hora de Inicio *',
                          prefixIcon: const Icon(Icons.access_time, color: AppColors.universityPurple),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTimeOfDay(_horaInicio),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hora fin
                    InkWell(
                      onTap: _seleccionarHoraFin,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Hora de Fin *',
                          prefixIcon: const Icon(Icons.access_time_filled, color: AppColors.universityPurple),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTimeOfDay(_horaFin),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Semana
                    _buildDropdownField(
                      value: _idSemana,
                      label: 'Semana *',
                      icon: Icons.calendar_view_week,
                      items: List.generate(
                        16,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('Semana ${index + 1}'),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _idSemana = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Capacidad y tiempos
                    Text(
                      'CAPACIDAD Y TIEMPOS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Máximo de asistentes
                    _buildTextField(
                      controller: _maxAsistentesController,
                      label: 'Máximo de Asistentes *',
                      icon: Icons.people,
                      hint: 'Ej: 30',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El máximo de asistentes es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Minutos antes de la sesión
                    _buildTextField(
                      controller: _antesSesionController,
                      label: 'Minutos Antes (registro anticipado) *',
                      icon: Icons.timer,
                      hint: 'Ej: 10',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Minutos después de la sesión
                    _buildTextField(
                      controller: _despuesSesionController,
                      label: 'Minutos Después (registro tardío) *',
                      icon: Icons.timer_off,
                      hint: 'Ej: 5',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es requerido';
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
                            // Gestiona asistencia
                            Row(
                              children: [
                                Icon(
                                  _gestionaAsistencia ? Icons.check_circle : Icons.cancel,
                                  color: _gestionaAsistencia ? Colors.green : Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Gestiona asistencia',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Switch(
                                  value: _gestionaAsistencia,
                                  onChanged: (value) {
                                    setState(() {
                                      _gestionaAsistencia = value;
                                    });
                                  },
                                  activeColor: AppColors.universityPurple,
                                ),
                              ],
                            ),
                            const Divider(),
                            // Facilitador externo
                            Row(
                              children: [
                                Icon(
                                  _facilitadorExterno ? Icons.check_circle : Icons.cancel,
                                  color: _facilitadorExterno ? Colors.green : Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Facilitador externo',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Switch(
                                  value: _facilitadorExterno,
                                  onChanged: (value) {
                                    setState(() {
                                      _facilitadorExterno = value;
                                    });
                                  },
                                  activeColor: AppColors.universityPurple,
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
                        onPressed: _crearSesion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.universityPurple,
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
                              'Crear Sesión',
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
        prefixIcon: Icon(icon, color: AppColors.universityPurple),
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
          borderSide: const BorderSide(color: AppColors.universityPurple, width: 2),
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

  Widget _buildDropdownField({
    required int value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<int>> items,
    required void Function(int?) onChanged,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.universityPurple),
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
          borderSide: const BorderSide(color: AppColors.universityPurple, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}
