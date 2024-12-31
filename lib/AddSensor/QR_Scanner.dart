import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'FoundCodeScreen.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({Key? key}) : super(key: key);

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _screenOpened = false;

  void _foundBarcode(Barcode barcode, MobileScannerArguments? args) {
    if (!_screenOpened) {
      final String code = barcode.rawValue ?? "---";
      _screenOpened = true;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoundCodeScreen(
            screenClosed: _screenWasClosed,
            value: code,
          ),
        ),
      ).then((newSensor) {
        if (newSensor != null) {
          Navigator.pop(context, newSensor);
        }
      });
    }
  }

  void _screenWasClosed() {
    _screenOpened = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Code"),
        backgroundColor: Colors.green[700],
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: _foundBarcode,
      ),
    );
  }
}
