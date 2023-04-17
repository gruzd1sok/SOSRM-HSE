part of 'package:my_app/network_layer/network.dart';

class WorkplaceData {
  final String id;
  final String createdAt;
  final String name;
  final String image;
  final String description;
  final String location;
  final String workTime;
  final List<String> images;
  final String metro;

  const WorkplaceData({
    required this.createdAt,
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.location,
    required this.workTime,
    required this.images,
    required this.metro,
  });

  factory WorkplaceData.fromJson(Map<String, dynamic> json) {
    return WorkplaceData(
      id: json['id'],
      name: json['name'],
      createdAt: json['created_at'],
      image: json['image'],
      description: json['description'],
      location: json['location'],
      workTime: json['work_time'],
      metro: json['metro'],
      images: List.from(
        json['images'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt,
        "name": name,
        "image": image,
        'description': description,
        'location': location,
        'work_time': workTime,
        'images': images,
        'metro': metro,
      };
}
