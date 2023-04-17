import 'package:flutter/material.dart';
import 'package:my_app/design_system/palette.dart';
import 'package:my_app/network_layer/network.dart';
import 'package:my_app/screens/tab_bar_pages/main_page.dart';
import 'package:my_app/screens/tab_bar_pages/settings_page.dart';
import 'package:my_app/screens/tab_bar_pages/workplaces_page.dart';
import 'package:my_app/ui_components/custom_app_bar.dart';

class TabBarScreen extends StatefulWidget {
  const TabBarScreen(this.nfcData);

  final NfcData? nfcData;
  @override
  State<StatefulWidget> createState() => _TabBarScreen();
}

class _TabBarScreen extends State<TabBarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tcontroller;
  final List<String> titleList = ['Главный экран', 'Пространства', 'Настройки'];
  late String currentTitle;

  @override
  void initState() {
    currentTitle = titleList[0];
    _tcontroller = TabController(length: 3, vsync: this);
    _tcontroller.addListener(changeTitle);
    super.initState();
  }

  void changeTitle() {
    setState(() {
      currentTitle = titleList[_tcontroller.index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: CustomAppBar(title: currentTitle),
          bottomNavigationBar: menu(),
          body: TabBarView(
            controller: _tcontroller,
            children: [
              MainPage(widget.nfcData),
              const WorkplacesPage(),
              const SettingsPage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget menu() {
    return Container(
      color: Palette.mainAppColor,
      child: TabBar(
        padding: const EdgeInsets.only(bottom: 15),
        controller: _tcontroller,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(5.0),
        indicatorColor: Colors.blue,
        labelPadding: EdgeInsets.symmetric(horizontal: 10),
        tabs: const [
          Tab(
            text: 'Главный экран',
            icon: Icon(Icons.pages),
          ),
          Tab(
            text: 'Пространства',
            icon: Icon(Icons.work),
          ),
          Tab(
            text: 'Настройки',
            icon: Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
