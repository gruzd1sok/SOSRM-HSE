import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:native_shared_preferences/native_shared_preferences.dart';

final supabase = Supabase.instance.client;
final key = Supabase.instance.client.supabaseKey;
final userId = supabase.auth.currentSession!.user.id;
final token = supabase.auth.currentSession!.accessToken;

extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.green,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ));
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }
}
