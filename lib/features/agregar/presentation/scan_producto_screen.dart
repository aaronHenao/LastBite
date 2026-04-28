import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_theme.dart';

class ScanProductoScreen extends StatefulWidget {
  const ScanProductoScreen({super.key});

  @override
  State<ScanProductoScreen> createState() => _ScanProductoScreenState();
}

class _ScanProductoScreenState extends State<ScanProductoScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.qrCode,
    ],
  );

  bool _popping = false;
  bool _permissionDialogShown = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDetect(BarcodeCapture capture) {
    if (_popping) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    Barcode? selected;
    for (final barcode in barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.trim().isNotEmpty) {
        selected = barcode;
        break;
      }
    }

    final value = selected?.rawValue;
    if (value == null || value.trim().isEmpty) return;

    _popping = true;
    Navigator.of(context).pop(value.trim());
  }

  void _handlePermissionDenied() {
    if (_permissionDialogShown || !mounted) return;
    _permissionDialogShown = true;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso de camara requerido'),
        content: const Text(
          'Necesitamos acceso a la camara para escanear el codigo de barras.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
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
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Escanear producto'),
        actions: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, child) {
              final isOn = state.torchState == TorchState.on;
              return IconButton(
                tooltip: isOn ? 'Apagar flash' : 'Encender flash',
                icon: Icon(isOn ? Icons.flash_on : Icons.flash_off),
                onPressed: _controller.toggleTorch,
              );
            },
          ),
          IconButton(
            tooltip: 'Cambiar camara',
            icon: const Icon(Icons.cameraswitch),
            onPressed: _controller.switchCamera,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleDetect,
            errorBuilder: (context, error, child) {
              if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
                _handlePermissionDenied();
                return const Center(
                  child: Text(
                    'Permiso de camara denegado',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return const Center(
                child: Text(
                  'No se pudo iniciar la camara',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 260,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.accent, width: 2),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: const Text(
                'Alinea el codigo de barras dentro del marco',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
