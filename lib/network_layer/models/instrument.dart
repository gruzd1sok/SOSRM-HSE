part of 'package:my_app/network_layer/network.dart';

class Instrument {
  Instrument({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
  });

  final String id;
  final String name;
  final String image;
  final String description;

  factory Instrument.fromRawJson(String str) =>
      Instrument.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Instrument.fromJson(Map<String, dynamic> json) => Instrument(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "description": description,
      };
}
