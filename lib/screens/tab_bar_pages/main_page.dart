import 'package:flutter/material.dart';
import 'package:my_app/pages/home_page.dart';
import 'package:my_app/pages/home_page_data.dart';
import 'package:my_app/network_layer/network.dart';

class MainPage extends StatelessWidget {
  const MainPage(this.nfcData, {super.key});

  final NfcData? nfcData;

  @override
  Widget build(BuildContext context) =>
      nfcData == null ? const HomePage() : HomePageWithData(nfcData: nfcData!);
}
