part of 'package:my_app/network_layer/network.dart';

class NfcData {
  NfcData({
    required this.id,
    required this.name,
    required this.roomNum,
    required this.image,
    required this.instrument,
  });

  final String id;
  final String name;
  final int roomNum;
  final String image;
  final List<Instrument> instrument;

  factory NfcData.fromRawJson(String str) => NfcData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NfcData.fromJson(Map<String, dynamic> json) => NfcData(
        id: json["id"],
        name: json["name"],
        roomNum: json["room_num"],
        image: json["image"],
        instrument: List<Instrument>.from(
            json["instrument"].map((x) => Instrument.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "room_num": roomNum,
        "image": image,
        "instrument": List<dynamic>.from(instrument.map((x) => x.toJson())),
      };
}
