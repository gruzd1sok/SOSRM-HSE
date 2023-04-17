import 'package:safe_device/safe_device.dart';

import '../network_layer/network.dart';
import 'package:flutter/material.dart';
import 'package:my_app/pages/instruments_page.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  List<String> split(String string, String separator, {int max = 0}) {
    List<String> result = [];

    if (separator.isEmpty) {
      result.add(string);
      return result;
    }

    while (true) {
      var index = string.indexOf(separator, 0);
      if (index == -1 || (max > 0 && result.length >= max)) {
        result.add(string);
        break;
      }

      result.add(string.substring(0, index));
      string = string.substring(index + separator.length);
    }

    return result;
  }

  static void displayDialogOKCallBack(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("Закрыть"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _isRealDevice() async {
    return await SafeDevice.isRealDevice;
  }

  String get _simulatorNfcId => '90001441-a4d9-43bb-af77-bbdb50c415c2';

  void _nfcAction(BuildContext context) async {
    {
      final isRealDevice = await _isRealDevice();
      if (!isRealDevice) {
        final nfcData = await getNfcInfo(_simulatorNfcId);
        if (nfcData != null)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InstrumentsPage(
                nfcData: nfcData,
              ),
            ),
          );
      } else {
        var availability = FlutterNfcKit.nfcAvailability;
        if (availability != FlutterNfcKit.nfcAvailability) {
          NFCTag? tag;
          ndef.NDEFRecord? ndefRecord;
          try {
            tag = await FlutterNfcKit.poll(
                timeout: const Duration(seconds: 10),
                iosMultipleTagMessage: "Multiple tags found!",
                iosAlertMessage: "Отсканируйте NFC метку что бы начать работу");
          } on Exception catch (error) {
            // displayDialogOKCallBack(context, 'Error', '$error');
          }

          if (tag != null) {
            if (tag.type == NFCTagType.mifare_ultralight) {
              List<ndef.NDEFRecord>? ndefRecords;
              try {
                ndefRecords = await FlutterNfcKit.readNDEFRecords();
              } on Exception catch (error) {
                await FlutterNfcKit.finish(iosErrorMessage: 'Ошибка, $error');
              }
              try {
                ndefRecord = ndefRecords!.first;
              } on Exception catch (error) {
                await FlutterNfcKit.finish(
                    iosErrorMessage: "Попробуйте еще раз");
              }

              if (ndefRecord != null) {
                final decodedNdefRecord = ndef.decodePartialNdefMessage(
                    ndef.TypeNameFormat.nfcWellKnown,
                    ndefRecord.type!,
                    ndefRecord.payload!);

                final nfcId = split(decodedNdefRecord.toString(), '=').last;
                final nfcData = await getNfcInfo(nfcId);
                if (nfcData != null) {
                  await FlutterNfcKit.finish(iosAlertMessage: "Готово");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InstrumentsPage(
                        nfcData: nfcData,
                      ),
                    ),
                  );
                } else {
                  await FlutterNfcKit.finish(
                      iosErrorMessage: "Ошибка загрузки данных");
                }
              } else {
                await FlutterNfcKit.finish(
                    iosErrorMessage: "Невозможно получить id из NFC метки");
              }
            }
          }
        } else {
          displayDialogOKCallBack(context, "Ошибка",
              "Ваше устройство не поддерживает работу с NFC :(");
        }
      }
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: SizedBox(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(
                  Icons.nfc_rounded,
                  size: 50,
                ),
                SizedBox(height: 30),
                Text(
                  'Cканировать NFC метку\nна рабочем месте',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          onPressed: () => _nfcAction(context),
        ),
      ),
    );
  }
}
