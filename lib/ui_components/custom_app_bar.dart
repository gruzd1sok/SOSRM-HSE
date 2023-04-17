import 'package:flutter/material.dart';
import 'package:my_app/design_system/palette.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  CustomAppBar({
    super.key,
    this.title = 'Система состояния рабочего места',
  });

  @override
  Size get preferredSize => const Size(double.infinity, 56);

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontStyle: FontStyle.normal,
          fontSize: 15.0,
        ),
      ),
      backgroundColor: Palette.mainAppColor,
    );
  }
}
