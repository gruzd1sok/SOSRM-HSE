import 'package:flutter/material.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/network_layer/network.dart';
import 'package:my_app/ui_components/custom_app_bar.dart';

class HistoryWork extends StatelessWidget {
  const HistoryWork({super.key});

  Future<List<HistoryOfWork>?> _getHistoryOfWork() async {
    final result = await getHistoryOfWork(userId);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'История работ',
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<HistoryOfWork>?>(
          future: _getHistoryOfWork(),
          builder: (context, AsyncSnapshot<List<HistoryOfWork>?> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                return SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      snapshot.data!.length,
                      (index) => _HistoryView(
                        history: snapshot.data![index],
                        isLast: index + 1 == snapshot.data!.length,
                      ),
                    ),
                  ),
                );
              } else {
                return const Text('error');
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView({
    super.key,
    required this.history,
    required this.isLast,
  });

  final HistoryOfWork history;
  final bool isLast;

  String _returnHoursAndMinutes(String time) {
    var date = DateTime.parse(time);
    return '${date.hour + 3}:${date.minute}';
  }

  String _returnDate(String time) {
    var date = DateTime.parse(time);
    return '${date.day}.${date.month}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Text(
                history.name,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 10),
              Text(_returnDate(history.createdAt)),
              const SizedBox(width: 10),
              Text(
                _returnHoursAndMinutes(history.createdAt),
              ),
              const Spacer(),
              Icon(
                Icons.circle,
                color: history.mark >= 4 ? Colors.green : Colors.red,
              )
            ],
          ),
        ),
        if (!isLast)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              height: 1,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }
}
