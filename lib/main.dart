import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/account_page.dart';
import 'pages/login_page.dart';
import 'pages/splash_page.dart';
import 'pages/home_page.dart';
import 'pages/registration_page.dart';
import 'pages/instruments_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://pvhvfpgtjpkdftxuqbpg.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB2aHZmcGd0anBrZGZ0eHVxYnBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NjY2MzgyNDcsImV4cCI6MTk4MjIxNDI0N30.II9pH6jEmEdpe07M2m56RA1oniXS9mayCsxikRMPepI",
  );

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Flutter',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.orange,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.orange,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.orange,
          ),
        ),
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (_) => const SplashPage(),
        '/login': (_) => const LoginPage(),
        '/home': (_) => const MyHomePage(),
        '/registration': (_) => const RegistrationPage(),
      },
    );
  }
}
