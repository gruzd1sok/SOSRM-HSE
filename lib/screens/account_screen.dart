
import 'package:flutter/material.dart';
import 'package:my_app/design_system/palette.dart';
import 'package:my_app/ui_components/custom_app_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/constants.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _groupController = TextEditingController();
  final _phoneController = TextEditingController();
  var _loading = false;

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
      _phoneController.text = (data['phone'] ?? '') as String;
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      //context.showErrorSnackBar(message: 'Unexpected exception occured');
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
    final updates = {
      'id': user!.id,
      'name': name,
      'surname': surname,
      'phone': phone,
      'updated_at': DateTime.now().toIso8601String(),
    };
    try {
      await supabase.from('profiles').upsert(updates);
      if (mounted) {
        context.showSnackBar(message: 'Данные обновлены!');
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
    return Scaffold(
      appBar: CustomAppBar(title: 'Профиль'),
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
                ElevatedButton.styleFrom(backgroundColor: Palette.mainAppColor),
            child: Text(_loading ? 'Сохранение...' : 'Обновить данные'),
          ),
        ],
      ),
    );
  }
}
