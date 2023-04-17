import 'package:flutter/material.dart';
import 'package:my_app/pages/rating_screen.dart';
import 'package:my_app/screens/instruments_detail_screen.dart';
import 'package:my_app/ui_components/custom_app_bar.dart';
import '../network_layer/network.dart';
import '../widgets/detail_screen.dart';

class InstrumentsPage extends StatelessWidget {
  NfcData nfcData;
  InstrumentsPage({super.key, required this.nfcData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: 'Начало работы',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              '${nfcData.name}\nРабочее место #:${nfcData.roomNum}',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return DetailScreen(photo: Image.network(nfcData.image));
                    },
                  ),
                );
              },
              child: Image.network(nfcData.image),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'На данном рабочем месте доступно:',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Column(
              children: List.generate(
                nfcData.instrument.length,
                (index) => InstrumentView(
                  instrument: nfcData.instrument[index],
                  onTap: (instrument) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          InstrumentsDetailScreen(instrument: instrument),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RatingScreen(nfcData: nfcData),
                    ),
                  );
                },
                child: const Text(
                  'Продолжить',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InstrumentView extends StatelessWidget {
  const InstrumentView({
    super.key,
    required this.instrument,
    required this.onTap,
  });

  final Instrument instrument;
  final Function(Instrument) onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(instrument),
      child: ListTile(
        leading: SizedBox(
          width: 100,
          height: 100,
          child: Image.network(instrument.image),
        ),
        title: Text(instrument.name),
        trailing: const Icon(Icons.keyboard_arrow_right),
      ),
    );
  }
}
