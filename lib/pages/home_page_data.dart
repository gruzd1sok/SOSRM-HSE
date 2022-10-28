import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_app/pages/home_page.dart';
import '../widgets/nav-drawer.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;
import 'network.dart';
import '../widgets/detail-screen.dart';

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

class MyHomePageWithData extends StatelessWidget {
  NfcData nfcData;
  MyHomePageWithData({super.key, required this.nfcData});

  Future<void> returnNfc(BuildContext context) async {
    var availability = FlutterNfcKit.nfcAvailability;
    if (availability != FlutterNfcKit.nfcAvailability) {
      NFCTag? tag;
      ndef.NDEFRecord? ndefRecord;
      try {
        tag = await FlutterNfcKit.poll(
            timeout: const Duration(seconds: 10),
            iosMultipleTagMessage: "Multiple tags found!",
            iosAlertMessage: "Поднесите NFC метку");
      } on Exception catch (error) {
        // displayDialogOKCallBack(context, 'Error', '$error');
      }

      if (tag != null) {
        if (tag.type == NFCTagType.mifare_ultralight) {
          List<ndef.NDEFRecord>? ndefRecords;
          try {
            ndefRecords = await FlutterNfcKit.readNDEFRecords();
          } on Exception catch (error) {
            await FlutterNfcKit.finish(iosErrorMessage: 'Error, $error');
          }
          try {
            ndefRecord = ndefRecords!.first;
          } on Exception catch (error) {
            await FlutterNfcKit.finish(iosErrorMessage: "Try again");
          }

          if (ndefRecord != null) {
            final decodedNdefRecord = ndef.decodePartialNdefMessage(
                ndef.TypeNameFormat.nfcWellKnown,
                ndefRecord.type!,
                ndefRecord.payload!);

            final nfcId = split(decodedNdefRecord.toString(), '=').last;
            final loadedNfcData = await fetchNfcData(nfcId);
            if (loadedNfcData != null) {
              if (loadedNfcData.id == nfcData.id) {
                final success = await stopNfcInWork(nfcData.id);
                if (success == true) {
                  await FlutterNfcKit.finish(iosAlertMessage: "Готово");

                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MyHomePage()));
                } else {
                  await FlutterNfcKit.finish(
                      iosErrorMessage: "Ошибка, Попробуйте еще раз");
                }
              } else {
                print('loadedNfcData - ${loadedNfcData.id.toString()}');
                print('nfcData - ${nfcData.id.toString()}');
                await FlutterNfcKit.finish(
                    iosErrorMessage: "Ошибка, Неправильный тэг");
              }
            } else {
              await FlutterNfcKit.finish(
                  iosErrorMessage: "Ошибка загрузки данных для этой NFC метки");
            }
          } else {
            await FlutterNfcKit.finish(
                iosErrorMessage: "Невозможно получить id для NFC метки");
          }
        }
      }
    } else {
      displayDialogOKCallBack(
          context, "Ошибка", "Ваше устройство не поддерживает работу с NFC :(");
    }
  }

  Future<void> isReadyToReturn(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Вы пытаетесь завершить работу',
          ),
          content: Text(
              "Проверьте содержимое набора, все должно быть на месте, а так же в хорошем состоянии.\n\nДля завершения работы необходимо отсканировать NFC метку."),
          actions: <Widget>[
            TextButton(
                child: new Text("Завершить работу"),
                onPressed: () {
                  returnNfc(context);
                }),
            TextButton(
              child: new Text("Отменить"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
    return Scaffold(
      drawer: NavDrawer(
        nfcData: nfcData,
      ),
      appBar: AppBar(
        title: const Text(
          "NFC APP MIEM",
          style: TextStyle(
              color: Colors.white, fontStyle: FontStyle.normal, fontSize: 25.0),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Center(
          child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 30),
            child: const Text(
              'В работе сейчас находится:',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontStyle: FontStyle.normal,
                  fontSize: 25.0),
            ),
          ),
          Container(
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return DetailScreen(photo: Image.network(nfcData.image));
                }));
              },
              child: Container(child: Image.network(nfcData.image)),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 30, top: 50, right: 30),
            child: Text(
              '${nfcData.name}\n\nАудитория: ${nfcData.roomNum.toString()}\n\nКомплект должен содержать:',
              style: const TextStyle(
                  color: Colors.black,
                  fontStyle: FontStyle.normal,
                  fontSize: 20.0),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 30, top: 10, right: 30),
            child: Text(
              nfcData.items,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontStyle: FontStyle.normal,
                  fontSize: 15.0),
            ),
          ),
          const SizedBox(height: 15),
          Container(
              padding: const EdgeInsets.only(left: 40, right: 40),
              height: 43,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.white,
                ),
                onPressed: () async {
                  isReadyToReturn(context);
                },
                label: const Text(
                  "Закончить работу",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              )),
        ],
      )),
    );
  }
}
