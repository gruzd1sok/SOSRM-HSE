import 'package:flutter/material.dart';
import 'package:my_app/screens/tab_bar_screen.dart';
import 'package:my_app/ui_components/custom_app_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/constants.dart';
import 'package:native_shared_preferences/native_shared_preferences.dart';
import '../network_layer/network.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _groupController = TextEditingController();
  final _phoneController = TextEditingController();
  var _loadingScreen = true;
  var _loading = false;

  openScreen() async {
    final nfcData = await fetchActiveNfc();
    return TabBarScreen(nfcData);
  }

  _saveUserId(String id) async {
    NativeSharedPreferences prefs = await NativeSharedPreferences.getInstance();
    const key = 'userId';
    prefs.setString(key, id);
  }

  /// Called once a user id is received within `onAuthenticated()`
  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });

    final screen = await openScreen();
    Map<dynamic, dynamic>? data;
    try {
      final userId = supabase.auth.currentUser!.id;
      data = await supabase.from('profiles').select().eq('id', userId).single()
          as Map;
    } on PostgrestException catch (error) {
      // context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpected exception occured');
    }

    if (data != null) {
      final isNewUser = data['name'];
      if (isNewUser == 'false') {
        _nameController.text = (data['name'] ?? '') as String;
        _surnameController.text = (data['surname'] ?? '') as String;
        _phoneController.text = (data['phone'] ?? '') as String;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      }
    }
    setState(() {
      _loading = false;
      _loadingScreen = false;
    });
  }

  /// Called when user taps `Update` button
  Future<void> _updateProfile() async {
    setState(() {
      _loading = true;
    });
    final name = _nameController.text;
    final surname = _surnameController.text;
    final phone = _phoneController.text;
    final user = supabase.auth.currentUser;
    _saveUserId(user!.id);
    final updates = {
      'id': user.id,
      'name': name,
      'surname': surname,
      'phone': phone,
      'updated_at': DateTime.now().toIso8601String(),
      'isNewUser': false,
    };
    try {
      await supabase.from('profiles').upsert(updates);
      if (mounted) {
        context.showSnackBar(message: 'Регистрация завершена!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TabBarScreen(null),
          ),
        );
      }
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpeted error occured');
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _groupController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _loadingScreen
        ? Scaffold(
            body: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            appBar: CustomAppBar(title: 'Регистрация'),
            body: ListView(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Имя'),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _surnameController,
                  decoration: const InputDecoration(labelText: 'Фамилия'),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Телефон'),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _updateProfile,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: Text(
                      _loading ? 'Сохранение...' : 'Завершить регистрацию'),
                ),
              ],
            ),
          );
  }
}
