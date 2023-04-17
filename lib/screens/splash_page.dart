import 'package:flutter/material.dart';
import 'package:my_app/screens/login_screen.dart';
import 'package:my_app/screens/tab_bar_screen.dart';
import '../constants.dart';
import '../network_layer/network.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _redicrectCalled = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _redirect();
  }

  openScreen() async {
    final nfcData = await fetchActiveNfc();
    return TabBarScreen(nfcData);
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    if (_redicrectCalled || !mounted) {
      return;
    }

    _redicrectCalled = true;
    final session = supabase.auth.currentSession;
    if (session != null) {
      final screen = await openScreen();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => screen,
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
