import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_app/pages/account_page.dart';
import 'package:my_app/pages/home_page.dart';
import 'package:my_app/pages/home_page_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/network.dart';

class NavDrawer extends StatelessWidget {
  NfcData? nfcData;
  NavDrawer({super.key, required this.nfcData});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          AppBar(
            title: const Text(
              "ПРОФИЛЬ",
              style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.normal,
                  fontSize: 25.0),
            ),
            backgroundColor: Colors.orange,
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('Главная'),
            onTap: () => {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      nfcData == null
                          ? MyHomePage()
                          : MyHomePageWithData(nfcData: nfcData!),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              )
            },
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Профиль'),
            onTap: () => {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => AccountPage(
                    navDrawer: NavDrawer(
                      nfcData: nfcData,
                    ),
                  ),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              )
            },
          ),
          // ListTile(
          //   leading: Icon(Icons.settings),
          //   title: Text('Settings'),
          //   onTap: () => {Navigator.of(context).pop()},
          // ),
        ],
      ),
    );
  }
}
