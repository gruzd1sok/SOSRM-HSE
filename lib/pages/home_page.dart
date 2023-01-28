import 'dart:convert';
import 'network.dart';
import 'package:flutter/material.dart';
import 'package:my_app/pages/instruments_page.dart';
import '../widgets/nav-drawer.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;
import 'package:native_shared_preferences/native_shared_preferences.dart';
import 'qr_scanner_page.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

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
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const IconData qr_code_scanner_rounded =
        IconData(0xf00cc, fontFamily: 'MaterialIcons');

    return Scaffold(
      drawer: NavDrawer(
        nfcData: null,
      ),
      appBar: AppBar(
        title: const Text(
          "SOSRM-HSE",
          style: TextStyle(
              color: Colors.white, fontStyle: FontStyle.normal, fontSize: 25.0),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: IconButton(
          icon: Image.asset('assets/mainLogo.png'),
          iconSize: 1000,
          onPressed: () async {
            var availability = FlutterNfcKit.nfcAvailability;
            if (availability != FlutterNfcKit.nfcAvailability) {
              NFCTag? tag;
              ndef.NDEFRecord? ndefRecord;
              try {
                tag = await FlutterNfcKit.poll(
                    timeout: const Duration(seconds: 10),
                    iosMultipleTagMessage: "Multiple tags found!",
                    iosAlertMessage:
                        "Отсканируйте NFC метку что бы начать работу");
              } on Exception catch (error) {
                // displayDialogOKCallBack(context, 'Error', '$error');
              }

              if (tag != null) {
                if (tag.type == NFCTagType.mifare_ultralight) {
                  List<ndef.NDEFRecord>? ndefRecords;
                  try {
                    ndefRecords = await FlutterNfcKit.readNDEFRecords();
                  } on Exception catch (error) {
                    await FlutterNfcKit.finish(
                        iosErrorMessage: 'Ошибка, $error');
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
                    final nfcData = await fetchNfcData(nfcId);
                    if (nfcData != null) {
                      await FlutterNfcKit.finish(iosAlertMessage: "Готово");
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InstrumentsPage(
                            nfcData: nfcData!,
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
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: Colors.orange,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const QRViewExample(),
          ));
        },
        child: Icon(qr_code_scanner_rounded),
      ),
    );
  }
}
