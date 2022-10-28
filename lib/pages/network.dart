import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

final encoding = Encoding.getByName('utf-8');

String check =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB2aHZmcGd0anBrZGZ0eHVxYnBnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY2NjYzODI0NywiZXhwIjoxOTgyMjE0MjQ3fQ.LQ46PYnvF28uUoor9dA8FzNG4h0hhM4ybh-wmmnGuKE";

Future<NfcData?> fetchActiveNfc() async {
  final reqUri = Uri.parse(
      'https://pvhvfpgtjpkdftxuqbpg.supabase.co/rest/v1/rpc/GetNFCByProfileInWork');

  final Map<String, String> header = {
    'Content-type': 'application/json',
    'ApiKey': check,
    'Authorization': 'Bearer $check',
  };

  Map<String, dynamic> body = {"profile_id": userId};

  var res = await http.post(reqUri,
      body: jsonEncode(body), headers: header, encoding: encoding);

  if (res.statusCode == 200) {
    if (res.body != 'null') {
      var decode = jsonDecode(res.body);
      return NfcData.fromJson(decode);
    }
  }
}

Future<NfcData?> fetchNfcData(String nfc_id) async {
  final reqUri = Uri.parse(
      'https://pvhvfpgtjpkdftxuqbpg.supabase.co/rest/v1/rpc/GetNFCData');

  final Map<String, String> header = {
    'Content-type': 'application/json',
    'ApiKey': check,
    'Authorization': 'Bearer $check',
  };

  Map<String, dynamic> body = {"nfcid": nfc_id};

  var res = await http.post(reqUri,
      body: jsonEncode(body), headers: header, encoding: encoding);

  if (res.statusCode == 200) {
    var decode = jsonDecode(res.body);
    return NfcData.fromJson(decode);
  }
}

Future<bool> takeNfcInWork(String nfcId, String mark, String comment) async {
  final reqUri = Uri.parse(
      'https://pvhvfpgtjpkdftxuqbpg.supabase.co/rest/v1/rpc/TakeNFCInWork');

  final Map<String, String> header = {
    'Content-type': 'application/json',
    'ApiKey': check,
    'Authorization': 'Bearer $check',
  };

  Map<String, dynamic> body = {
    "mark": mark,
    "nfc_id": nfcId,
    "profile_id": userId,
    "comment": comment,
  };

  var res = await http.post(reqUri,
      body: jsonEncode(body), headers: header, encoding: encoding);

  if (res.statusCode == 200 || res.statusCode == 204) {
    return true;
  } else {
    print(res.statusCode);
    return false;
  }
}

Future<bool> cancelNfcInWork(String nfcId, String mark, String comment) async {
  final reqUri = Uri.parse(
      'https://pvhvfpgtjpkdftxuqbpg.supabase.co/rest/v1/rpc/CancelNFCInWork');

  final Map<String, String> header = {
    'Content-type': 'application/json',
    'ApiKey': check,
    'Authorization': 'Bearer $check',
  };

  Map<String, dynamic> body = {
    "mark": mark,
    "nfc_id": nfcId,
    "profile_id": userId,
    "comment": comment,
  };

  var res = await http.post(reqUri,
      body: jsonEncode(body), headers: header, encoding: encoding);

  if (res.statusCode == 200 || res.statusCode == 204) {
    return true;
  } else {
    print(res.statusCode);
    return false;
  }
}

Future<bool> stopNfcInWork(String nfcId) async {
  final reqUri = Uri.parse(
      'https://pvhvfpgtjpkdftxuqbpg.supabase.co/rest/v1/rpc/StopNFCInWork');

  final Map<String, String> header = {
    'Content-type': 'application/json',
    'ApiKey': check,
    'Authorization': 'Bearer $check',
  };

  Map<String, dynamic> body = {"nfc_id": nfcId, "profile_id": userId};

  var res = await http.post(reqUri,
      body: jsonEncode(body), headers: header, encoding: encoding);

  if (res.statusCode == 200 || res.statusCode == 204) {
    return true;
  } else {
    print(res.statusCode);
    return false;
  }
}

class NfcData {
  final String id;
  final String createdAt;
  final int roomNum;
  final String items;
  final String name;
  final String image;

  const NfcData(
      {required this.createdAt,
      required this.roomNum,
      required this.items,
      required this.id,
      required this.name,
      required this.image});

  factory NfcData.fromJson(Map<String, dynamic> json) {
    return NfcData(
        id: json['Id'],
        name: json['Name'],
        roomNum: json['RoomNum'],
        items: json['Items'],
        createdAt: json['created_at'],
        image: json['Image']);
  }

  Map<String, dynamic> toJson() => {
        'Id': id,
        'created_at': createdAt,
        'RoomNum': roomNum,
        "Items": items,
        "Name": name,
        "Image": image,
      };
}
