import 'package:flutter/material.dart';
import 'package:my_app/network_layer/network.dart';
import 'package:my_app/ui_components/custom_app_bar.dart';

class InstrumentsDetailScreen extends StatelessWidget {
  const InstrumentsDetailScreen({
    super.key,
    required this.instrument,
  });

  final Instrument instrument;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: instrument.name),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(instrument.image),
            const SizedBox(height: 30),
            Text(
              instrument.description,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
