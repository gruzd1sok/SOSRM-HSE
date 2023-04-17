import 'package:flutter/material.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/screens/history_work_screen.dart';
import 'package:my_app/screens/login_screen.dart';
import 'package:my_app/screens/account_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await supabase.auth.signOut().then((_) {
        context.showSnackBar(message: 'Вы успешно вышли из приложения');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
          (route) => false,
        );
      });
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpected error occured');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(30),
      children: [
        ListTile(
          title: const Text(
            'История работ',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HistoryWork(),
            ),
          ),
        ),
        ListTile(
          title: const Text(
            'Настроить профиль',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AccountScreen(),
            ),
          ),
        ),
        TextButton(
          onPressed: () => _signOut(context),
          style: TextButton.styleFrom(foregroundColor: Colors.black),
          child: const Text(
            'Выйти',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
