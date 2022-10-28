import 'package:flutter/material.dart';
import 'package:my_app/pages/home_page.dart';
import 'package:my_app/pages/home_page_data.dart';
import '../constants.dart';
import 'network.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _redicrectCalled = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _redirect();
  }

  openScreen() async {
    final nfcData = await fetchActiveNfc();
    if (nfcData == null) {
      return const MyHomePage();
    } else {
      return MyHomePageWithData(nfcData: nfcData);
    }
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
          context, MaterialPageRoute(builder: (context) => screen));
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
