import 'package:flutter/material.dart';
import 'package:my_app/network_layer/network.dart';
import 'package:my_app/ui_components/custom_app_bar.dart';
import 'package:my_app/widgets/detail_screen.dart';

class WorkplaceDetail extends StatelessWidget {
  const WorkplaceDetail({
    super.key,
    required this.workplace,
  });

  final WorkplaceData workplace;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: workplace.name,
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          SizedBox(
            height: 300,
            width: double.infinity,
            child: GridView.count(
              crossAxisCount: 1,
              scrollDirection: Axis.horizontal,
              children: List.generate(
                workplace.images.length,
                (index) => _ImageView(
                  image: Image.network(workplace.images[index]),
                  onTap: (image) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(photo: image),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workplace.description,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Text(
                  'Время работы: ${workplace.workTime}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Адрес: ${workplace.location}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageView extends StatelessWidget {
  const _ImageView({super.key, required this.image, required this.onTap});

  final Image image;
  final Function(Image) onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(image),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: image,
      ),
    );
  }
}
