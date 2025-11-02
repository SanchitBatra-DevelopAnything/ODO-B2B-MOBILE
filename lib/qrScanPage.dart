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

          if (data != null) {
            final regex = RegExp(
              r'Area\s*[:=]\s*(.+?)[,;\n]\s*Referrer\s*[:=]\s*(.+)$',
              caseSensitive: false,
            );
            final match = regex.firstMatch(data);
            if (match != null) {
              widget.onScan(match.group(1)!.trim(), match.group(2)!.trim());
            }
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("I read : ${data}")));
            isScanned = false;
          }
        },
      ),
    );
  }
}
