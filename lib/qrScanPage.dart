import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanPage extends StatefulWidget {
  final Function(String area, String referrer) onScan;

  const QRScanPage({required this.onScan, Key? key}) : super(key: key);

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Code")),
      body: MobileScanner(
        onDetect: (capture) {
          if (isScanned) return;
          isScanned = true;

          final List<Barcode> barcodes = capture.barcodes;
          final Barcode barcode = barcodes.first;
          final String? data = barcode.rawValue;

          if (data != null && data.contains("Area:") && data.contains("Referrer:")) {
            final parts = data.split(",");
            String area = parts[0].split(":")[1].trim();
            String referrer = parts[1].split(":")[1].trim();

            widget.onScan(area, referrer);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("I read : ${data}")),
            );
            isScanned = false;
          }
        },
      ),
    );
  }
}
