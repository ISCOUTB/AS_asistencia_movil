import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api/routes/sesion_service.dart';
import 'api/core/user_session_provider.dart';

class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 137, 99, 207);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> with WidgetsBindingObserver {
  late MobileScannerController cameraController;
  bool isScanning = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    // Iniciar la cámara después de que el widget esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        try {
          await cameraController.start();
        } catch (e) {
          setState(() {
            errorMessage = 'Error al iniciar cámara: $e';
          });
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Manejar el ciclo de vida de la aplicación
    if (!mounted) return;
    
    switch (state) {
      case AppLifecycleState.resumed:
        cameraController.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        cameraController.stop();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          isScanning = false;
        });
        
        // Mostrar el código QR escaneado
        _showQRResult(barcode.rawValue!);
        break;
      }
    }
  }

  void _showQRResult(String qrCode) async {
    // Mostrar diálogo de carga
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Validando código...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Obtener email del estudiante
      final userSession = context.read<UserSessionProvider>();
      final emailEstudiante = userSession.email;

      if (emailEstudiante.isEmpty) {
        if (!mounted) return;
        Navigator.pop(context); // Cerrar diálogo de carga
        _mostrarError('Error', 'No se pudo obtener la información del estudiante.');
        return;
      }

      // Validar código de acceso
      final sesionService = SesionService('https://ga7a0b6c9043600-atpdb.adb.us-phoenix-1.oraclecloudapps.com/ords/ecoutb_workspace/sesiones/');
      final sesionData = await sesionService.validarCodigoAcceso(qrCode);

      if (!mounted) return;
      Navigator.pop(context); // Cerrar diálogo de carga

      if (sesionData == null) {
        // Código inválido
        _mostrarError('Código inválido', 'El código QR escaneado no corresponde a ninguna sesión activa.');
        return;
      }

      // Guardar sesión como pendiente en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String key = 'sesiones_pendientes_$emailEstudiante';
      final String? existingData = prefs.getString(key);
      List<Map<String, dynamic>> sesionesPendientes = [];
      
      if (existingData != null) {
        final decoded = jsonDecode(existingData) as List;
        sesionesPendientes = decoded.map((e) => e as Map<String, dynamic>).toList();
      }

      // Verificar si ya existe esta sesión pendiente
      final bool yaExiste = sesionesPendientes.any((s) => s['id'] == sesionData['id']);
      
      if (yaExiste) {
        _mostrarError('Sesión duplicada', 'Ya tienes esta sesión en tus asistencias pendientes.');
        return;
      }

      // Agregar nueva sesión pendiente
      sesionesPendientes.add({
        'id': sesionData['id'],
        'nombre_sesion': sesionData['nombre_sesion'],
        'fecha_sesion': sesionData['fecha_sesion'],
        'codigo_acceso': qrCode,
        'email_estudiante': emailEstudiante,
        'fecha_escaneo': DateTime.now().toIso8601String(),
      });

      await prefs.setString(key, jsonEncode(sesionesPendientes));

      if (!mounted) return;

      // Mostrar mensaje de éxito
      _mostrarSesionAgregada(
        sesionData['nombre_sesion'] ?? 'Sesión',
        sesionData['fecha_sesion'] ?? '',
      );
    } catch (e) {
      if (!mounted) return;
      // Intentar cerrar diálogo de carga si sigue abierto
      try {
        Navigator.pop(context);
      } catch (_) {}
      
      _mostrarError('Error', 'Ocurrió un error al procesar el código: $e');
    }
  }

  void _mostrarSesionAgregada(String nombreSesion, String fechaSesion) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.universityBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_task, color: AppColors.universityBlue, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Sesión Agregada',
              style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.universityBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombreSesion,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fechaSesion,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Ve a "Asistencias" e ingresa el código de verificación para confirmar tu registro',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Cerrar scanner
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.universityBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Ir a Asistencias'),
          ),
        ],
      ),
    );
  }

  void _mostrarError(String titulo, String mensaje) {
    setState(() {
      isScanning = true; // Permitir escanear de nuevo
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.error_outline, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            mensaje,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Reintentar',
              style: TextStyle(color: AppColors.universityBlue),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Cerrar scanner también
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Escanear QR',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_off, color: Colors.white),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Cámara
          MobileScanner(
            controller: cameraController,
            onDetect: isScanning ? _onDetect : null,
            fit: BoxFit.cover,
            errorBuilder: (context, error, child) {
              return Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 64,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Error al acceder a la cámara',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Por favor, verifica los permisos de cámara en la configuración de tu dispositivo',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await cameraController.start();
                            setState(() {
                              errorMessage = null;
                            });
                          } catch (e) {
                            setState(() {
                              errorMessage = 'No se pudo reiniciar la cámara';
                            });
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.universityBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Overlay con guías
          CustomPaint(
            painter: QRScannerOverlay(),
            child: Container(),
          ),
          
          // Instrucciones
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 80, // Espacio para botones de navegación
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: AppColors.universityBlue,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enfoca el código QR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mantén la cámara estable',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Painter personalizado para el overlay del scanner
class QRScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanArea = size.width * 0.7;
    final double left = (size.width - scanArea) / 2;
    final double top = (size.height - scanArea) / 2;
    
    // Fondo oscuro semitransparente (reducida opacidad para mejor visibilidad)
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.6);
    
    // Dibujar el fondo completo
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    // Crear un agujero en el medio (área de escaneo)
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scanArea, scanArea),
        const Radius.circular(20),
      ),
    );
    
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, backgroundPaint);
    
    // Borde del área de escaneo con sombra para mejor visibilidad
    final shadowPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scanArea, scanArea),
        const Radius.circular(20),
      ),
      shadowPaint,
    );
    
    // Borde principal del área de escaneo
    final borderPaint = Paint()
      ..color = AppColors.universityBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scanArea, scanArea),
        const Radius.circular(20),
      ),
      borderPaint,
    );
    
    // Esquinas decorativas más gruesas y con glow
    final cornerGlowPaint = Paint()
      ..color = AppColors.universityBlue.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    final cornerPaint = Paint()
      ..color = AppColors.universityBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    
    const double cornerLength = 30;
    
    // Esquina superior izquierda
    canvas.drawLine(Offset(left, top + cornerLength), Offset(left, top), cornerGlowPaint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), cornerGlowPaint);
    canvas.drawLine(Offset(left, top + cornerLength), Offset(left, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), cornerPaint);
    
    // Esquina superior derecha
    canvas.drawLine(Offset(left + scanArea - cornerLength, top), Offset(left + scanArea, top), cornerGlowPaint);
    canvas.drawLine(Offset(left + scanArea, top), Offset(left + scanArea, top + cornerLength), cornerGlowPaint);
    canvas.drawLine(Offset(left + scanArea - cornerLength, top), Offset(left + scanArea, top), cornerPaint);
    canvas.drawLine(Offset(left + scanArea, top), Offset(left + scanArea, top + cornerLength), cornerPaint);
    
    // Esquina inferior izquierda
    canvas.drawLine(Offset(left, top + scanArea - cornerLength), Offset(left, top + scanArea), cornerGlowPaint);
    canvas.drawLine(Offset(left, top + scanArea), Offset(left + cornerLength, top + scanArea), cornerGlowPaint);
    canvas.drawLine(Offset(left, top + scanArea - cornerLength), Offset(left, top + scanArea), cornerPaint);
    canvas.drawLine(Offset(left, top + scanArea), Offset(left + cornerLength, top + scanArea), cornerPaint);
    
    // Esquina inferior derecha
    canvas.drawLine(Offset(left + scanArea - cornerLength, top + scanArea), Offset(left + scanArea, top + scanArea), cornerGlowPaint);
    canvas.drawLine(Offset(left + scanArea, top + scanArea - cornerLength), Offset(left + scanArea, top + scanArea), cornerGlowPaint);
    canvas.drawLine(Offset(left + scanArea - cornerLength, top + scanArea), Offset(left + scanArea, top + scanArea), cornerPaint);
    canvas.drawLine(Offset(left + scanArea, top + scanArea - cornerLength), Offset(left + scanArea, top + scanArea), cornerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
