import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        cameraController.start();
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

  void _showQRResult(String qrCode) {
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
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.qr_code_scanner, color: Colors.green, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'QR Escaneado',
              style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Código detectado:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                qrCode,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.universityBlue, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Funcionalidad en desarrollo',
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
          TextButton(
            onPressed: () {
              setState(() {
                isScanning = true;
              });
              Navigator.pop(context);
            },
            child: Text(
              'Escanear Otro',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Cerrar scanner también
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.universityBlue,
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
