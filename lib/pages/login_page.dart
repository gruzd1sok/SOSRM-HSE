import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _redirecting = false;
  late final TextEditingController _emailController;
  late final StreamSubscription<AuthState> _authStateSubscription;

  isValid(String text) {
    setState(() {
      _isLoading = true;
    });
    final valid = _emailController.text.toLowerCase().endsWith('miem.hse.ru');
    if (valid == true) {
      setState(() {
        _isLoading = false;
      });
      return true;
    } else {
      _emailController.clear();
      setState(() {
        _isLoading = false;
      });
      return false;
    }
  }

  Future<void> _signIn() async {
    if (isValid(_emailController.text)) {
      setState(() {
        _isLoading = true;
      });
      try {
        final response = await supabase.auth.signInWithOtp(
          email: _emailController.text,
          emailRedirectTo:
              kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
        );
        if (mounted) {
          context.showSnackBar(
              message: 'Проверь почту, там сейчас будет ссылка!');
          _emailController.clear();
        }
      } on AuthException catch (error) {
        context.showErrorSnackBar(message: error.message);
      } catch (error) {
        context.showErrorSnackBar(message: 'Unexpected error occured');
      }

      setState(() {
        _isLoading = false;
      });
    } else {
      context.showErrorSnackBar(
          message: 'Необходима почта домена @miem.hse.ru');
    }
  }

  @override
  void initState() {
    _emailController = TextEditingController();
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (_redirecting) return;
      final session = data.session;
      if (session != null) {
        _redirecting = true;
        Navigator.of(context).pushReplacementNamed('/registration');
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Авторизация",
          style: TextStyle(
              color: Colors.white, fontStyle: FontStyle.normal, fontSize: 25.0),
        ),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          const Text(
              'Введите почту с доменом @miem.hse.ru и зайдите по Magic Link'),
          const SizedBox(height: 18),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _isLoading ? null : _signIn,
            child: Text(_isLoading ? 'Загрузка' : 'Отправить Magic Link'),
          ),
        ],
      ),
    );
  }
}
