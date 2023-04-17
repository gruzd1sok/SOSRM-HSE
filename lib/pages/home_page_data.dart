import 'package:flutter/material.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/pages/instruments_page.dart';
import 'package:my_app/screens/instruments_detail_screen.dart';
import 'package:my_app/screens/tab_bar_screen.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;
import 'package:safe_device/safe_device.dart';
import '../network_layer/network.dart';
import '../widgets/detail_screen.dart';

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

class HomePageWithData extends StatelessWidget {
  HomePageWithData({
    super.key,
    required this.nfcData,
  });

  NfcData nfcData;

  Future<void> returnNfc(BuildContext context) async {
    final isRealDevice = await _isRealDevice();
    if (!isRealDevice) {
      final success = await stopNfcInWork(nfcData.id);
      if (success == true) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => TabBarScreen(null)),
            (route) => false);
        context.showSnackBar(message: 'Вы успешно завершили работу');
      } else {
        context.showErrorSnackBar(message: 'Ошибка, попробуйте ещё раз');
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TabBarScreen(null),
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
              final loadedNfcData = await getNfcInfo(nfcId);
              if (loadedNfcData != null) {
                if (loadedNfcData.id == nfcData.id) {
                  final success = await stopNfcInWork(nfcData.id);
                  if (success == true) {
                    await FlutterNfcKit.finish(iosAlertMessage: "Готово");

                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TabBarScreen(null)),
                        (route) => false);
                    context.showSnackBar(
                        message: 'Вы успешно завершили работу');
                  } else {
                    await FlutterNfcKit.finish(
                        iosErrorMessage: "Ошибка, Попробуйте еще раз");
                  }
                } else {
                  await FlutterNfcKit.finish(
                      iosErrorMessage: "Ошибка, Неправильный тэг");
                }
              } else {
                await FlutterNfcKit.finish(
                    iosErrorMessage:
                        "Ошибка загрузки данных для этой NFC метки");
              }
            } else {
              await FlutterNfcKit.finish(
                  iosErrorMessage: "Невозможно получить id для NFC метки");
            }
          }
        }
      } else {
        displayDialogOKCallBack(context, "Ошибка",
            "Ваше устройство не поддерживает работу с NFC :(, воспользуйтесь QR сканером");
      }
    }
  }

  Future<void> isReadyToReturn(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Вы пытаетесь завершить работу',
          ),
          content: const Text(
              'Проверьте рабочее место, если вы что-то брали удостоверьтесь что вернули администратору'),
          actions: <Widget>[
            TextButton(
                child: const Text("Завершить работу"),
                onPressed: () {
                  returnNfc(context);
                }),
            TextButton(
              child: const Text("Отменить"),
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

  Future<bool> _isRealDevice() async {
    return await SafeDevice.isRealDevice;
  }

  String get _simulatorNfcId => '90001441-a4d9-43bb-af77-bbdb50c415c2';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return DetailScreen(photo: Image.network(nfcData.image));
                  },
                ),
              );
            },
            child: Image.network(nfcData.image),
          ),
          Container(
            padding: const EdgeInsets.only(left: 30, top: 20, right: 30),
            child: Text(
              '${nfcData.name}\n\Рабочее место №: ${nfcData.roomNum.toString()}\n\nНа данном рабочем месте есть возможность взять в работу:',
              style: const TextStyle(
                  color: Colors.black,
                  fontStyle: FontStyle.normal,
                  fontSize: 20.0),
            ),
          ),
          Column(
            children: List.generate(
              nfcData.instrument.length,
              (index) => InstrumentView(
                instrument: nfcData.instrument[index],
                onTap: (instrument) => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        InstrumentsDetailScreen(instrument: instrument),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () async {
              isReadyToReturn(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
            ),
            child: const Text(
              "Завершить работу",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      )),
    );
  }
}
