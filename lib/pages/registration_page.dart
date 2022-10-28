import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/constants.dart';
import 'package:native_shared_preferences/native_shared_preferences.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _groupController = TextEditingController();
  final _phoneController = TextEditingController();
  var _loading = false;

  _saveUserId(String id) async {
    NativeSharedPreferences prefs = await NativeSharedPreferences.getInstance();
    const key = 'userId';
    prefs.setString(key, id);
    print('set userId - $id');
  }

  /// Called once a user id is received within `onAuthenticated()`
  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single() as Map;
      _nameController.text = (data['name'] ?? '') as String;
      _surnameController.text = (data['surname'] ?? '') as String;
      _groupController.text = (data['group'] ?? '') as String;
      _phoneController.text = (data['phone'] ?? '') as String;
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpected exception occured');
    }

    setState(() {
      _loading = false;
    });
  }

  /// Called when user taps `Update` button
  Future<void> _updateProfile() async {
    setState(() {
      _loading = true;
    });
    final name = _nameController.text;
    final surname = _surnameController.text;
    final group = _groupController.text;
    final phone = _phoneController.text;
    final user = supabase.auth.currentUser;
    _saveUserId(user!.id);
    final updates = {
      'id': user.id,
      'name': name,
      'surname': surname,
      'group': group,
      'phone': phone,
      'updated_at': DateTime.now().toIso8601String(),
    };
    try {
      await supabase.from('profiles').upsert(updates);
      if (mounted) {
        context.showSnackBar(message: 'Регистрация завершена!');
        Navigator.pushReplacementNamed(context, '/home');
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

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpected error occured');
    }
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Регистрация",
          style: TextStyle(
              color: Colors.white, fontStyle: FontStyle.normal, fontSize: 25.0),
        ),
        backgroundColor: Colors.orange,
      ),
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
            controller: _groupController,
            decoration: const InputDecoration(labelText: 'Группа'),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Телефон'),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _updateProfile,
            child: Text(_loading ? 'Сохранение...' : 'Завершить регистрацию'),
          ),
          const SizedBox(height: 18),
          TextButton(onPressed: _signOut, child: const Text('Выйти')),
        ],
      ),
    );
  }
}
