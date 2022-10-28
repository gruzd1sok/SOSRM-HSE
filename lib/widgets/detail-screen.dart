import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final Image photo;

  const DetailScreen({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Просмотр фото",
          style: TextStyle(
              color: Colors.white, fontStyle: FontStyle.normal, fontSize: 25.0),
        ),
        backgroundColor: Colors.orange,
      ),
      body: InteractiveViewer(
          maxScale: 8,
          child: Center(
            child: Container(child: photo),
          )),
    );
  }
}
