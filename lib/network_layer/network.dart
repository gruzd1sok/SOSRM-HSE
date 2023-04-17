import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

part 'models/history_of_work.dart';
part 'models/instrument.dart';
part 'models/nfc_data.dart';
part 'models/workplace_data.dart';

final encoding = Encoding.getByName('utf-8');

String check =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB2aHZmcGd0anBrZGZ0eHVxYnBnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY2NjYzODI0NywiZXhwIjoxOTgyMjE0MjQ3fQ.LQ46PYnvF28uUoor9dA8FzNG4h0hhM4ybh-wmmnGuKE";

Future<List<HistoryOfWork>?> getHistoryOfWork(String profileId) async {
  final reqUri = Uri.parse(
      'https://pvhvfpgtjpkdftxuqbpg.supabase.co/rest/v1/rpc/getRentHistory');

  final Map<String, String> header = {
    'Content-type': 'application/json',
    'ApiKey': check,
    'Authorization': 'Bearer $check',
  };

  Map<String, dynamic> body = {"history_id": profileId};

  var res = await http.post(reqUri,
      body: jsonEncode(body), headers: header, encoding: encoding);

  if (res.statusCode == 200) {
    if (res.body != 'null') {
      print('----> ${res.body}');
      List<HistoryOfWork> history = (json.decode(res.body) as List)
          .map((data) => HistoryOfWork.fromJson(data))
          .toList();
      history.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );
      return history;
    }
  }
}

Future<List<WorkplaceData>?> getAllWorkspaces() async {
  final reqUri = Uri.parse(
      'https://pvhvfpgtjpkdftxuqbpg.supabase.co/rest/v1/rpc/getAllWorkspaces');

  final Map<String, String> header = {
    'Content-type': 'application/json',
    'ApiKey': check,
    'Authorization': 'Bearer $check',
  };

  var res = await http.post(reqUri, headers: header, encoding: encoding);

  if (res.statusCode == 200) {
    if (res.body != 'null') {
      List<WorkplaceData> workplaces = (json.decode(res.body) as List)
          .map((data) => WorkplaceData.fromJson(data))
          .toList();
      workplaces.sort(
        (a, b) => a.name.compareTo(b.name),
      );
      return workplaces;
    }
  }
}

Future<WorkplaceData?> getDataForWorkplaceId(String workplaceId) async {
  final reqUri = Uri.parse(
      'https://pvhvfpgtjpkdftxuqbpg.supabase.co/rest/v1/rpc/getAllWorkspaces');

  final Map<String, String> header = {
    'Content-type': 'application/json',
    'ApiKey': check,
    'Authorization': 'Bearer $check',
  };

  Map<String, dynamic> body = {"workplaceid": workplaceId};

  var res = await http.post(reqUri,
      body: jsonEncode(body), headers: header, encoding: encoding);

  if (res.statusCode == 200) {
    if (res.body != 'null') {
      var decode = jsonDecode(res.body);
      return WorkplaceData.fromJson(decode);
    }
  }
}

Future<NfcData?> getNfcInfo(String nfc_id) async {
  final reqUri = Uri.parse(
      'https://pvhvfpgtjpkdftxuqbpg.supabase.co/rest/v1/rpc/getNfcInfo');

  final Map<String, String> header = {
    'Content-type': 'application/json',
    'ApiKey': check,
    'Authorization': 'Bearer $check',
  };

  Map<String, dynamic> body = {"nfc_id": nfc_id};

  var res = await http.post(reqUri,
      body: jsonEncode(body), headers: header, encoding: encoding);

  if (res.statusCode == 200) {
    var decode = jsonDecode(res.body);
    print('----> ${res.body}');
    return NfcData.fromJson(decode[0]);
  }
}

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
