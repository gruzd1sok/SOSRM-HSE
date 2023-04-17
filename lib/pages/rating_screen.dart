import 'package:cross_file_image/cross_file_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/network_layer/network.dart';
import 'package:my_app/screens/tab_bar_screen.dart';
import 'package:my_app/ui_components/custom_app_bar.dart';
import 'package:my_app/widgets/detail_screen.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key, required this.nfcData});

  final NfcData nfcData;

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  ImagePicker picker = ImagePicker();
  XFile? photo;
  int itemCount = 5;
  List<bool> selected = [];
  TextEditingController whatsWrongController = TextEditingController();

  @override
  initState() {
    for (var i = 0; i < itemCount; i++) {
      selected.add(false);
    }
    super.initState();
  }

  Image starEmpty = Image.asset('assets/Star.png');
  Image starFilled = Image.asset('assets/Star_fill.png');

  bool blockAddPhotoButton = false;

  bool star1 = false;
  bool star2 = false;
  bool star3 = false;
  bool star4 = false;
  bool star5 = false;

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
              child: const Text('Закрыть'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void isBroken(BuildContext context) {
    String mark = star5
        ? '5'
        : star4
            ? '4'
            : star3
                ? '3'
                : star2
                    ? '2'
                    : star1
                        ? '1'
                        : '0';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Проблема на рабочем месте',
          ),
          content: const Text('Оставьте комментарий и сделайте фото проблемы.'),
          actions: <Widget>[
            TextButton(
                child: const Text(
                  'Отправить и выбрать другое место',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  final success = await cancelNfcInWork(
                      widget.nfcData.id, mark, whatsWrongController.text);
                  if (success == true) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TabBarScreen(null),
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                    displayDialogOKCallBack(
                      context,
                      'Ошибка',
                      'Попробуйте ещё раз',
                    );
                  }
                }),
            TextButton(
              child: const Text('Отменить'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> goToHomePageData() async {
    String mark = star5
        ? '5'
        : star4
            ? '4'
            : star3
                ? '3'
                : star2
                    ? '2'
                    : star1
                        ? '1'
                        : '0';
    final success =
        await takeNfcInWork(widget.nfcData.id, mark, whatsWrongController.text);
    if (success == true) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => TabBarScreen(widget.nfcData)));
    } else {
      print('error');
    }
  }

  Future<void> isReadyToStartWork(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Начало работы',
          ),
          content: Text(
              'Вы выбрали рабочее место № ${widget.nfcData.roomNum} в ${widget.nfcData.name}\n\nОбращаем внимание, для завершения работы необходимо будет вновь отсканировать NFC тэг'),
          actions: <Widget>[
            TextButton(
                child: const Text('Да, все верно, начать работу'),
                onPressed: () {
                  Navigator.of(context).pop();
                  goToHomePageData();
                }),
            TextButton(
              child: const Text('Назад'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void needEvaulateWorkplace(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Ошибка',
          ),
          content: const Text('Без оценки рабочего места начать работу нельзя'),
          actions: <Widget>[
            TextButton(
              child: const Text('Хорошо'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> evaulationCriteries(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Критерии оценки состояния рабочего места',
          ),
          content: const Text(
              '5 - всё в порядке, замечаний нет\n4 и ниже - замечания есть, опишите в комментарии, сделайте фото'),
          actions: [
            TextButton(
              child: const Text('Понятно, оценить'),
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
      appBar: CustomAppBar(title: 'Оценка рабочего места'),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Для начала работы необходимо оценить состоние рабочего места',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.only(
                  left: 40,
                  right: 40,
                  top: 10,
                  bottom: 10,
                ),
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    evaulationCriteries(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Критерии оценки',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: star1 ? starFilled : starEmpty,
                    onPressed: () {
                      setState(() {
                        star1 = true;
                        star2 = false;
                        star3 = false;
                        star4 = false;
                        star5 = false;
                      });
                    },
                    iconSize: 50,
                  ),
                  IconButton(
                    icon: star2 ? starFilled : starEmpty,
                    onPressed: () {
                      setState(() {
                        star1 = true;
                        star2 = true;
                        star3 = false;
                        star4 = false;
                        star5 = false;
                      });
                    },
                    iconSize: 50,
                  ),
                  IconButton(
                    icon: star3 ? starFilled : starEmpty,
                    onPressed: () {
                      setState(() {
                        star1 = true;
                        star2 = true;
                        star3 = true;
                        star4 = false;
                        star5 = false;
                      });
                    },
                    iconSize: 50,
                  ),
                  IconButton(
                    icon: star4 ? starFilled : starEmpty,
                    onPressed: () {
                      setState(() {
                        star1 = true;
                        star2 = true;
                        star3 = true;
                        star4 = true;
                        star5 = false;
                      });
                    },
                    iconSize: 50,
                  ),
                  IconButton(
                    icon: star5 ? starFilled : starEmpty,
                    onPressed: () {
                      setState(() {
                        star1 = true;
                        star2 = true;
                        star3 = true;
                        star4 = true;
                        star5 = true;
                      });
                    },
                    iconSize: 50,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Visibility(
                visible: !star5 && star1,
                child: Container(
                  height: 150,
                  padding:
                      const EdgeInsets.only(left: 30, right: 30, bottom: 30),
                  child: TextField(
                    maxLines: 8,
                    textAlign: TextAlign.left,
                    controller: whatsWrongController,
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    decoration: InputDecoration(
                      hintText: 'Что-то не так?',
                      hintStyle: TextStyle(fontSize: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            width: 1,
                            style: BorderStyle.none,
                            color: Colors.black),
                      ),
                      filled: true,
                      contentPadding: EdgeInsets.all(16),
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: photo != null,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) {
                          return DetailScreen(
                            photo: Image(image: XFileImage(photo!)),
                          );
                        },
                      ),
                    );
                  },
                  child: Column(children: [
                    SizedBox(
                        width: 200,
                        height: 200,
                        child: photo != null
                            ? Image(image: XFileImage(photo!))
                            : Image.asset('assets/photoEmpty.png')),
                    const SizedBox(height: 30),
                  ]),
                ),
              ),
              Visibility(
                visible: !star5 && star1,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    setState(() {
                      blockAddPhotoButton = true;
                    });

                    XFile? tempPhoto =
                        await picker.pickImage(source: ImageSource.camera);
                    setState(() {
                      photo = tempPhoto;
                      blockAddPhotoButton = false;
                    });
                  },
                  label: const Text(
                    'Добавьте фото',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        blockAddPhotoButton ? Colors.grey : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () async => star1 || star2 || star3 || star4 || star5
                    ? isReadyToStartWork(context)
                    : needEvaulateWorkplace(context),
                child: const Text(
                  'Начать работу',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () async {
                  isBroken(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  'Сообщить о проблеме',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
