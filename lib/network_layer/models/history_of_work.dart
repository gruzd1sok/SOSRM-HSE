part of 'package:my_app/network_layer/network.dart';

class HistoryOfWork {
  final String id;
  final String createdAt;
  final String name;
  final int mark;
  final String comment;

  const HistoryOfWork({
    required this.createdAt,
    required this.id,
    required this.name,
    required this.mark,
    required this.comment,
  });

  factory HistoryOfWork.fromJson(Map<String, dynamic> json) {
    return HistoryOfWork(
      id: json['id'],
      name: json['name'],
      createdAt: json['created_at'],
      comment: json['comment'],
      mark: json['mark'],
    );
  }
}
