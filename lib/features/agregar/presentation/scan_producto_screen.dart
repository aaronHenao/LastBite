import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:lastbite/l10n/traducciones.dart';

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
        title: Text(context.t.escanerPermisoTitulo),
        content: Text(context.t.escanerPermisoDescripcion),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.t.escanerEntendido),
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
        title: Text(context.t.escanerTitulo),
        actions: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, child) {
              final isOn = state.torchState == TorchState.on;
              return IconButton(
                tooltip: isOn
                    ? context.t.escanerApagarFlash
                    : context.t.escanerEncenderFlash,
                icon: Icon(isOn ? Icons.flash_on : Icons.flash_off),
                onPressed: _controller.toggleTorch,
              );
            },
          ),
          IconButton(
            tooltip: context.t.escanerCambiarCamara,
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
                return Center(
                  child: Text(
                    context.t.escanerPermisoDenegado,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }

              return Center(
                child: Text(
                  context.t.escanerNoInicia,
                  style: const TextStyle(color: Colors.white),
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
                border: Border.all(color: context.paleta.marca, width: 2),
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
              child: Text(
                context.t.escanerAlinea,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
