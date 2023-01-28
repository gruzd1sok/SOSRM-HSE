import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/pages/home_page.dart';
import 'package:my_app/pages/home_page_data.dart';
import 'network.dart';
import '../widgets/detail-screen.dart';

int itemCount = 5;
List<bool> selected = [];
TextEditingController whatsWrongController = new TextEditingController();

class InstrumentsPage extends StatefulWidget {
  NfcData nfcData;
  InstrumentsPage({super.key, required this.nfcData});

  @override
  _InstrumentsPageState createState() => _InstrumentsPageState();
}

class _InstrumentsPageState extends State<InstrumentsPage> {
  ImagePicker picker = ImagePicker();
  XFile? photo;

  Future<void> goToHomePageData() async {
    String mark = star5
        ? "5"
        : star4
            ? "4"
            : star3
                ? "3"
                : star2
                    ? "2"
                    : star1
                        ? "1"
                        : "0";
    final success =
        await takeNfcInWork(widget.nfcData.id, mark, whatsWrongController.text);
    if (success == true) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MyHomePageWithData(nfcData: widget.nfcData)));
    } else {
      print("error");
    }
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

  void isBroken(BuildContext context) {
    String mark = star5
        ? "5"
        : star4
            ? "4"
            : star3
                ? "3"
                : star2
                    ? "2"
                    : star1
                        ? "1"
                        : "0";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Отменить',
          ),
          content: Text(
              "Вы хотите занять другое место? Если что-то не так с рабочим местом, пожалуйста оставьте комментарий с фото и отмените кнопкой Проблема на рабочем месте"),
          actions: <Widget>[
            TextButton(
                child: new Text("Проблема на рабочем месте"),
                onPressed: () async {
                  final success = await cancelNfcInWork(
                      widget.nfcData.id, mark, whatsWrongController.text);
                  if (success == true) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => MyHomePage()));
                  } else {
                    Navigator.pop(context);
                    displayDialogOKCallBack(
                        context, 'Ошибка', 'Попробуйте ещё раз');
                  }
                }),
            TextButton(
              child: new Text("Все в порядке, выйти"),
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => MyHomePage()));
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> isReadyToStartWork(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Начало работы',
          ),
          content: Text(
              "Вы выбрали рабочее место № ${widget.nfcData.roomNum} в ${widget.nfcData.name}\n\n"),
          actions: <Widget>[
            TextButton(
                child: new Text("Начать работу"),
                onPressed: () {
                  goToHomePageData();
                }),
            TextButton(
              child: new Text("Назад"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          "Начало работы",
          style: TextStyle(
              color: Colors.white, fontStyle: FontStyle.normal, fontSize: 25.0),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: ListView(children: [
          Container(
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return DetailScreen(
                      photo: Image.network(widget.nfcData.image));
                }));
              },
              child: Container(child: Image.network(widget.nfcData.image)),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 30, top: 50, right: 30),
            child: Text(
              '${widget.nfcData.name}\n\nРабочее место №: ${widget.nfcData.roomNum.toString()}',
              style: const TextStyle(
                  color: Colors.black,
                  fontStyle: FontStyle.normal,
                  fontSize: 20.0),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 30, top: 10, right: 30),
            child: Text(
              'Есть возможность взять в работу: \n${widget.nfcData.items}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontStyle: FontStyle.normal,
                  fontSize: 15.0),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 30, top: 10, right: 30),
            child: const Text(
              "Внимательно осмотрите рабочее место.\nОцените качество:",
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: Colors.black,
                  fontStyle: FontStyle.normal,
                  fontSize: 20.0),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 30),
            child: Row(
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
                  iconSize: 60,
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
                  iconSize: 60,
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
                  iconSize: 60,
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
                  iconSize: 60,
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
                  iconSize: 60,
                ),
              ],
            ),
          ),
          Visibility(
            visible: !star5 && star1,
            child: Container(
              height: 150,
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
              child: TextField(
                maxLines: 8,
                textAlign: TextAlign.left,
                controller: whatsWrongController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Что-то не так?',
                  hintStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        width: 1, style: BorderStyle.none, color: Colors.black),
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
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return DetailScreen(
                    photo: Image(image: XFileImage(photo!)),
                  );
                }));
              },
              child: Column(children: [
                Container(
                    width: 200,
                    height: 200,
                    child: photo != null
                        ? Image(image: XFileImage(photo!))
                        : Image.asset('assets/photoEmpty.png')),
                const SizedBox(height: 30),
              ]),
            ),
          ),
          Container(
              padding: EdgeInsets.only(left: 40, right: 40),
              height: 43,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.add_circle,
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
                  "Добавьте фото",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      blockAddPhotoButton ? Colors.grey : Colors.blue,
                ),
              )),
          SizedBox(height: 15),
          Container(
              padding: EdgeInsets.only(left: 40, right: 40),
              height: 43,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.play_circle,
                  color: Colors.white,
                ),
                onPressed: () async {
                  isReadyToStartWork(context);
                },
                label: const Text(
                  "Начать работу",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              )),
          SizedBox(height: 15),
          Container(
              padding: EdgeInsets.only(left: 40, right: 40),
              height: 43,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.remove_circle,
                  color: Colors.white,
                ),
                onPressed: () async {
                  isBroken(context);
                },
                label: const Text(
                  "Отказаться",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              )),
        ]),
      ),
    );
  }
}
