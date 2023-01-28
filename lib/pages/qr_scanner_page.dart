import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'network.dart';
import 'instruments_page.dart';
import '../constants.dart';
import 'home_page.dart';

class QRViewExample extends StatefulWidget {
  final bool isEnd;
  const QRViewExample({Key? key, this.isEnd = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Отсканируйте QR",
          style: TextStyle(
              color: Colors.white, fontStyle: FontStyle.normal, fontSize: 25.0),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: ElevatedButton(
                onPressed: () async {
                  await controller?.toggleFlash();
                  setState(() {});
                },
                child: FutureBuilder(
                  future: controller?.getFlashStatus(),
                  builder: (context, snapshot) {
                    return Text(
                        'Фонарик: ${(snapshot.data ?? 'выкл') == true ? 'вкл' : 'выкл'}');
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      result = scanData;
      var code = result?.code;
      controller.pauseCamera();
      if (code != null) {
        final nfcData = await fetchNfcData(code);
        if (nfcData != null) {
          if (widget.isEnd == false) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => InstrumentsPage(
                  nfcData: nfcData!,
                ),
              ),
            );
            controller.stopCamera();
          } else {
            final loadedNfcData = await fetchNfcData(code);
            if (loadedNfcData != null) {
              if (loadedNfcData.id == nfcData.id) {
                final success = await stopNfcInWork(nfcData.id);
                if (success == true) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage()),
                      (route) => false);
                  context.showSnackBar(message: 'Вы успешно завершили работу');
                } else {
                  context.showErrorSnackBar(message: 'Попробуйте ещё раз');
                }
              } else {
                context.showErrorSnackBar(message: 'Неверный QR код');
              }
            } else {
              context.showErrorSnackBar(message: 'Попробуйте ещё раз');
            }
          }
        } else {
          context.showErrorSnackBar(message: 'Не удается распознать QR код');
          controller.resumeCamera();
        }
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    controller?.stopCamera();
    super.dispose();
  }
}
