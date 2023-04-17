import 'package:flutter/material.dart';
import 'package:my_app/ui_components/custom_app_bar.dart';

class DetailScreen extends StatelessWidget {
  final Image photo;

  const DetailScreen({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(title: 'Просмотр фото'),
      body: InteractiveViewer(
          maxScale: 8,
          child: Center(
            child: Container(child: photo),
          )),
    );
  }
}
